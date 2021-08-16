package com.electrotank.electroserver4 {
    import com.electrotank.electroserver4.message.ValidationResponse;
    
    public class SendStatus {

        //ERRORS
        static public var NOT_CONNECTED:String = "not_connected";
        static public var VALIDATION_FAILED:String = "validation_failed";
        //
        private var isSent:Boolean;
        private var reason:String;
        private var validationResponse:ValidationResponse;
        public function SendStatus() {
            
        }
        public function setValidationResponse(vr:ValidationResponse):void {

            this.validationResponse = vr;
        }
        public function getValidationResponse():ValidationResponse {
            return this.validationResponse;
        }
        public function setIsSent(isSent:Boolean):void {

            this.isSent = isSent;
        }
        public function getIsSent():Boolean {
            return isSent;
        }
        public function setReason(reason:String):void {

            this.reason = reason;
        }
        public function getReason():String {
            return reason;
        }
        
    }
}
