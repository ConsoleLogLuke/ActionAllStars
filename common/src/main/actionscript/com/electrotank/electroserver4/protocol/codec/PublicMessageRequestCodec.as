package com.electrotank.electroserver4.protocol.codec {
    import com.electrotank.electroserver4.MessageConstants;
    import com.electrotank.electroserver4.protocol.codec.*;
    import com.electrotank.electroserver4.protocol.*;
    import com.electrotank.electroserver4.message.Message;
    import com.electrotank.electroserver4.message.request.*;
    import com.electrotank.electroserver4.esobject.EsObject;
    
    public class PublicMessageRequestCodec extends MessageCodecImpl {

        override public function encode(writer:MessageWriter, mess:Message):void {

            var request:PublicMessageRequest = PublicMessageRequest(mess);
            // Initialize the needed data
            writer.writeInteger(request.getZoneId(), MessageConstants.ZONE_ID_LENGTH);
            
            // write the room id
            writer.writeInteger(request.getRoomId(), MessageConstants.ROOM_ID_LENGTH);
            
            // write the message
            writer.writePrefixedString(request.getMessage(), MessageConstants.PUBLIC_MESSAGE_PREFIX_LENGTH);
            
            // Handle the esobject
            var esObject:EsObject = request.getEsObject();
            if(esObject == null) {
                writer.writeBoolean(false);
            } else {
                writer.writeBoolean(true);
                EsObjectCodec.encode(writer, esObject);
            }
        }
    }
}
