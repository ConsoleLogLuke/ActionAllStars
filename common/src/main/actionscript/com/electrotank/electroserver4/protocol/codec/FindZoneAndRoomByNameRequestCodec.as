package com.electrotank.electroserver4.protocol.codec {
    import com.electrotank.electroserver4.MessageConstants;
    import com.electrotank.electroserver4.protocol.codec.*;
    import com.electrotank.electroserver4.protocol.*;
    import com.electrotank.electroserver4.message.Message;
    import com.electrotank.electroserver4.message.request.*;
    
    public class FindZoneAndRoomByNameRequestCodec extends MessageCodecImpl {

        override public function encode(writer:MessageWriter, mess:Message):void {

            var request:FindZoneAndRoomByNameRequest = FindZoneAndRoomByNameRequest(mess);
            writer.writePrefixedString(request.getZoneName(), MessageConstants.ZONE_NAME_PREFIX_LENGTH);
            writer.writePrefixedString(request.getRoomName(), MessageConstants.ROOM_NAME_PREFIX_LENGTH);
        }
    }
}
