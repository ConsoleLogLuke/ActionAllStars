package com.electrotank.electroserver4.transaction {
    import com.electrotank.electroserver4.transaction.*;
    import com.electrotank.electroserver4.message.Message;
    import com.electrotank.electroserver4.message.response.*;
    import com.electrotank.electroserver4.ElectroServer;
    import com.electrotank.electroserver4.user.User;
    import com.electrotank.electroserver4.room.Room;
    import com.electrotank.electroserver4.zone.*;
    
    public class GenericErrorResponseTransaction extends TransactionImpl {

        override public function execute(mess:Message, es:ElectroServer):void {

            var message:GenericErrorResponse = GenericErrorResponse(mess);
            es.handleError(message);
            es.dispatchEvent(message);
            //es.notifyListeners("onError", {target:es, error:message, message:message.getErrorType().getDescription()});
        }
    }
}
