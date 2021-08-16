package com.electrotank.electroserver4.protocol.codec {
    import com.electrotank.electroserver4.MessageConstants;
    import com.electrotank.electroserver4.protocol.codec.*;
    import com.electrotank.electroserver4.protocol.*;
    import com.electrotank.electroserver4.message.Message;
    import com.electrotank.electroserver4.message.event.*;
    import com.electrotank.electroserver4.message.response.*;
    import com.electrotank.electroserver4.message.request.*;
    import com.electrotank.electroserver4.entities.*;
    
    public class UpdateRoomDetailsEventCodec extends MessageCodecImpl {

        
        override public function decode(reader:MessageReader):Message {
            var message:UpdateRoomDetailsEvent = new UpdateRoomDetailsEvent();
            message.setZoneId(reader.nextInteger(MessageConstants.ZONE_ID_LENGTH));
            message.setRoomId(reader.nextInteger(MessageConstants.ROOM_ID_LENGTH));
    
            message.setRoomNameUpdate(reader.nextBoolean());
            if (message.isRoomNameUpdate()) {
                message.setRoomName(reader.nextPrefixedString(MessageConstants.ROOM_NAME_PREFIX_LENGTH));
            }
    
            message.setCapacityUpdate(reader.nextBoolean());
            if (message.isCapacityUpdate()) {
                message.setCapacity(reader.nextInteger(MessageConstants.ROOM_CAPACITY_LENGTH));
            }
    
            message.setDescriptionUpdate(reader.nextBoolean());
            if (message.isDescriptionUpdate()) {
                message.setDescription(reader.nextPrefixedString(MessageConstants.ROOM_DESCRIPTION_PREFIX_LENGTH));
            }
    
            message.setPasswordUpdate(reader.nextBoolean());
            /*if (message.isPasswordUpdate()) {
                message.setPassword(reader.nextPrefixedString(MessageConstants.ROOM_PASSWORD_PREFIX_LENGTH));
            }*/
    
            message.setHiddenUpdate(reader.nextBoolean());
            if (message.isHiddenUpdate()) {
                message.setHidden(reader.nextBoolean());
            }
            
            return message;
        }
    }
}
