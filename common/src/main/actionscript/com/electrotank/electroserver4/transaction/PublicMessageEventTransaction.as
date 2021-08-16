package com.electrotank.electroserver4.transaction {
    import com.electrotank.electroserver4.transaction.*;
    import com.electrotank.electroserver4.message.Message;
    import com.electrotank.electroserver4.message.event.*;
    import com.electrotank.electroserver4.ElectroServer;
    import com.electrotank.electroserver4.user.*;
    import com.electrotank.electroserver4.room.Room;
    import com.electrotank.electroserver4.zone.*;
    
    public class PublicMessageEventTransaction extends TransactionImpl {

        override public function execute(mess:Message, es:ElectroServer):void {

            var message:PublicMessageEvent = PublicMessageEvent(mess);
            var room:Room = es.getZoneManager().getZoneById(message.getZoneId()).getRoomById(message.getRoomId());
            var UM:UserManager = es.getUserManager();
            var user:User;
            if (UM.doesUserExist(message.getUserId())) {
                user = UM.getUserById(message.getUserId());
                message.setUserName(user.getUserName());
            } else {
                user = new User();
                user.setUserId(message.getUserId());
                if (message.isUserNameIncluded()) {
                    user.setUserName(message.getUserName());
                }
            }
            message.user = user;
            message.room = room;
            es.dispatchEvent(message);
            //es.notifyListeners("onPublicMessage", {target:es, user:user, room:room, message:message.getMessage(), pairs:message.getPairs()});
        }
    }
}
