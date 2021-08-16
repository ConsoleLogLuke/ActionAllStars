package com.electrotank.electroserver4.transaction {
    import com.electrotank.electroserver4.transaction.*;
    import com.electrotank.electroserver4.message.Message;
    import com.electrotank.electroserver4.message.request.*;
    import com.electrotank.electroserver4.ElectroServer;
    import com.electrotank.electroserver4.zone.Zone;
    
    public class ValidateAdditionalLoginRequestTransaction extends TransactionImpl {

        override public function execute(mess:Message, es:ElectroServer):void {

            var message:ValidateAdditionalLoginRequest = ValidateAdditionalLoginRequest(mess);
            es.dispatchEvent(message);
        }
    }
}
