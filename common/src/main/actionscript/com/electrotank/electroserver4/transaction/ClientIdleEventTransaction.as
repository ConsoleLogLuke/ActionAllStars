package com.electrotank.electroserver4.transaction {
    import com.electrotank.electroserver4.transaction.*;
    import com.electrotank.electroserver4.message.Message;
    import com.electrotank.electroserver4.message.event.*;
    import com.electrotank.electroserver4.ElectroServer;
    import com.electrotank.electroserver4.zone.*;
    import com.electrotank.electroserver4.room.Room;
    
    public class ClientIdleEventTransaction extends TransactionImpl {

        override public function execute(mess:Message, es:ElectroServer):void {

            var message:ClientIdleEvent = ClientIdleEvent(mess);
            es.dispatchEvent(message);
        }
    }
}
