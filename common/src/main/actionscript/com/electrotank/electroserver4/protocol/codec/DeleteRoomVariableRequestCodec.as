package com.electrotank.electroserver4.protocol.codec {
    import com.electrotank.electroserver4.MessageConstants;
    import com.electrotank.electroserver4.protocol.codec.*;
    import com.electrotank.electroserver4.protocol.*;
    import com.electrotank.electroserver4.message.Message;
    import com.electrotank.electroserver4.message.request.*;
    
    public class DeleteRoomVariableRequestCodec extends MessageCodecImpl {

        override public function encode(writer:MessageWriter, mess:Message):void {

            var requestMessage:DeleteRoomVariableRequest = DeleteRoomVariableRequest(mess);
            writer.writeInteger(requestMessage.getZoneId(), MessageConstants.ZONE_ID_LENGTH);
            writer.writeInteger(requestMessage.getRoomId(), MessageConstants.ROOM_ID_LENGTH);
            writer.writePrefixedString(requestMessage.getName(), MessageConstants.ROOM_VARIABLE_NAME_PREFIX_LENGTH);
        }
    }
}
