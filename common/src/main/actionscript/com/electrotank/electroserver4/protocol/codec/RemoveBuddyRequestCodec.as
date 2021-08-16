package com.electrotank.electroserver4.protocol.codec {
    import com.electrotank.electroserver4.MessageConstants;
    import com.electrotank.electroserver4.protocol.codec.*;
    import com.electrotank.electroserver4.protocol.*;
    import com.electrotank.electroserver4.message.Message;
    import com.electrotank.electroserver4.message.request.*;
    
    public class RemoveBuddyRequestCodec extends MessageCodecImpl {

        override public function encode(writer:MessageWriter, mess:Message):void {

            var request:RemoveBuddyRequest = RemoveBuddyRequest(mess);
            writer.writePrefixedString(request.getBuddyName(), MessageConstants.USER_NAME_PREFIX_LENGTH);
        }
    }
}
