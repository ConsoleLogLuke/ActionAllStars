package com.electrotank.electroserver4.protocol.codec {
    import com.electrotank.electroserver4.MessageConstants;
    import com.electrotank.electroserver4.protocol.codec.*;
    import com.electrotank.electroserver4.protocol.*;
    import com.electrotank.electroserver4.message.Message;
    import com.electrotank.electroserver4.message.request.*;
    import com.electrotank.electroserver4.esobject.EsObject;
    
    public class PrivateMessageRequestCodec extends MessageCodecImpl {

        override public function encode(writer:MessageWriter, mess:Message):void {

            var privateMessage:PrivateMessageRequest = PrivateMessageRequest(mess);
            // write out the list of users who will receive the message
            var users:Array = privateMessage.getUsers();
            writer.writeInteger(users.length, MessageConstants.USER_COUNT_LENGTH);
            var i:Number;
            for (i=0;i<users.length;++i) {
                writer.writeLong(users[i].getUserId(), MessageConstants.USER_ID_LENGTH);
            }
            
            var userNames:Array = privateMessage.getUserNames();
            writer.writeInteger(userNames.length, MessageConstants.USER_COUNT_LENGTH);
            for (i=0;i<userNames.length;++i) {
                var userName:String = userNames[i];
                writer.writePrefixedString(userName, MessageConstants.USER_NAME_PREFIX_LENGTH);
            }
            
            
            
            // write out the message
            writer.writePrefixedString(privateMessage.getMessage(), MessageConstants.PRIVATE_MESSAGE_PREFIX_LENGTH);
            
            // Handle the esobject
            var esObject:EsObject = privateMessage.getEsObject();
            if(esObject == null) {
                writer.writeBoolean(false);
            } else {
                writer.writeBoolean(true);
                EsObjectCodec.encode(writer, esObject);
            }
        }
    }
}
