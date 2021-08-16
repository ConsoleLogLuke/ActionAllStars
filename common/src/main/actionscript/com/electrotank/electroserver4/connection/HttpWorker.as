     
    package com.electrotank.electroserver4.connection {
        import com.electrotank.electroserver4.protocol.binary.BinaryMessageWriter;
        import flash.events.ErrorEvent;
        import flash.events.IEventDispatcher;
        import flash.events.SecurityErrorEvent;
        import flash.events.ProgressEvent;
        import flash.events.IOErrorEvent;
        import flash.events.Event;
        import flash.net.URLRequestMethod;
        import flash.net.URLRequest;
        import flash.utils.ByteArray;
        import flash.net.URLStream;
    
        internal class HttpWorker implements IEventDispatcher {
            private static var counter:uint = 0;
    
            private var connection:HttpConnection;
            private var stream:URLStream;
    
            private var bytesNeeded:int = 0;
    
            private var _id:uint;
    
            function HttpWorker( connection:HttpConnection ) {
                this.connection = connection;
                this._id = counter++;
    
                var worker:HttpWorker = this;
    
                this.stream = new URLStream();
                this.stream.addEventListener(Event.COMPLETE, function():void {
                    connection.removeWorker(worker);
                });
                this.stream.addEventListener(Event.OPEN, function():void {
    //                HttpConnection.log(worker + " opened");
                    connection.addWorker(worker);
                });
                this.stream.addEventListener(ProgressEvent.PROGRESS, function( e:Event ):void {
    //                HttpConnection.log(e);
                    readData();
                });
    
                this.stream.addEventListener(IOErrorEvent.IO_ERROR, function( e:ErrorEvent ):void {
                    HttpConnection.log(e);
                });
                this.stream.addEventListener(SecurityErrorEvent.SECURITY_ERROR, function( e:ErrorEvent ):void {
                    HttpConnection.log(e);
                });
            }
    
            internal function send( url:String, data:ByteArray ):void {
                var request:URLRequest = new URLRequest();
    
                request.url = "http://" + connection.getIp() + ":" + connection.getPort() + url;
                request.data = data;
                request.method = URLRequestMethod.POST;
    
    //            HttpConnection.log(this + " >>> " + request.url);
    
                stream.load(request);
            }
    
            internal function close():void {
                stream.close();
            }
    
            private function readData():void {
                if ( !stream.connected ) {
                    // nothing to do, not connected!
                } else if ( bytesNeeded > 0 ) {
                    if ( stream.bytesAvailable >= bytesNeeded ) {
                        var data:ByteArray = new ByteArray();
    
                        stream.readBytes(data, 0, bytesNeeded);
    
                        bytesNeeded = 0;
    
    //                    HttpConnection.log("data: " + BinaryMessageWriter.dumpByteArray(data));
    
                        if ( 0 == data[0] && 0 == data[1] ) {
    //                        HttpConnection.log("discarding padding bytes");
                        } else {
                            connection.notifyListeners("onBinaryData", { target:connection, data:data });
                        }
    
                        readData();
                    } else {
    //                    HttpConnection.log("Waiting for more data. Need " + bytesNeeded + " but only have " + stream.bytesAvailable);
                    }
                } else if ( stream.bytesAvailable >= 4 ) {
                    bytesNeeded = stream.readInt();
    
                    readData();
                } else {
    //                HttpConnection.log("Waiting for 4-byte stream header. Only have " + stream.bytesAvailable);
                }
            }
    
            public function dispatchEvent( event:Event ):Boolean {
                return stream.dispatchEvent(event);
            }
    
            public function hasEventListener( type:String ):Boolean {
                return stream.hasEventListener(type);
            }
    
            public function willTrigger( type:String ):Boolean {
                return stream.willTrigger(type);
            }
    
            public function removeEventListener( type:String, listener:Function, useCapture:Boolean = false ):void {
                stream.removeEventListener(type, listener, useCapture);
            }
    
            public function addEventListener( type:String, listener:Function, useCapture:Boolean = false, priority:int = 0,
                                              useWeakReference:Boolean = false ):void {
                stream.addEventListener(type, listener, useCapture, priority, useWeakReference);
            }
    
            public function toString():String {
                return "[HttpWorker " + _id + "]";
            }
        }
    }
     
