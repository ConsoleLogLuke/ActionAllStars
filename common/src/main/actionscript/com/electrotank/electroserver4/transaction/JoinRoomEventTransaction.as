package com.electrotank.electroserver4.transaction {
    import com.electrotank.electroserver4.entities.UserVariable;
    import com.electrotank.electroserver4.transaction.*;
    import com.electrotank.electroserver4.message.Message;
    import com.electrotank.electroserver4.message.event.*;
    import com.electrotank.electroserver4.ElectroServer;
    import com.electrotank.electroserver4.zone.*;
    import com.electrotank.electroserver4.room.*;
    import com.electrotank.electroserver4.user.*;
    
    public class JoinRoomEventTransaction extends TransactionImpl {

        override public function execute(mess:Message, es:ElectroServer):void {

            var message:JoinRoomEvent = JoinRoomEvent(mess);
            var zone:Zone = es.getZoneManager().getZoneById(message.getZoneId());
            var room:Room;
            if (zone.doesRoomExist(message.getRoomId())) {
                room = zone.getRoomById(message.getRoomId());
            } else {
                room = new Room();
                room.setZoneId(message.getZoneId());
                room.setRoomId(message.getRoomId());
                room.setRoomName(message.getRoomName());
                room.setCapacity(message.getCapacity());
                room.setHasPassword(message.getHasPassword());
                room.setDescription(message.getRoomDescription());
                room.setUserCount(message.getUsers().length);
                zone.addRoom(room);
            }
            room.setIsJoined(true);
            zone.addJoinedRoom(room);
            room.setZone(es.getZoneManager().getZoneById(message.getZoneId()));
            message.room = room;
            message.setZoneName(zone.getZoneName());
            var UM:UserManager = es.getUserManager();
            for (var i:Number=0;i<message.getUsers().length;++i) {
                var user:User = message.getUsers()[i];
                
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
            }
            room.setRoomVariables(message.getRoomVariables());
            es.dispatchEvent(message);
            //es.notifyListeners("onJoinRoom", {target:es, room:room});
            //es.notifyListeners("onRoomVariableUpdate", {target:es, room:room, type:"all"});
        }
    }
}
