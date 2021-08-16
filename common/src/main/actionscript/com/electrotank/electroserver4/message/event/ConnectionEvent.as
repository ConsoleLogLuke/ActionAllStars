package com.electrotank.electroserver4.message.event {
    import com.electrotank.electroserver4.message.MessageImpl;
    import com.electrotank.electroserver4.message.event.*;
    import com.electrotank.electroserver4.message.*;
    import com.electrotank.electroserver4.errors.*;
    /**
     * When the client tries to establish a new text or binary socket a ConnectionEvent is eventually fired. If the connection is successful then the getAccepted() method returns true. 
         * @example
         * This shows how to listen for the ConnectionEvent.
         * <listing>
    import com.electrotank.electroserver4.ElectroServer;
    import com.electrotank.electroserver4.message.MessageType;
    import com.electrotank.electroserver4.message.event.ConnectionEvent;
    //
    var es:ElectroServer;
    es.addEventListener(MessageType.ConnectionEvent, "onConnectionEvent", this);
    function onConnectionEvent(e:ConnectionEvent):void {
        trace("connection established: "+e.getAccepted());
    }
         * </listing>
     */
    
    public class ConnectionEvent extends EventImpl {

        private var accepted:Boolean;
        private var esError:EsError;
     private var hashId:int;
        private var prime:String;
        private var base:String;
        /**
         * Creates a new instance of the ConnectionEvent class.
         */
        public function ConnectionEvent() {
            setMessageType(MessageType.ConnectionEvent);
        }
     public function setHashId(hashId:int):void {
            this.hashId = hashId;
        }
     public function getHashId():int {
            return hashId;
        }
        /**
         * @private
         */
        public function setEsError(err:EsError):void {

            this.esError = err;
        }
        /**
         * Gets the EsError. If the connection failed then there will be an EsError.
         * @return The EsError.
         */
        public function getEsError():EsError {
            return this.esError;
        }
        /**
         * @private
         */
        public function setPrime(prime:String):void {

            this.prime = prime;
        }
        /**
         * Gets the prime.
         * @return The prime.
         */
        public function getPrime():String {
            return this.prime;
        }
        /**
         * @private
         */
        public function setBase(base:String):void {

            this.base = base;
        }
        /**
         * Gets the base.
         * @return The base.
         */
        public function getBase():String {
            return this.base;
        }
        /**
         * Returns true if the connection was a success.
         */
        public function get success():Boolean {
            return getAccepted();
        }
        /**
         * @private
         */
        public function setAccepted(val:Boolean):void {

            accepted = val;
        }
        /**
         * Returns true if the connection was a success.
         * @return True or false.
         */
        public function getAccepted():Boolean {
            return accepted;
        }
        public function toString():String {
            return "ConnectionEvent[id: " + getHashId() + ", accepted: " + accepted + "]";
        }
    }
}
