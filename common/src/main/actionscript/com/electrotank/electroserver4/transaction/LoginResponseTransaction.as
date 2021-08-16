package com.electrotank.electroserver4.transaction {
    import com.electrotank.electroserver4.transaction.*;
    import com.electrotank.electroserver4.message.Message;
    import com.electrotank.electroserver4.message.event.*;
    import com.electrotank.electroserver4.message.request.*;
    import com.electrotank.electroserver4.message.response.*;
    import com.electrotank.electroserver4.ElectroServer;
    
    public class LoginResponseTransaction extends TransactionImpl {

        override public function execute(mess:Message, es:ElectroServer):void {

            var message:LoginResponse = LoginResponse(mess);
            es.handleLoginResponse(message);
            es.dispatchEvent(message);
        }
    }
}
