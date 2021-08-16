package com.electrotank.electroserver4.transaction {
    import com.electrotank.electroserver4.transaction.*;
    import com.electrotank.electroserver4.message.Message;
    import com.electrotank.electroserver4.message.event.*;
    import com.electrotank.electroserver4.ElectroServer;
    
    public class ConnectionEventTransaction extends TransactionImpl {

        override public function execute(mess:Message, es:ElectroServer):void {

            var message:ConnectionEvent = ConnectionEvent(mess);
            es.dispatchEvent(message);
            //es.notifyListeners("onConnection", {target:es, success:message.getAccepted()});
        }
    }
}
