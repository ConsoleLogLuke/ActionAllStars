package com.electrotank.electroserver4.protocol.codec {
    import com.electrotank.electroserver4.esobject.EsObject;
    import com.electrotank.electroserver4.MessageConstants;
    import com.electrotank.electroserver4.protocol.codec.*;
    import com.electrotank.electroserver4.protocol.*;
    import com.electrotank.electroserver4.message.*;
    import com.electrotank.electroserver4.message.event.*;
    import com.electrotank.electroserver4.message.response.*;
    import com.electrotank.electroserver4.message.request.*;
    import com.electrotank.electroserver4.room.Room;
    import com.electrotank.electroserver4.errors.*;
    
    public class GenericErrorResponseCodec extends MessageCodecImpl {

        override public function decode(reader:MessageReader):Message {
            var response:GenericErrorResponse = new GenericErrorResponse();
                var requestId:String = reader.nextInteger(MessageConstants.MESSAGE_ID_SIZE).toString();
            var requestTypeIndicator:String = reader.nextCharacter();
    
            // Get the error id
            var id:Number = reader.nextInteger(MessageConstants.ERROR_ID_LENGTH);
            // Find the request and error type
            var messageType:MessageType = MessageType.findTypeById(requestTypeIndicator);
            var errorType:EsError = Errors.getErrorById(id);
    
            // Set it
            response.setRequestMessageType(messageType);
            response.setErrorType(errorType);
    
            // Handle the esobject
            var containsVariables:Boolean = reader.nextBoolean();
            if(containsVariables) {
                var esObject:EsObject = EsObjectCodec.decode(reader);
                response.setEsObject(esObject);
            }
            
            return response;
        }
    }
}
