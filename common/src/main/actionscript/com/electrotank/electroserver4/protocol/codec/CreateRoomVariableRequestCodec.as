package com.electrotank.electroserver4.protocol.codec {
    import com.electrotank.electroserver4.MessageConstants;
    import com.electrotank.electroserver4.protocol.codec.*;
    import com.electrotank.electroserver4.protocol.*;
    import com.electrotank.electroserver4.message.Message;
    import com.electrotank.electroserver4.message.request.*;
    import com.electrotank.electroserver4.esobject.EsObject;
    
    public class CreateRoomVariableRequestCodec extends MessageCodecImpl {

        override public function encode(writer:MessageWriter, mess:Message):void {

            var requestMessage:CreateRoomVariableRequest = CreateRoomVariableRequest(mess);
            writer.writeInteger(requestMessage.getZoneId(), MessageConstants.ZONE_ID_LENGTH);
            writer.writeInteger(requestMessage.getRoomId(), MessageConstants.ROOM_ID_LENGTH);
            writer.writePrefixedString(requestMessage.getName(), MessageConstants.ROOM_VARIABLE_NAME_PREFIX_LENGTH);
            EsObjectCodec.encode(writer, requestMessage.getValue());
    
            writer.writeBoolean(requestMessage.getLocked());
            writer.writeBoolean(requestMessage.getPersistent());
        }
    }
}
