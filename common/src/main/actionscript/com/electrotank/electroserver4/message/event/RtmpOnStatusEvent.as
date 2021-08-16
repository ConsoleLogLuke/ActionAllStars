package com.electrotank.electroserver4.message.event {
    import com.electrotank.electroserver4.message.MessageImpl;
    import com.electrotank.electroserver4.message.event.*;
    import com.electrotank.electroserver4.message.*;
    import com.electrotank.electroserver4.user.User;
    import com.electrotank.electroserver4.esobject.EsObject;
    
    public class RtmpOnStatusEvent extends EventImpl {

        private var info:Object;
        public function RtmpOnStatusEvent() {
            setMessageType(MessageType.RtmpOnStatusEvent);
        }
        public function getInfo():Object {
            return info;
        }
        public function setInfo(info:Object):void {

            this.info = info;
        }
    }
}
