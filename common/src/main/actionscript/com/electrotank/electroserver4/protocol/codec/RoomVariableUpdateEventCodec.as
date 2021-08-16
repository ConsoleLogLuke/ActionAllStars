package com.electrotank.electroserver4.protocol.codec {
    import com.electrotank.electroserver4.MessageConstants;
    import com.electrotank.electroserver4.protocol.codec.*;
    import com.electrotank.electroserver4.protocol.*;
    import com.electrotank.electroserver4.message.Message;
    import com.electrotank.electroserver4.message.event.*;
    import com.electrotank.electroserver4.message.response.*;
    import com.electrotank.electroserver4.message.request.*;
    import com.electrotank.electroserver4.room.*;
    import com.electrotank.electroserver4.esobject.EsObject;
    
    public class RoomVariableUpdateEventCodec extends MessageCodecImpl {

        override public function decode(reader:MessageReader):Message {
            var eventMessage:RoomVariableUpdateEvent = new RoomVariableUpdateEvent();
    
    
            eventMessage.setZoneId(reader.nextInteger(MessageConstants.ZONE_ID_LENGTH));
            eventMessage.setRoomId(reader.nextInteger(MessageConstants.ROOM_ID_LENGTH));
            eventMessage.setUpdateAction(reader.nextShort(MessageConstants.UPDATE_ACTION_LENGTH));
            eventMessage.setName(reader.nextPrefixedString(MessageConstants.ROOM_VARIABLE_NAME_PREFIX_LENGTH));
    
            if (eventMessage.getUpdateAction() != RoomVariableUpdateEvent.VariableDeleted) {
                
                eventMessage.setValueChanged(reader.nextBoolean());
                if (eventMessage.getValueChanged()) {
                    eventMessage.setValue(EsObjectCodec.decode(reader));
                }
    
                eventMessage.setLockChanged(reader.nextBoolean());
                if (eventMessage.getLockChanged()) {
                    eventMessage.setLocked(reader.nextBoolean());
                }
                
                if (eventMessage.getUpdateAction() == RoomVariableUpdateEvent.VariableCreated) {
                    eventMessage.setPersistent(reader.nextBoolean());
                }
            }
            
            return eventMessage;
        }
    }
}
