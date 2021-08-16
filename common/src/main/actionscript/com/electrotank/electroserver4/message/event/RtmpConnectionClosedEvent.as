package com.electrotank.electroserver4.message.event {
    import com.electrotank.electroserver4.message.MessageImpl;
    import com.electrotank.electroserver4.message.event.*;
    import com.electrotank.electroserver4.message.*;
    import com.electrotank.electroserver4.user.User;
    import com.electrotank.electroserver4.esobject.EsObject;
    
    public class RtmpConnectionClosedEvent extends EventImpl {

        private var accepted:Boolean;
        public function RtmpConnectionClosedEvent() {
            setMessageType(MessageType.RtmpConnectionClosedEvent);
        }
    }
}
