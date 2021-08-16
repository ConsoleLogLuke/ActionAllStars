package com.electrotank.electroserver4.protocol.codec {
    import com.electrotank.electroserver4.MessageConstants;
    import com.electrotank.electroserver4.protocol.codec.*;
    import com.electrotank.electroserver4.protocol.*;
    import com.electrotank.electroserver4.message.Message;
    import com.electrotank.electroserver4.message.event.*;
    import com.electrotank.electroserver4.message.response.*;
    import com.electrotank.electroserver4.message.request.*;
    import com.electrotank.electroserver4.room.Room;
    
    public class JoinZoneEventCodec extends MessageCodecImpl {

        override public function decode(reader:MessageReader):Message {
            var message:JoinZoneEvent = new JoinZoneEvent();
            message.setZoneId(reader.nextInteger(MessageConstants.ZONE_ID_LENGTH));
            message.setZoneName(reader.nextPrefixedString(MessageConstants.ZONE_NAME_PREFIX_LENGTH));
            var cnt:Number = reader.nextInteger(MessageConstants.ROOM_COUNT_LENGTH);
            var entries:Array = new Array();
            for (var i:Number = 0; i < cnt; i++) {
                var entry:Room = new Room();
                entry.setZoneId(reader.nextInteger(MessageConstants.ZONE_ID_LENGTH));
                entry.setRoomId(reader.nextInteger(MessageConstants.ROOM_ID_LENGTH));
                entry.setRoomName(reader.nextPrefixedString(MessageConstants.ROOM_NAME_PREFIX_LENGTH));
                entry.setUserCount(reader.nextInteger(MessageConstants.USER_COUNT_LENGTH));
                entry.setCapacity(reader.nextInteger(MessageConstants.ROOM_CAPACITY_LENGTH));
                entry.setHasPassword(reader.nextBoolean());
                entry.setDescription(reader.nextPrefixedString(MessageConstants.ROOM_DESCRIPTION_PREFIX_LENGTH));
                entries.push(entry);
            }
            
            message.setRooms(entries);
            
            return message;
        }
    }
}
