package com.electrotank.electroserver4.message.response {
    import com.electrotank.electroserver4.message.MessageImpl;
    import com.electrotank.electroserver4.message.response.*;
    import com.electrotank.electroserver4.message.*;
    
    public class GetUserCountResponse extends ResponseImpl {

        private var count:Number;
        public function GetUserCountResponse() {
            setMessageType(MessageType.GetUserCountResponse);
        }
        public function setCount(num:Number):void {

            count = num;
        }
        public function getCount():Number {
            return count;
        }
    }
}
