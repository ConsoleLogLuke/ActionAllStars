package com.electrotank.electroserver4.message.response {
    import com.electrotank.electroserver4.esobject.EsObject;
    import com.electrotank.electroserver4.message.MessageImpl;
    import com.electrotank.electroserver4.message.response.*;
    import com.electrotank.electroserver4.message.*;
    import com.electrotank.electroserver4.room.*;
    import com.electrotank.electroserver4.errors.*;
    
    public class GenericErrorResponse extends ResponseImpl {

        private var requestMessageType:MessageType;
        private var errorType:EsError;
        private var esObject:EsObject;
        private var hasEsObject:Boolean;
        public function GenericErrorResponse() {
            setMessageType(MessageType.GenericErrorResponse);
            hasEsObject = false;
        }
        public function setEsObject(esObject:EsObject):void {

            this.esObject = esObject;
            hasEsObject = true;
        }
        public function getEsObject():EsObject {
            return esObject;
        }
        public function setRequestMessageType(mt:MessageType):void {

            requestMessageType = mt;
        }
        public function getRequestMessageType():MessageType {
            return requestMessageType;
        }
        public function setErrorType(et:EsError):void {

            errorType = et;
        }
        public function getErrorType():EsError {
            return errorType;
        }
    }
}
