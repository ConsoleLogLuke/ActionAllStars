package com.electrotank.electroserver4.transaction {
    import com.electrotank.electroserver4.transaction.*;
    import com.electrotank.electroserver4.message.Message;
    import com.electrotank.electroserver4.message.event.*;
    import com.electrotank.electroserver4.message.request.*;
    import com.electrotank.electroserver4.message.response.*;
    import com.electrotank.electroserver4.zone.Zone;
    import com.electrotank.electroserver4.room.Room;
    import com.electrotank.electroserver4.ElectroServer;
    
    public class GetRoomsInZoneResponseTransaction extends TransactionImpl {

        override public function execute(mess:Message, es:ElectroServer):void {

            var message:GetRoomsInZoneResponse = GetRoomsInZoneResponse(mess);
            var zone:Zone = new Zone();
            if (message.getZoneId() != -1) {
                zone.setZoneId(message.getZoneId());
            } else {
                zone.setZoneName(message.getZoneName());
            }
            for (var i:Number=0;i<message.getRooms().length;++i) {
                var room:Room = message.getRooms()[i];
                room.setZone(zone);
            }
            es.dispatchEvent(message);
            //es.notifyListeners("onRoomsLoaded", {target:es, zoneId:message.getZoneId(), rooms:message.getRooms()});
        }
    }
}
