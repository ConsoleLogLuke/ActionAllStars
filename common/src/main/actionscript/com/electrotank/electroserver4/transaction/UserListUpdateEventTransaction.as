package com.electrotank.electroserver4.transaction {
    import com.electrotank.electroserver4.entities.UserVariable;
    import com.electrotank.electroserver4.transaction.*;
    import com.electrotank.electroserver4.message.Message;
    import com.electrotank.electroserver4.message.event.*;
    import com.electrotank.electroserver4.ElectroServer;
    import com.electrotank.electroserver4.room.*;
    import com.electrotank.electroserver4.zone.*;
    import com.electrotank.electroserver4.user.*;
    
    public class UserListUpdateEventTransaction extends TransactionImpl {

        override public function execute(mess:Message, es:ElectroServer):void {

            var message:UserListUpdateEvent = UserListUpdateEvent(mess);
            var actionId:Number = message.getActionId();
            var room:Room = es.getZoneManager().getZoneById(message.getZoneId()).getRoomById(message.getRoomId());
            var type:String;//this is for the AS1 downgrading support
            var user:User;
            var UM:UserManager = es.getUserManager();
            if (actionId == UserListUpdateEvent.AddUser) {
                user = new User();
                user.setUserId(message.getUserId());
                user.setUserName(message.getUserName());
                user.setUserVariables(message.getUserVariables());
                
                if (UM.doesUserExist(user.getUserId())) {
                    var uvs:Array = user.getUserVariables();
                    user = UM.getUserById(user.getUserId());
                    for (var j:Number=0;j<uvs.length;++j) {
                        var uv:UserVariable = uvs[j];
                        user.addUserVariable(uv);
                    }
                } else {
                    UM.addUser(user);
                }
                UM.addReference(user);
                room.addUser(user);
                
                
                
                type = "userjoined";
            } else if (actionId == UserListUpdateEvent.DeleteUser) {
                user = UM.getUserById(message.getUserId());
                room.removeUser(message.getUserId());
                UM.removeReference(user);
                type = "userleft";
            } else if (actionId == UserListUpdateEvent.UpdateUser) {
                user = UM.getUserById(message.getUserId());
                trace("TODO: UpdateUser not handled in UserListUpdateEventTransaction");
            } else if (actionId == UserListUpdateEvent.OperatorGranted) {
                user = UM.getUserById(message.getUserId());
                trace("TODO: OperatorGranted not handled in UserListUpdateEventTransaction");
            } else if (actionId == UserListUpdateEvent.OperatorRevoked) {
                user = UM.getUserById(message.getUserId());
                trace("TODO: OperatorRevoked not handled in UserListUpdateEventTransaction");
            } else if (actionId == UserListUpdateEvent.SendingVideoStream) {
                user = UM.getUserById(message.getUserId());
                user.setIsSendingVideo(true);
                user.setVideoStreamName(message.getVideoStreamName());
            } else if (actionId == UserListUpdateEvent.StoppingVideoStream) {
                user = UM.getUserById(message.getUserId());
                user.setIsSendingVideo(false);
            }
            message.setUserName(user.getUserName());
            message.setUser(user);
            message.user = user;
            message.minorType = type;
            message.room = room;
            es.dispatchEvent(message);
            //es.notifyListeners("onUserListUpdate", {target:es, room:room, actionId:actionId, type:type, user:user});
        }
    }
}
