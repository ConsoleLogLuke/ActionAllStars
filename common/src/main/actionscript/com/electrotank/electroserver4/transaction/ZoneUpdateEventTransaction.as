package com.electrotank.electroserver4.transaction {
    import com.electrotank.electroserver4.transaction.*;
    import com.electrotank.electroserver4.message.Message;
    import com.electrotank.electroserver4.message.event.*;
    import com.electrotank.electroserver4.ElectroServer;
    import com.electrotank.electroserver4.zone.*;
    import com.electrotank.electroserver4.room.Room;
    
    public class ZoneUpdateEventTransaction extends TransactionImpl {

        override public function execute(mess:Message, es:ElectroServer):void {

            var message:ZoneUpdateEvent = ZoneUpdateEvent(mess);
            var actionId:Number = message.getActionId();
            var type:String;//for AS1 api downgrading
            var room:Room;
            if (actionId == ZoneUpdateEvent.AddRoom) {
                room = message.getRoom();
                room.setZone(es.getZoneManager().getZoneById(message.getZoneId()));
                es.getZoneManager().getZoneById(message.getZoneId()).addRoom(room);
                type = "roomcreated";
            } else if (actionId == ZoneUpdateEvent.DeleteRoom) {
                room = es.getZoneManager().getZoneById(message.getZoneId()).getRoomById(message.getRoomId());
                es.getZoneManager().getZoneById(message.getZoneId()).removeRoom(message.getRoomId());
                type = "roomdeleted";
            } else if (actionId == ZoneUpdateEvent.UpdateRoom) {
                room = es.getZoneManager().getZoneById(message.getZoneId()).getRoomById(message.getRoomId());
                es.getZoneManager().getZoneById(message.getZoneId()).getRoomById(message.getRoomId()).setUserCount(message.getRoomCount());
                type = "roomupdated";
            }
            var zone:Zone = es.getZoneManager().getZoneById(message.getZoneId());
            message.room = room;
            message.zone = zone;
            message.minorType = type;
            es.dispatchEvent(message);
            //es.notifyListeners("onZoneUpdate", {target:es, actionId:actionId, room:room, zone:zone, type:type});
        }
    }
}
