package com.electrotank.electroserver4.transaction {
    import com.electrotank.electroserver4.transaction.*;
    import com.electrotank.electroserver4.message.Message;
    import com.electrotank.electroserver4.message.response.*;
    import com.electrotank.electroserver4.ElectroServer;
    import com.electrotank.electroserver4.zone.Zone;
    
    public class FindZoneAndRoomByNameResponseTransaction extends TransactionImpl {

        override public function execute(mess:Message, es:ElectroServer):void {

            var message:FindZoneAndRoomByNameResponse = FindZoneAndRoomByNameResponse(mess);
            es.dispatchEvent(message);
            //es.notifyListeners("onZoneAndRoomsByNameLoaded", {target:es, list:message.getRoomAndZoneList()});
        }
    }
}
