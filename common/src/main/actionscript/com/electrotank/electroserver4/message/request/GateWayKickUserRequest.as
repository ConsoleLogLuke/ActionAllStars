package com.electrotank.electroserver4.message.request {
    import com.electrotank.electroserver4.errors.EsError;
    import com.electrotank.electroserver4.message.request.*;
    import com.electrotank.electroserver4.message.MessageType;
    import com.electrotank.electroserver4.esobject.EsObject;
    import com.electrotank.electroserver4.message.ValidationResponse;
    
    public class GateWayKickUserRequest extends RequestImpl {

        private var eserror:EsError;
        private var esObject:EsObject;
        /**
         * Creates a new instance of the GateWayKickUserRequest
         */
        public function GateWayKickUserRequest() {
            setMessageType(MessageType.GateWayKickUserRequest);
        }
        
     override public function validate():ValidationResponse {    
            var valid:Boolean = true;
            var problems:Array = new Array();
            var vr:ValidationResponse = new ValidationResponse(valid, problems);
            return vr;
        }
        public function setEsObject(esob:EsObject):void {

            esObject = esob;
        }
        public function getEsObject():EsObject {
            return esObject;
        }
        public function setEsError(esError:EsError):void {

            this.eserror = esError;
        }
        public function getEsError():EsError {
            return eserror;
        }
    
    }
}
