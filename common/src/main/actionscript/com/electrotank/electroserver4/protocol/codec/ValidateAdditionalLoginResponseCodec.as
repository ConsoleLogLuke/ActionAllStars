package com.electrotank.electroserver4.protocol.codec {
    import com.electrotank.electroserver4.MessageConstants;
    import com.electrotank.electroserver4.protocol.codec.*;
    import com.electrotank.electroserver4.protocol.*;
    import com.electrotank.electroserver4.message.Message;
    import com.electrotank.electroserver4.message.response.*;
    
    public class ValidateAdditionalLoginResponseCodec extends MessageCodecImpl {

        override public function encode(writer:MessageWriter, mess:Message):void {

            var response:ValidateAdditionalLoginResponse = ValidateAdditionalLoginResponse(mess);
            writer.writeBoolean(response.getApproved());
            writer.writePrefixedString(response.getSecret(), MessageConstants.SHARED_SECRET_LENGTH);
            
        }
    }
}
