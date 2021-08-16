package com.electrotank.electroserver4.message.response {
    import com.electrotank.electroserver4.message.MessageImpl;
    import com.electrotank.electroserver4.message.response.*;
    import com.electrotank.electroserver4.message.*;
    import com.electrotank.electroserver4.errors.*;
    import com.electrotank.electroserver4.esobject.EsObject;
    
    public class ValidateAdditionalLoginResponse extends ResponseImpl {

        private var approved:Boolean;
        private var secret:String;
        public function ValidateAdditionalLoginResponse() {
            setMessageType(MessageType.ValidateAdditionalLoginResponse);
        }
        public function getApproved():Boolean {
            return approved;
        }
        public function setApproved(val:Boolean):void {

            approved = val;
        }
        public function setSecret(str:String):void {

            secret = str;
        }
        public function getSecret():String {
            return secret;
        }
    }
}
