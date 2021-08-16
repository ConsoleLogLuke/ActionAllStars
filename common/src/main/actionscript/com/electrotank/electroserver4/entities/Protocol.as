package com.electrotank.electroserver4.entities {
    /**
     * ElectroServer supports several different protocols. Normal ElectroServer communication can occur with text or binary protocols. ElectroServer also supports RTMP for streaming audio and video. When setting the protocol to use with ElectroServer this class is used. RTMP is not handled through this class, that is a special case and is built-in to the Flash player.
     */
    
    public class Protocol {

        //static vars
        static public var TEXT:String = "text";
        static public var BINARY:String = "binary";
        //
        private var protocolId:Number;
        public function Protocol() {
            
        }
        public function setProtocolId(protocolId:Number):void {

            this.protocolId = protocolId;
        }
        public function getProtocolId():Number {
            return protocolId;
        }
    }
}
