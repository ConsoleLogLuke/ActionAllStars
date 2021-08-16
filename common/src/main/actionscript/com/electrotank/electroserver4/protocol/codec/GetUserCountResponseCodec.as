package com.electrotank.electroserver4.protocol.codec {
    import com.electrotank.electroserver4.MessageConstants;
    import com.electrotank.electroserver4.protocol.codec.*;
    import com.electrotank.electroserver4.protocol.*;
    import com.electrotank.electroserver4.message.Message;
    import com.electrotank.electroserver4.message.response.*;
    
    public class GetUserCountResponseCodec extends MessageCodecImpl {

        override public function decode(reader:MessageReader):Message {
            var response:GetUserCountResponse = new GetUserCountResponse();
                var requestId:String = reader.nextInteger(MessageConstants.MESSAGE_ID_SIZE).toString();
            
            response.setCount(reader.nextInteger(MessageConstants.FULL_USER_COUNT_LENGTH));
            return response;
        }
    }
}
