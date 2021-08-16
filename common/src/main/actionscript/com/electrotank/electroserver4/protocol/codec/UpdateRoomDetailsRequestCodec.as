package com.electrotank.electroserver4.protocol.codec {
    import com.electrotank.electroserver4.MessageConstants;
    import com.electrotank.electroserver4.protocol.codec.*;
    import com.electrotank.electroserver4.protocol.*;
    import com.electrotank.electroserver4.message.Message;
    import com.electrotank.electroserver4.message.request.*;
    import com.electrotank.electroserver4.entities.*;
    
    public class UpdateRoomDetailsRequestCodec extends MessageCodecImpl {

        
        override public function encode(writer:MessageWriter, mess:Message):void {

            var request:UpdateRoomDetailsRequest = UpdateRoomDetailsRequest(mess);
            writer.writeInteger(request.getZoneId(), MessageConstants.ZONE_ID_LENGTH);
            writer.writeInteger(request.getRoomId(), MessageConstants.ROOM_ID_LENGTH);
    
            writer.writeBoolean(request.isRoomNameUpdate());
            if (request.isRoomNameUpdate()) {
                writer.writePrefixedString(request.getRoomName(), MessageConstants.ROOM_NAME_PREFIX_LENGTH);
            }
    
            writer.writeBoolean(request.isCapacityUpdate());
            if (request.isCapacityUpdate()) {
                writer.writeInteger(request.getCapacity(), MessageConstants.ROOM_CAPACITY_LENGTH);
            }
    
            writer.writeBoolean(request.isDescriptionUpdate());
            if (request.isDescriptionUpdate()) {
                writer.writePrefixedString(request.getDescription(), MessageConstants.ROOM_DESCRIPTION_PREFIX_LENGTH);
            }
    
            writer.writeBoolean(request.isPasswordUpdate());
            if (request.isPasswordUpdate()) {
                writer.writePrefixedString(request.getPassword(), MessageConstants.ROOM_PASSWORD_PREFIX_LENGTH);
            }
    
            writer.writeBoolean(request.isHiddenUpdate());
            if (request.isHiddenUpdate()) {
                writer.writeBoolean(request.getHidden());
            }
        }
    }
}
