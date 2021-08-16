package com.electrotank.electroserver4.protocol.codec {
    import com.electrotank.electroserver4.MessageConstants;
    import com.electrotank.electroserver4.protocol.codec.*;
    import com.electrotank.electroserver4.protocol.*;
    import com.electrotank.electroserver4.message.Message;
    import com.electrotank.electroserver4.message.event.*;
    import com.electrotank.electroserver4.message.response.*;
    import com.electrotank.electroserver4.message.request.*;
    import com.electrotank.electroserver4.esobject.EsObject;
    
    public class PublicMessageEventCodec extends MessageCodecImpl {

        override public function decode(reader:MessageReader):Message {
            var message:PublicMessageEvent = new PublicMessageEvent();
            message.setZoneId(reader.nextInteger(MessageConstants.ZONE_ID_LENGTH));
            message.setRoomId(reader.nextInteger(MessageConstants.ROOM_ID_LENGTH));
            message.setUserId(reader.nextLong(MessageConstants.USER_ID_LENGTH));
            message.setUserNameIncluded(reader.nextBoolean());
            if (message.isUserNameIncluded()) {
                message.setUserName(reader.nextPrefixedString(MessageConstants.USER_NAME_PREFIX_LENGTH));
            }
            message.setMessage(reader.nextPrefixedString(MessageConstants.PUBLIC_MESSAGE_PREFIX_LENGTH));
            // Handle the name/value pairs
               var containsVariables:Boolean = reader.nextBoolean();
            if(containsVariables) {
                var esObject:EsObject = EsObjectCodec.decode(reader);
                message.setEsObject(esObject);
            }
            return message;
        }
    }
}
