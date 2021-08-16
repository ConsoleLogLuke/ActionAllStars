package com.electrotank.electroserver4.transaction {
    import com.electrotank.electroserver4.transaction.*;
    import com.electrotank.electroserver4.message.Message;
    import com.electrotank.electroserver4.message.event.*;
    import com.electrotank.electroserver4.ElectroServer;
    import com.electrotank.electroserver4.zone.*;
    import com.electrotank.electroserver4.room.*;
    
    public class JoinZoneEventTransaction extends TransactionImpl {

        override public function execute(mess:Message, es:ElectroServer):void {

            var message:JoinZoneEvent = JoinZoneEvent(mess);
            var zone:Zone = new Zone();
            zone.setZoneId(message.getZoneId());
            zone.setZoneName(message.getZoneName());
            for (var i:Number=0;i<message.getRooms().length;++i) {
                var room:Room = message.getRooms()[i];
                zone.addRoom(room);
            }
            es.getZoneManager().addZone(zone);
            message.zone = zone;
            es.dispatchEvent(message);
            //es.notifyListeners("onJoinZone", {target:es, success:true, zoneId:message.getZoneId()});
        }
    }
}
