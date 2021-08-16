package com.electrotank.electroserver4.message.request {
    import com.electrotank.electroserver4.message.request.*;
    import com.electrotank.electroserver4.message.MessageType;
    import com.electrotank.electroserver4.esobject.EsObject;
    import com.electrotank.electroserver4.message.ValidationResponse;
    
    public class LogoutRequest extends RequestImpl {

        private var dropAllConnections:Boolean;
        private var dropConnection:Boolean;
        public function LogoutRequest() {
            setMessageType(MessageType.LogoutRequest);
            setDropAllConnections(true);
            setDropConnection(false);
        }
    
     override public function validate():ValidationResponse {    
            var valid:Boolean = true;
            var problems:Array = new Array();
            var vr:ValidationResponse = new ValidationResponse(valid, problems);
            return vr;
        }
        
        public function setDropAllConnections(val:Boolean):void {

            dropAllConnections = val;
        }
        public function getDropAllConnections():Boolean {
            return dropAllConnections;
        }
        public function setDropConnection(val:Boolean):void {

            dropConnection = val;
        }
        public function getDropConnection():Boolean {
            return dropConnection;
        }
    }
}
