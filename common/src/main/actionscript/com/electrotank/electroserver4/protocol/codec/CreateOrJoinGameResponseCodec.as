package com.electrotank.electroserver4.protocol.codec {
    import com.electrotank.electroserver4.MessageConstants;
    import com.electrotank.electroserver4.protocol.codec.*;
    import com.electrotank.electroserver4.protocol.*;
    import com.electrotank.electroserver4.message.Message;
    import com.electrotank.electroserver4.message.response.*;
    import com.electrotank.electroserver4.errors.Errors;
    
    public class CreateOrJoinGameResponseCodec extends MessageCodecImpl {

        override public function decode(reader:MessageReader):Message {
                var requestId:String = reader.nextInteger(MessageConstants.MESSAGE_ID_SIZE).toString();
            
            var response:CreateOrJoinGameResponse = new CreateOrJoinGameResponse();
            
    
            response.setSuccessful(reader.nextBoolean());
            
            if(response.getSuccessful()) {
                response.setGameId(reader.nextInteger());
                response.setZoneId(reader.nextInteger());
                response.setRoomId(reader.nextInteger());
                response.setGameDetails(EsObjectCodec.decode(reader));
            } else {
                response.setEsError(Errors.getErrorById(reader.nextInteger()));
            }
            
            return response;
        }
    
    }
}
