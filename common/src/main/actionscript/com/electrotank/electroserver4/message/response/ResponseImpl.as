package com.electrotank.electroserver4.message.response {
    import com.electrotank.electroserver4.message.MessageImpl;
    import com.electrotank.electroserver4.message.response.*;
    
    public class ResponseImpl extends MessageImpl {

        private var requestId:Number;
        public function ResponseImpl() {
        }
        public function setRequestId(num:Number):void {

            requestId = num;
        }
        public function getRequestId():Number {
            return requestId;
        }
    }
}
