package com.electrotank.electroserver4.protocol.codec {
    import com.electrotank.electroserver4.MessageConstants;
    import com.electrotank.electroserver4.protocol.codec.*;
    import com.electrotank.electroserver4.protocol.*;
    import com.electrotank.electroserver4.message.Message;
    import com.electrotank.electroserver4.message.request.*;
    import com.electrotank.electroserver4.esobject.EsObject;
    
    public class AddBuddyRequestCodec extends MessageCodecImpl {

        override public function encode(writer:MessageWriter, mess:Message):void {

            var request:AddBuddyRequest = AddBuddyRequest(mess);
            writer.writePrefixedString(request.getBuddyName(), MessageConstants.USER_NAME_PREFIX_LENGTH);
            // Handle the associated esobject, if there is one
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
