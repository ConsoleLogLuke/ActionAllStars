package com.electrotank.electroserver4.protocol.codec {
    import com.electrotank.electroserver4.MessageConstants;
    import com.electrotank.electroserver4.protocol.codec.*;
    import com.electrotank.electroserver4.protocol.*;
    import com.electrotank.electroserver4.message.Message;
    import com.electrotank.electroserver4.message.event.*;
    import com.electrotank.electroserver4.message.response.*;
    import com.electrotank.electroserver4.message.request.*;
    import com.electrotank.electroserver4.esobject.EsObject;
    
    public class PrivateMessageEventCodec extends MessageCodecImpl {

        override public function decode(reader:MessageReader):Message {
            var event:PrivateMessageEvent = new PrivateMessageEvent();
            event.setUserId(reader.nextLong(MessageConstants.USER_ID_LENGTH));
            event.setUserName(reader.nextPrefixedString(MessageConstants.USER_NAME_PREFIX_LENGTH));
            event.setMessage(reader.nextPrefixedString(MessageConstants.PRIVATE_MESSAGE_PREFIX_LENGTH));
            // Handle the name/value pairs
               var containsVariables:Boolean = reader.nextBoolean();
            if(containsVariables) {
                var esObject:EsObject = EsObjectCodec.decode(reader);
                event.setEsObject(esObject);
            }
            return event;
        }
    }
}
