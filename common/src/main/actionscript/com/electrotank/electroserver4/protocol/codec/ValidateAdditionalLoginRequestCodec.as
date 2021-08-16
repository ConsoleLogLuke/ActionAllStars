package com.electrotank.electroserver4.protocol.codec {
    import com.electrotank.electroserver4.MessageConstants;
    import com.electrotank.electroserver4.protocol.codec.*;
    import com.electrotank.electroserver4.protocol.*;
    import com.electrotank.electroserver4.message.Message;
    import com.electrotank.electroserver4.message.request.*;
    import com.electrotank.electroserver4.entities.*;
    import com.electrotank.electroserver4.plugin.*;
    
    public class ValidateAdditionalLoginRequestCodec extends MessageCodecImpl {

        override public function encode(writer:MessageWriter, mess:Message):void {

            var request:ValidateAdditionalLoginRequest = ValidateAdditionalLoginRequest(mess);
            
        }
        
        override public function decode(msr:MessageReader):Message {
    
            var message:ValidateAdditionalLoginRequest = new ValidateAdditionalLoginRequest();
    
            message.setSecret(msr.nextPrefixedString(MessageConstants.SHARED_SECRET_LENGTH));
    
            return message;
    
        }
        
    }
}
