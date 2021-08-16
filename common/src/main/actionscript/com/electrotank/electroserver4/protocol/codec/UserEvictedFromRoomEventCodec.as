package com.electrotank.electroserver4.protocol.codec {
    import com.electrotank.electroserver4.MessageConstants;
    import com.electrotank.electroserver4.protocol.codec.*;
    import com.electrotank.electroserver4.protocol.*;
    import com.electrotank.electroserver4.message.Message;
    import com.electrotank.electroserver4.message.event.*;
    
    public class UserEvictedFromRoomEventCodec extends MessageCodecImpl {

        override public function decode(reader:MessageReader):Message {
            var message:UserEvictedFromRoomEvent = new UserEvictedFromRoomEvent();
            message.setZoneId(reader.nextInteger(MessageConstants.ZONE_ID_LENGTH));
            message.setRoomId(reader.nextInteger(MessageConstants.ROOM_ID_LENGTH));
            message.setUserId(reader.nextLong(MessageConstants.USER_ID_LENGTH));
            message.setReason(reader.nextPrefixedString(MessageConstants.ROOM_EVICTION_REASON_PREFIX_LENGTH));
            message.setBan(reader.nextBoolean());
            if (message.isBan()) {
                message.setDuration(reader.nextInteger(MessageConstants.ROOM_BAN_DURATION_LENGTH));
            }
            return message;
        }
    }
}
