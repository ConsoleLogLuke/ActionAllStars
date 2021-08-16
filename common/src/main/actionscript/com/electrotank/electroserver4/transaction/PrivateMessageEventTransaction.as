package com.electrotank.electroserver4.transaction {
    import com.electrotank.electroserver4.transaction.*;
    import com.electrotank.electroserver4.message.Message;
    import com.electrotank.electroserver4.message.event.*;
    import com.electrotank.electroserver4.ElectroServer;
    import com.electrotank.electroserver4.user.*;
    import com.electrotank.electroserver4.room.Room;
    import com.electrotank.electroserver4.zone.*;
    
    public class PrivateMessageEventTransaction extends TransactionImpl {

        override public function execute(mess:Message, es:ElectroServer):void {

            var message:PrivateMessageEvent = PrivateMessageEvent(mess);
            var UM:UserManager = es.getUserManager();
            var user:User = new User();
            user.setUserId(message.getUserId());
            user.setUserName(message.getUserName());
            if (UM.doesUserExist(user.getUserId())) {
                user = UM.getUserById(user.getUserId());
            }
            message.user = user;
            es.dispatchEvent(message);
            //es.notifyListeners("onPrivateMessage", {target:es, user:user, message:message.getMessage(), pairs:message.getPairs()});
        }
    }
}
