package com.electrotank.electroserver4.transaction {
    import com.electrotank.electroserver4.transaction.*;
    import com.electrotank.electroserver4.message.Message;
    import com.electrotank.electroserver4.message.event.*;
    import com.electrotank.electroserver4.ElectroServer;
    import com.electrotank.electroserver4.zone.*;
    import com.electrotank.electroserver4.room.*;
    import com.electrotank.electroserver4.entities.*;
    
    public class RoomVariableUpdateEventTransaction extends TransactionImpl {

        override public function execute(mess:Message, es:ElectroServer):void {

            var message:RoomVariableUpdateEvent = RoomVariableUpdateEvent(mess);
            var room:Room = es.getZoneManager().getZoneById(message.getZoneId()).getRoomById(message.getRoomId());
            var variable:RoomVariable;
            var type:String;
            var actionId:Number = message.getUpdateAction();
            if (actionId == RoomVariableUpdateEvent.VariableCreated) {
                type = "created";
            } else if (actionId == RoomVariableUpdateEvent.VariableUpdated) {
                type = "updated";
            } else if (actionId == RoomVariableUpdateEvent.VariableDeleted) {
                type = "deleted";
            }
            if (actionId == RoomVariableUpdateEvent.VariableCreated) {
                variable = new RoomVariable(message.getName(), message.getValue(), message.getPersistent(), message.getLocked());
                room.addRoomVariable(variable);
            }
            variable = room.getRoomVariable(message.getName());
            if (message.getValueChanged()) {
                variable.setValue(message.getValue());
            }
            if (message.getLockChanged()) {
                variable.setLocked(message.getLocked());
            }
            if (actionId == RoomVariableUpdateEvent.VariableDeleted) {
                room.removeRoomVariable(message.getName());
            }
            message.room = room;
            message.minorType = type;
            message.variable = variable;
            es.dispatchEvent(message);
            //es.notifyListeners("onRoomVariableUpdate", {target:es, room:room, type:type, variable:variable});
        }
    }
}
