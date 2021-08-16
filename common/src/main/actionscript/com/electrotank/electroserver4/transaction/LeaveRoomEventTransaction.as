package com.electrotank.electroserver4.transaction {
    import com.electrotank.electroserver4.transaction.*;
    import com.electrotank.electroserver4.message.Message;
    import com.electrotank.electroserver4.message.event.*;
    import com.electrotank.electroserver4.ElectroServer;
    import com.electrotank.electroserver4.room.Room;
    import com.electrotank.electroserver4.zone.*;
    import com.electrotank.electroserver4.user.*;
    
    public class LeaveRoomEventTransaction extends TransactionImpl {

        override public function execute(mess:Message, es:ElectroServer):void {

            var message:LeaveRoomEvent = LeaveRoomEvent(mess);
            var zone:Zone = es.getZoneManager().getZoneById(message.getZoneId());
            var room:Room = zone.getRoomById(message.getRoomId());
            room.setIsJoined(false);
            zone.removeJoinedRoom(room);
            var UM:UserManager = es.getUserManager();
            for (var i:Number=0;i<room.getUsers().length;++i) {
                UM.removeReference(room.getUsers()[i]);
            }
            message.room = room;
            es.dispatchEvent(message);
            //es.notifyListeners("onRoomLeft", {target:es, room:room});
        }
    }
}
