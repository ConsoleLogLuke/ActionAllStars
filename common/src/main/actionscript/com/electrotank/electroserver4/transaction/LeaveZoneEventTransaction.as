package com.electrotank.electroserver4.transaction {
    import com.electrotank.electroserver4.transaction.*;
    import com.electrotank.electroserver4.message.Message;
    import com.electrotank.electroserver4.message.event.*;
    import com.electrotank.electroserver4.ElectroServer;
    import com.electrotank.electroserver4.zone.Zone;
    
    public class LeaveZoneEventTransaction extends TransactionImpl {

        override public function execute(mess:Message, es:ElectroServer):void {

            var message:LeaveZoneEvent = LeaveZoneEvent(mess);
            var zone:Zone = es.getZoneManager().getZoneById(message.getZoneId());
            es.getZoneManager().removeZone(zone.getZoneId());
            message.zone = zone;
            es.dispatchEvent(message);
            //es.notifyListeners("onZoneLeft", {target:es, zone:zone});
        }
    }
}
