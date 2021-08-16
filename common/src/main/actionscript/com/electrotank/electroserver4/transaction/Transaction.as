package com.electrotank.electroserver4.transaction {
    import com.electrotank.electroserver4.transaction.*;
    import com.electrotank.electroserver4.message.Message;
    import com.electrotank.electroserver4.ElectroServer;
    
    public interface Transaction {

        function execute(mess:Message, es:ElectroServer):void;

    }
}
