package com.electrotank.electroserver4.message.event {
    import com.electrotank.electroserver4.message.MessageImpl;
    import com.electrotank.electroserver4.message.event.*;
    import com.electrotank.electroserver4.message.*;
    import com.electrotank.electroserver4.zone.*;
    
    public class ClientIdleEvent extends EventImpl {

        public function ClientIdleEvent() {
            setMessageType(MessageType.ClientIdleEvent);
        }
    }
}
