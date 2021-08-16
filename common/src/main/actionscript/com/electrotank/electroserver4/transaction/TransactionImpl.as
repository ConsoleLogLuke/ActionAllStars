package com.electrotank.electroserver4.transaction {
    import com.electrotank.electroserver4.transaction.*;
    import com.electrotank.electroserver4.message.Message;
    import com.electrotank.electroserver4.ElectroServer;
    
    public class TransactionImpl implements Transaction {

        public function execute(mess:Message, es:ElectroServer):void {

            trace("Error: 'execute' method not overwritten in transaction for "+mess.getMessageType().getMessageTypeName());
        }
    }
}
