package com.electrotank.electroserver4.message.request {
    import com.electrotank.electroserver4.message.request.*;
    import com.electrotank.electroserver4.message.MessageType;
    import com.electrotank.electroserver4.message.ValidationResponse;
    
    public class DeleteUserVariableRequest extends RequestImpl {

        private var name:String;
        public function DeleteUserVariableRequest() {
            setMessageType(MessageType.DeleteUserVariableRequest);
        }
        public function setName(str:String):void {

            name = str;
        }
        public function getName():String {
            return name;
        }
    }
}
