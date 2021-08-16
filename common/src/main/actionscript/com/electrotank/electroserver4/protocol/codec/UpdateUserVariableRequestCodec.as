package com.electrotank.electroserver4.protocol.codec {
    import com.electrotank.electroserver4.MessageConstants;
    import com.electrotank.electroserver4.protocol.codec.*;
    import com.electrotank.electroserver4.protocol.*;
    import com.electrotank.electroserver4.message.Message;
    import com.electrotank.electroserver4.message.request.*;
    import com.electrotank.electroserver4.entities.*;
    import com.electrotank.electroserver4.esobject.EsObject;
    
    public class UpdateUserVariableRequestCodec extends MessageCodecImpl {

        override public function encode(writer:MessageWriter, mess:Message):void {

            var request:UpdateUserVariableRequest = UpdateUserVariableRequest(mess);
            
            //writer.writeString(request.getName());
            writer.writePrefixedString(request.getName(), MessageConstants.USER_VARIABLE_NAME_PREFIX_LENGTH);
            EsObjectCodec.encode(writer, request.getValue());
        }
    }
}
