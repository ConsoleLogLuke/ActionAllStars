package com.electrotank.electroserver4.protocol.codec {
    import com.electrotank.electroserver4.MessageConstants;
    import com.electrotank.electroserver4.protocol.codec.*;
    import com.electrotank.electroserver4.protocol.*;
    import com.electrotank.electroserver4.message.Message;
    import com.electrotank.electroserver4.message.response.*;
    
    public class GetUsersInRoomResponseCodec extends MessageCodecImpl {

        override public function decode(reader:MessageReader):Message {
            var response:GetUsersInRoomResponse = new GetUsersInRoomResponse();
                var requestId:String = reader.nextInteger(MessageConstants.MESSAGE_ID_SIZE).toString();
            response.setZoneId(reader.nextInteger(MessageConstants.ZONE_ID_LENGTH));
            response.setRoomId(reader.nextInteger(MessageConstants.ROOM_ID_LENGTH));
            response.setUsers(UserListCodec.decode(reader));
            
            return response;
        }
    }
}
