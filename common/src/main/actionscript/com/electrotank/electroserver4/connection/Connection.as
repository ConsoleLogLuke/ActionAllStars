package com.electrotank.electroserver4.connection {
    
    import com.electrotank.electroserver4.connection.*;
    import com.electrotank.electroserver4.utils.Observable;
    import com.electrotank.electroserver4.entities.Protocol;
    
     
    import flash.events.*;
    import flash.display.Sprite;
    import flash.net.XMLSocket;
    import flash.system.Security;
    import flash.net.Socket;
    import flash.utils.ByteArray;
     
    
    
    /**
     * This class is used internally to the ElectroServer class. When you want to create a new connection use ElectroServer.createConnection. This class is used to handle text-based socket connections to the server.
     */
    
    public class Connection extends AbstractConnection {

        private var socket:XMLSocket;
        
     
        private var binarySocket:Socket;
        private var handledPolicyFile:Boolean;
        private var waitingForHeader:Boolean;
        private var bytesNeeded:int;
     
    
        
        //PUBLIC 
        /**
         * @private
         */
        public var onData:Function;
        /**
         * Creates a new instance of the Connection class.
         * @param tmpip    The ip to connect to.
         * @param tmpport The port to use.
         */
        public function Connection(tmpip:String, tmpport:Number, protocol:String) {
            super(tmpip, tmpport, protocol);
            
            trace("Connection:init()");
            
     
                if (protocol == Protocol.BINARY) {
                    waitingForHeader = true;
                    handledPolicyFile = false;
                    binarySocket = new Socket();
                    binarySocket.addEventListener(Event.CONNECT, onBinaryConnect);
                    binarySocket.addEventListener(Event.CLOSE, onBinaryClose);
                    binarySocket.addEventListener(ProgressEvent.SOCKET_DATA, onBinarySocketData);
                    binarySocket.addEventListener(IOErrorEvent.IO_ERROR, onBinaryIOErrorEvent);
                }
     
            
            
     Security.loadPolicyFile("xmlsocket://"+ getIp()+":"+getPort());
            
            socket = new XMLSocket();
            
     configureListeners(socket);
            
      
      
      
        }
        
        
        
     
            private function onBinaryIOErrorEvent(e:IOErrorEvent):void {
                 onPreConnect(false);
            }
            private function onBinaryClose(e:Event):void {
                onPreClose();
            }
            private function onBinaryConnect(e:Event):void {
                onPreConnect(true);
            }
            private function onBinarySocketData(e:ProgressEvent):void {
                if (!handledPolicyFile) {
                    if (binarySocket.readUTFBytes(1) == "<") {
                        while (binarySocket.readByte() != 0) {
                        }
                        handledPolicyFile = true;
                    }
                }
                processBinarySocketData();
            }
            private function processBinarySocketData():void {
                if (!binarySocket.connected) {
                    return;
                }
                if (waitingForHeader) {
                    if (binarySocket.bytesAvailable >= 4) {
                        bytesNeeded = binarySocket.readInt();
                        waitingForHeader = false;
                    }
                }
                if (!waitingForHeader) {
                    if (binarySocket.bytesAvailable >= bytesNeeded) {
                        var ba:ByteArray = new ByteArray();
                        binarySocket.readBytes(ba, 0, bytesNeeded);
                        notifyListeners("onBinaryData", { target:this, data:ba } );
                        waitingForHeader = true;
                        processBinarySocketData();
                    }
                }
            }
            public override function sendBinary(ba:ByteArray):void {
                binarySocket.writeBytes(ba);
                binarySocket.flush();
            }
     
        
        //AS3
      
        private function configureListeners(dispatcher:IEventDispatcher):void {
            dispatcher.addEventListener(Event.CLOSE, closeHandler);
            dispatcher.addEventListener(Event.CONNECT, connectHandler);
            dispatcher.addEventListener(DataEvent.DATA, dataHandler);
            dispatcher.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
            dispatcher.addEventListener(ProgressEvent.PROGRESS, progressHandler);
            dispatcher.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
        }
        private function closeHandler(event:Event):void {
            //trace("closeHandler: " + event);
            onPreClose();
        }
    
        private function connectHandler(event:Event):void {
            //trace("connectHandler: " + event);
            onPreConnect(true);
        }
    
        private function dataHandler(event:DataEvent):void {
            //trace("dataHandler: " + event);
            onPreData(event.data);
        }
    
        private function ioErrorHandler(event:IOErrorEvent):void {
            onPreConnect(false);
        }
    
        private function progressHandler(event:ProgressEvent):void {
            //trace("progressHandler loaded:" + event.bytesLoaded + " total: " + event.bytesTotal);
        }
    
        private function securityErrorHandler(event:SecurityErrorEvent):void {
            trace("securityErrorHandler: " + event);
        }
        
        
      
        
        public override function send(message:String):void {

            socket.send(message);
        }
        /**
         * Closes the connection to the server.
         */
        protected override function doClose():void {
            
            if (getProtocol() == Protocol.TEXT) {
                socket.close();
            } else if (getProtocol() == Protocol.BINARY) {
     binarySocket.close();
            }
        }
        /**
         * Attempts to connect to the ip and port specified.
         */
        public override function connect():void {

                if (getProtocol() == Protocol.TEXT) {
                    socket.connect(getIp(), getPort());
                } else if (getProtocol() == Protocol.BINARY) {
     binarySocket.connect(getIp(), getPort());
                }
            }
    
        /**
         * Used internally to tell whoever is listening that data has just arrived.
         * @param    The data.
         */
        public function onPreData(data:String):void {

            //onData({target:this, data:data});
            notifyListeners("onStringData", {target:this, data:data});
        }
    }
}
