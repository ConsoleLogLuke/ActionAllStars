package com.electrotank.electroserver4.message.request {
    import com.electrotank.electroserver4.message.request.*;
    import com.electrotank.electroserver4.message.MessageType;
    import com.electrotank.electroserver4.message.ValidationResponse;
    /**
     * @private
     */
    
    public class ValidateAdditionalLoginRequest extends RequestImpl {

        private var secret:String;
        public function ValidateAdditionalLoginRequest() {
            setMessageType(MessageType.ValidateAdditionalLoginRequest);
        }
    
     override public function validate():ValidationResponse {    
            var valid:Boolean = true;
            var problems:Array = new Array();
            var vr:ValidationResponse = new ValidationResponse(valid, problems);
            return vr;
        }
        
        public function setSecret(str:String):void {

            secret = str;
        }
        public function getSecret():String {
            return secret;
        }
    }
}
