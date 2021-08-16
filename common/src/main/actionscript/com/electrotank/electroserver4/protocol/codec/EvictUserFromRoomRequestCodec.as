package com.electrotank.electroserver4.protocol.codec {
    import com.electrotank.electroserver4.MessageConstants;
    import com.electrotank.electroserver4.protocol.codec.*;
    import com.electrotank.electroserver4.protocol.*;
    import com.electrotank.electroserver4.message.Message;
    import com.electrotank.electroserver4.message.request.*;
    
    public class EvictUserFromRoomRequestCodec extends MessageCodecImpl {

        override public function encode(writer:MessageWriter, mess:Message):void {

            var request:EvictUserFromRoomRequest = EvictUserFromRoomRequest(mess);
            writer.writeInteger(request.getZoneId(), MessageConstants.ZONE_ID_LENGTH);
            writer.writeInteger(request.getRoomId(), MessageConstants.ROOM_ID_LENGTH);
            writer.writeLong(request.getUserId(), MessageConstants.USER_ID_LENGTH);
            writer.writePrefixedString(request.getReason(), MessageConstants.ROOM_EVICTION_REASON_PREFIX_LENGTH);
            writer.writeBoolean(request.isBan());
            if (request.isBan()) {
                writer.writeInteger(request.getDuration(), MessageConstants.ROOM_BAN_DURATION_LENGTH);
            }
        }
    }
}
