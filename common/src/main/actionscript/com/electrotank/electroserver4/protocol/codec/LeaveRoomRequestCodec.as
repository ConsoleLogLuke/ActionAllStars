package com.electrotank.electroserver4.protocol.codec {
    import com.electrotank.electroserver4.MessageConstants;
    import com.electrotank.electroserver4.protocol.codec.*;
    import com.electrotank.electroserver4.protocol.*;
    import com.electrotank.electroserver4.message.Message;
    import com.electrotank.electroserver4.message.request.*;
    
    public class LeaveRoomRequestCodec extends MessageCodecImpl {

        override public function encode(writer:MessageWriter, mess:Message):void {

            var request:LeaveRoomRequest = LeaveRoomRequest(mess);
            // Write the zone id
            writer.writeInteger(request.getZoneId(), MessageConstants.ZONE_ID_LENGTH);
    
            // Write the room id
            writer.writeInteger(request.getRoomId(), MessageConstants.ROOM_ID_LENGTH);
        }
    }
}
