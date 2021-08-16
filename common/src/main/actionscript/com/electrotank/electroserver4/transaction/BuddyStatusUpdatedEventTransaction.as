package com.electrotank.electroserver4.transaction {
    import com.electrotank.electroserver4.transaction.*;
    import com.electrotank.electroserver4.message.Message;
    import com.electrotank.electroserver4.message.event.*;
    import com.electrotank.electroserver4.ElectroServer;
    import com.electrotank.electroserver4.user.*;
    import com.electrotank.electroserver4.room.*;
    import com.electrotank.electroserver4.zone.*;
    
    public class BuddyStatusUpdatedEventTransaction extends TransactionImpl {

        override public function execute(mess:Message, es:ElectroServer):void {

            var message:BuddyStatusUpdatedEvent = BuddyStatusUpdatedEvent(mess);
            var UM:UserManager = es.getUserManager();
            var user:User = new User();
            user.setUserId(message.getUserId());
            user.setUserName(message.getUserName());
            if (UM.doesUserExist(user.getUserId())) {
                user = UM.getUserById(user.getUserId());
            } else {
                UM.addUser(user);
            }
            var type:String;
            if (message.getActionId() == BuddyStatusUpdatedEvent.LoggedIn) {
                UM.addReference(user);
                type = "loggedIn";
            } else if (message.getActionId() == BuddyStatusUpdatedEvent.LoggedOut) {
                UM.removeReference(user);
                type = "loggedOut";
            }
            message.setUser(user);
            es.dispatchEvent(message);
            //es.notifyListeners("onBuddyStatusUpdate", {target:es, user:user, type:type});
        }
    }
}
