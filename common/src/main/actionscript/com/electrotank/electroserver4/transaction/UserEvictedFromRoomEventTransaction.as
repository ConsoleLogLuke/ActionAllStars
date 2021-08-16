package com.electrotank.electroserver4.transaction {
    import com.electrotank.electroserver4.transaction.*;
    import com.electrotank.electroserver4.message.Message;
    import com.electrotank.electroserver4.message.event.*;
    import com.electrotank.electroserver4.ElectroServer;
    import com.electrotank.electroserver4.user.*;
    import com.electrotank.electroserver4.room.*;
    import com.electrotank.electroserver4.zone.*;
    
    public class UserEvictedFromRoomEventTransaction extends TransactionImpl {

        override public function execute(mess:Message, es:ElectroServer):void {

            var message:UserEvictedFromRoomEvent = UserEvictedFromRoomEvent(mess);
            var UM:UserManager = es.getUserManager();
            var user:User = UM.getUserById(message.getUserId());
            message.user = user;
            es.dispatchEvent(message);
            //es.notifyListeners("onUserKicked", {target:es, user:user, reason:reason});
        }
    }
}
