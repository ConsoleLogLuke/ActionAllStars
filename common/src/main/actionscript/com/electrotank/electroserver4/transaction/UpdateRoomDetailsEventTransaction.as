package com.electrotank.electroserver4.transaction {
    import com.electrotank.electroserver4.transaction.*;
    import com.electrotank.electroserver4.message.Message;
    import com.electrotank.electroserver4.message.event.*;
    import com.electrotank.electroserver4.ElectroServer;
    import com.electrotank.electroserver4.room.*;
    import com.electrotank.electroserver4.zone.*;
    import com.electrotank.electroserver4.user.*;
    
    public class UpdateRoomDetailsEventTransaction extends TransactionImpl {

        override public function execute(mess:Message, es:ElectroServer):void {

            var message:UpdateRoomDetailsEvent = UpdateRoomDetailsEvent(mess);
            var room:Room = es.getZoneManager().getZoneById(message.getZoneId()).getRoomById(message.getRoomId());
            if (message.isHiddenUpdate()) {
                room.setIsHidden(message.getHidden());
            }
            if (message.isDescriptionUpdate()) {
                room.setDescription(message.getDescription());
            }
            if (message.isCapacityUpdate()) {
                room.setCapacity(message.getCapacity());
            }
            if (message.isRoomNameUpdate()) {
                room.setRoomName(message.getRoomName());
            }
            if (message.isPasswordUpdate()) {
                //do nothing
            }
            message.room = room;
            es.dispatchEvent(message);
            //es.notifyListeners("onRoomDetailsUpdate", {target:es, room:room, message:message});
        }
    }
}
