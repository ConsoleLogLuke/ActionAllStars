package com.electrotank.electroserver4.protocol.codec {
    import com.electrotank.electroserver4.protocol.codec.*;
    import com.electrotank.electroserver4.protocol.*;
    import com.electrotank.electroserver4.message.Message;
    
    public interface MessageCodec {

        function encode(writer:MessageWriter, message:Message):void;

        function decode(reader:MessageReader):Message;
    }
}
