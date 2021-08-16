package com.electrotank.electroserver4.protocol.codec {
    import com.electrotank.electroserver4.MessageConstants;
    import com.electrotank.electroserver4.protocol.codec.*;
    import com.electrotank.electroserver4.protocol.*;
    import com.electrotank.electroserver4.message.Message;
    import com.electrotank.electroserver4.message.event.*;
    import com.electrotank.electroserver4.message.response.*;
    import com.electrotank.electroserver4.message.request.*;
    import com.electrotank.electroserver4.errors.*;
    
    public class ConnectionEventCodec extends MessageCodecImpl {

        override public function decode(msr:MessageReader):Message {
            var message:ConnectionEvent = new ConnectionEvent();
            var accepted:Boolean = msr.nextBoolean();
            message.setAccepted(accepted);
            if(message.getAccepted()) {
                message.setHashId(msr.nextInteger(MessageConstants.HASH_ID_LENGTH));
                message.setPrime(msr.nextString());
                message.setBase(msr.nextString());
            } else {
                var errorId:Number = msr.nextInteger(MessageConstants.ERROR_ID_LENGTH);
                message.setEsError(Errors.getErrorById(errorId));
            }
            return message;
        }
    }
}
