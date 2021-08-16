package com.electrotank.electroserver4.protocol.codec {
    import com.electrotank.electroserver4.MessageConstants;
    import com.electrotank.electroserver4.protocol.codec.*;
    import com.electrotank.electroserver4.protocol.*;
    import com.electrotank.electroserver4.message.Message;
    import com.electrotank.electroserver4.message.request.*;
    import com.electrotank.electroserver4.entities.*;
    
    public class DeleteUserVariableRequestCodec extends MessageCodecImpl {

        override public function encode(writer:MessageWriter, mess:Message):void {

            var request:DeleteUserVariableRequest = DeleteUserVariableRequest(mess);
            writer.writePrefixedString(request.getName(), MessageConstants.VARIABLE_NAME_PREFIX_LENGTH);
        }
    }
}
