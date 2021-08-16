package com.electrotank.electroserver4.connection {
    
    import com.electrotank.electroserver4.utils.Observable;
    import com.electrotank.electroserver4.entities.Protocol;
    
     
    import flash.utils.ByteArray;
     
    
    /**
     * This class is used internally to the ElectroServer class. When you want to create a new connection use one of the connection functions on the ElectroServer object. This class is inherited by all Connection types to handle connection-related functions.
     */
    
    public class AbstractConnection extends Observable {

        private var ip:String;
        private var port:Number;
        private var id:Number;
        private var outboundId:Number = -1;
        private var expectedInboundId:Number = 0;
        private var isConnected:Boolean = false;
        private var protocol:String;
        
        //PUBLIC 
        /**
         * @private
         */
        public var onConnect:Function;
        /**
         * @private
         */
        public var onClose:Function;
        /**
         * Creates a new instance of the AbstractConnection class.
         * @param ip    The ip to connect to.
         * @param port The port to use.
         * @param protocol    The protocol to use.
         * @see com.electrotank.electroserver4.entities.Protocol
         */
        public function AbstractConnection( ip:String, port:Number, protocol:String ) {
            this.ip = ip;
            this.port = port;
            this.protocol = protocol;
        }
        
        /**
         * Gets the ip used.
         * @return The ip used.
         */
        public function getIp():String {
            return ip;
        }
        /**
         * Gets the port used.
         * @return The port used.
         */
        public function getPort():Number {
            return port;
        }
        /**
         * Sets the connection id.
         * @param    The connection id.
         */
        public function setId(id:Number):void {

            this.id = id;
        }
        /**
         * Gets the connection id.
         * @return The connection id.
         */
        public function getId():Number {
            return id;
        }
        /**
         * Gets the connection protocol.
         * @return The connection protocol.
         */
        public function getProtocol():String {
            return protocol;
        }
        /**
         * Sets the next expected inbound id.
         * @param    The next inbound id to expect.
         */
        public function setExpectedInboundId(id:Number):void {

            expectedInboundId = id;
        }
        /**
         * Gets the next expected inbound id.
         * @return The next expected inbound id.
         */
        public function getExpectedInboundId():Number {
            return expectedInboundId;
        }
        /**
         * Gets the next outbound id.
         * @return The next outbound id.
         */
        public function getNextOutboundId():Number {
            outboundId++;
            if (outboundId == 10000) {
                outboundId = 0;
            }
            return outboundId;
        }
        /**
         * Returns true if connected, false if not.
         * @return True or false.
         */
        public function getIsConnected():Boolean {
            return isConnected;
        }
    
        /**
         * Sends a message to the server.
         * @param The message to send.
         */
        public function send(message:String):void {

            if( getProtocol() == Protocol.TEXT ) {
                throw new Error("Must implement for text protocol");
            }
    
            throw new Error("Use sendBinary for binary connections");
        }
        
      
        /**
         * Sends a message to the server.
         * @param ba The message to send.
         */
        public function sendBinary( ba:ByteArray ):void {
            if( getProtocol() == Protocol.BINARY ) {
                throw new Error("Must implement for binary protocol");    
            }
    
            throw new Error("Use send for text connections");
        }
      
            
        /**
         * Closes the connection to the server.
         */
        public final function close():void {

            doClose();
    
            onPreClose();
        }
        
        /**
         * Must be implemented in a new inherited class.
         */
        protected function doClose():void {
            throw new Error("Must implement close");
        }
            
        /**
         * Used internally to send an event to whoever is listening.
         * @param success True or false. 
         */
        public function onPreConnect(success:Boolean):void {

            isConnected = success;
            notifyListeners("onConnect", {target:this, success:success});
        }
        /**
         * Attempts to connect to the ip and port specified.
         */
            public function connect():void {

                 throw new Error("Must implement connect");
            }
        /**
         * Used internally to tell whoever is listening that a connection close is happening.
         */
        public function onPreClose():void {

            isConnected = false;
            //onClose({target:this});
            notifyListeners("onClose", {target:this});
        }
    }
}
