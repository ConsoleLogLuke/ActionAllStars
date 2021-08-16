package com.electrotank.electroserver4.protocol.codec {
    import com.electrotank.electroserver4.protocol.codec.*;
    import com.electrotank.electroserver4.protocol.*;
    import com.electrotank.electroserver4.message.Message;
    
    public class MessageCodecImpl implements MessageCodec {

        public function encode(writer:MessageWriter, message:Message):void {

            trace("Error: 'encode' method not over-written in a codec for "+message.getMessageType().getMessageTypeName());
        }
        public function decode(reader:MessageReader):Message {
            trace("Error: 'decode' method not over-written in a codec for this message");
            var mess:Message;
            return mess;
        }
    }
}
