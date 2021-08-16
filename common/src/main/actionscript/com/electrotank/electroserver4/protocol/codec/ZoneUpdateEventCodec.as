package com.electrotank.electroserver4.protocol.codec {
    import com.electrotank.electroserver4.MessageConstants;
    import com.electrotank.electroserver4.protocol.codec.*;
    import com.electrotank.electroserver4.protocol.*;
    import com.electrotank.electroserver4.message.Message;
    import com.electrotank.electroserver4.message.event.*;
    import com.electrotank.electroserver4.message.response.*;
    import com.electrotank.electroserver4.message.request.*;
    import com.electrotank.electroserver4.room.*;
    
    public class ZoneUpdateEventCodec extends MessageCodecImpl {

        override public function decode(reader:MessageReader):Message {
            var event:ZoneUpdateEvent = new ZoneUpdateEvent();
            var zoneId:Number = reader.nextInteger(MessageConstants.ZONE_ID_LENGTH);
            event.setZoneId(zoneId);
    
            // Get the action
            var actionId:Number = reader.nextShort(MessageConstants.UPDATE_ACTION_LENGTH);
            event.setActionId(actionId);
    
            // Get the room id
            var roomId:Number = reader.nextInteger(MessageConstants.ROOM_ID_LENGTH);
            event.setRoomId(roomId);
    
            // Read in the conditional fields
            if(actionId == ZoneUpdateEvent.AddRoom) {
                var entry:Room = new Room();
                entry.setZoneId(zoneId);
                entry.setRoomId(roomId);
                entry.setRoomName(reader.nextPrefixedString(MessageConstants.ROOM_NAME_PREFIX_LENGTH));
                entry.setUserCount(reader.nextInteger(MessageConstants.USER_COUNT_LENGTH));
                entry.setCapacity(reader.nextInteger(MessageConstants.ROOM_CAPACITY_LENGTH));
                entry.setHasPassword(reader.nextBoolean());
                entry.setDescription(reader.nextPrefixedString(MessageConstants.ROOM_DESCRIPTION_PREFIX_LENGTH));
                event.setRoom(entry);
            }
            if (actionId != ZoneUpdateEvent.DeleteRoom) {
                var roomCount:Number = reader.nextInteger(MessageConstants.ROOM_COUNT_LENGTH);
                event.setRoomCount(roomCount);
            }
            return event;
        }
    }
}
