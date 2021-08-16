package com.electrotank.electroserver4.message.event {
    import com.electrotank.electroserver4.message.MessageImpl;
    import com.electrotank.electroserver4.message.event.*;
    import com.electrotank.electroserver4.message.*;
    import com.electrotank.electroserver4.user.User;
    import com.electrotank.electroserver4.esobject.EsObject;
    
    public class RtmpConnectionEvent extends EventImpl {

        private var accepted:Boolean;
        public function RtmpConnectionEvent() {
            setMessageType(MessageType.RtmpConnectionEvent);
        }
        public function setAccepted(accepted:Boolean):void {

            this.accepted = accepted;
        }
        public function getAccepted():Boolean {
            return accepted;
        }
    }
}
