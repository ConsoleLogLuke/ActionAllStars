     
    package com.electrotank.electroserver4.connection {
        import flash.utils.Timer;
        import com.electrotank.electroserver4.ElectroServer;
        import com.electrotank.electroserver4.message.event.ConnectionEvent;
        import com.electrotank.electroserver4.message.MessageType;
        import com.electrotank.electroserver4.connection.*;
        import com.electrotank.electroserver4.entities.Protocol;
        import flash.events.*;
        import flash.system.Security;
        import flash.utils.ByteArray;
    
    /**
     * This class is used internally to the ElectroServer class. When you want to create a new HTTP connection use ElectroServer.createHttpConnection. This class is used to handle binary-based socket connections to the server.
     */
        public class HttpConnection extends AbstractConnection {
    
            private var workers:Array = new Array();
            private var sessionKey:String = null;
            private var closing:Boolean = false;
    
            private var _retryCount:uint = 7;
            private var _retryDelay:uint = 1000;
    
        /**
         * Creates a new instance of the HttpConnection class.
         * @param ip    The ip to connect to.
         * @param port The port to use.
         * @param es The instance of the ElectroServer object that you want to attach the HttpConnection to.
         */
            public function HttpConnection( ip:String, port:Number, es:ElectroServer ) {
                super(ip, port, Protocol.BINARY);
    
                es.addEventListener(MessageType.ConnectionEvent, "onConnectionEvent", this, true);
    
                Security.loadPolicyFile("http://" + ip + ":" + port + "/cross-domain");
            }
    
            /**
             * Get the number of times to retry on a failure to send a message.
             * @return Number of retries. Default is 7
             */
            public function get retryCount():uint {
                return _retryCount;
            }
            /**
             * Set the number of times to retry on a failure to send a message.
             * @param val Number of times to retry. Numbers < 1 disable the retry logic
             */
            public function set retryCount( val:uint ):void {
                _retryCount = val;
            }
    
            /**
             * Get the delay between retries in milliseconds
             * @return Delay between retries. Default is 1000 (1s)
             */
            public function get retryDelay():uint {
                return _retryDelay;
            }
            /**
             * Set the delay between retry attempts.
             * @param val Retry delay in milliseconds
             */
            public function set retryDelay( val:uint ):void {
                _retryDelay = val;
            }
    
      
        /**
         * Sends a message to the server.
         * @param message The message to send.
         */
            override public function sendBinary( message:ByteArray ):void {
                if ( null == sessionKey ) {
                    throw new Error("Cannot send a message until the connection process is complete");
                }
    
                var worker:HttpWorker = new HttpWorker(this);
    
                if ( retryCount > 0 ) {
                    var timer:Timer = null;
                    var listener:Function = function():void {
                        worker.addEventListener(IOErrorEvent.IO_ERROR, function():void {
                            if ( timer.currentCount <= timer.repeatCount ) {
                                timer.start();
                            } else {
                                onPreConnect(false);
                            }
                        });
                        worker.removeEventListener(IOErrorEvent.IO_ERROR, listener)
    
                        timer = new Timer(retryDelay, retryCount);
                        timer.addEventListener(TimerEvent.TIMER, function():void {
                            timer.stop(); // pause it in case we're delayed for awhile..
    //                        log("### re-sending " + message);
                            worker.send("/s/" + sessionKey, message);
                        });
                        timer.start();
                    };
    
                    worker.addEventListener(IOErrorEvent.IO_ERROR, listener);
                }
    
                worker.send("/s/" + sessionKey, message);
            }
    
        /**
         * Attempts to connect to the ip and port specified.
         */
            override public function connect():void {
                var data:ByteArray = new ByteArray();
                data.writeByte(0);
    
                var worker:HttpWorker = new HttpWorker(this);
    
                worker.addEventListener(Event.OPEN, function():void {
                    onPreConnect(true);
                });
                worker.addEventListener(IOErrorEvent.IO_ERROR, function():void {
                    onPreConnect(false);
                });
    
                worker.send("/connect/binary", data);
            }
    
        /**
         * Closes the connection to the server.
         */
            override protected function doClose():void {
                closing = true;
    
                while ( workers.length > 0 ) {
                    for ( var i:int; i = 0; i < workers.length ) {
                        HttpWorker(workers[i]).close();
                    }
                }
            }
    
        /**
         * Event fired upon connection attempt.
         */
            public function onConnectionEvent( e:ConnectionEvent ):void {
                sessionKey = e.getHashId().toString();
            }
    
        /**
         * Add worker object to handle connection communications.
         * @param worker HttpWorker object.
         */
            internal function addWorker( worker:HttpWorker ):void {
                workers.push(worker);
    //            log("+++ Add " + worker + " -- " + workers.length);
            }
    
        /**
         * Remove worker object that is handling connection communications.
         * @param worker HttpWorker object.
         */
            internal function removeWorker( worker:HttpWorker ):void {
    //            log("--- Del " + worker + " -- " + workers.length);
    
                var index:int = workers.indexOf(worker);
    
                if ( index >= 0 ) {
                    workers.splice(index, 1);
                }
    
    //            log("    " + workers);
    
                if ( !closing && workers.length == 0 ) {
    //                log("*** All connections gone. Opening polling connection");
                    sendBinary(null); // open a polling connection
                }
            }
    
        /**
         * Timestamped output of object.
         * @param o Object to dump.
         */
            internal static function log(o:Object):void {
                trace( new Date() + " " + o);
            }
        }
    }
     
