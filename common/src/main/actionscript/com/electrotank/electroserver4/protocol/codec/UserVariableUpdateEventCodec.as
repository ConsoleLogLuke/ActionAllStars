package com.electrotank.electroserver4.protocol.codec {
    import com.electrotank.electroserver4.MessageConstants;
    import com.electrotank.electroserver4.protocol.codec.*;
    import com.electrotank.electroserver4.protocol.*;
    import com.electrotank.electroserver4.message.Message;
    import com.electrotank.electroserver4.message.event.*;
    import com.electrotank.electroserver4.message.response.*;
    import com.electrotank.electroserver4.message.request.*;
    import com.electrotank.electroserver4.room.*;
    import com.electrotank.electroserver4.esobject.EsObject;
    import com.electrotank.electroserver4.entities.UserVariable;
    
    public class UserVariableUpdateEventCodec extends MessageCodecImpl {

        override public function decode(reader:MessageReader):Message {
            var message:UserVariableUpdateEvent = new UserVariableUpdateEvent();
    
            
            message.setUserId(reader.nextLong(MessageConstants.USER_ID_LENGTH));
            var actionId:Number = reader.nextShort(MessageConstants.UPDATE_ACTION_LENGTH);
            //UserVariableUpdateEvent
            message.setActionId(actionId);
            
            //var name:String = reader.nextString();
            var name:String = reader.nextPrefixedString(MessageConstants.USER_VARIABLE_NAME_PREFIX_LENGTH);
            message.setVariableName(name);
            
            if(message.getActionId() != UserVariableUpdateEvent.VariableDeleted) {
                var value:EsObject = EsObjectCodec.decode(reader);
                
                message.setVariable(new UserVariable(name, value));
            }
            
            
            return message;
        }
    }
}
