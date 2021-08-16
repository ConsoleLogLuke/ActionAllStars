package com.electrotank.electroserver4.protocol.codec {
    import com.electrotank.electroserver4.entities.UserVariable;
    import com.electrotank.electroserver4.MessageConstants;
    import com.electrotank.electroserver4.protocol.codec.*;
    import com.electrotank.electroserver4.protocol.*;
    import com.electrotank.electroserver4.message.Message;
    import com.electrotank.electroserver4.message.event.*;
    import com.electrotank.electroserver4.message.response.*;
    import com.electrotank.electroserver4.message.request.*;
    import com.electrotank.electroserver4.errors.*;
    import com.electrotank.electroserver4.esobject.EsObject;
    
    public class LoginResponseCodec extends MessageCodecImpl {

        override public function decode(msr:MessageReader):Message {
            var message:LoginResponse = new LoginResponse();
                var requestId:String = msr.nextInteger(MessageConstants.MESSAGE_ID_SIZE).toString();
            
            var accepted:Boolean = msr.nextBoolean();
            message.setAccepted(accepted);
            if (!message.getAccepted()) {
                var errorId:Number = msr.nextInteger(MessageConstants.ERROR_ID_LENGTH);
                message.setEsError(Errors.getErrorById(errorId));
            }
            // Handle the esobjects
            var containsVariables:Boolean = msr.nextBoolean();
            if(containsVariables) {
                
                var esObject:EsObject = EsObjectCodec.decode(msr);
                message.setEsObject(esObject);
            }
            
            // Handle the username
            var containsUserName:Boolean = msr.nextBoolean();
            if(containsUserName) {
                message.setUserName(msr.nextPrefixedString(MessageConstants.USER_NAME_PREFIX_LENGTH));
            }
            
            // Handle the user ID
            var containsUserId:Boolean = msr.nextBoolean();
            if(containsUserId) {
                message.setUserId(msr.nextLong(MessageConstants.USER_ID_LENGTH));
            }
            
            // Handle the user variables
            var variableCnt:Number = msr.nextInteger(MessageConstants.VARIABLE_COUNT_LENGTH);
            var userVariables:Array = new Array();
            var i:Number;
            var name:String;
            var value:EsObject;
            for (i = 0; i < variableCnt; i++) {
                name = msr.nextPrefixedString(MessageConstants.VARIABLE_NAME_PREFIX_LENGTH);
                value = EsObjectCodec.decode(msr);
                var uv:UserVariable = new UserVariable(name, value);
                userVariables.push(uv);
            }
            message.setUserVariables(userVariables);
            
            
            // Handle the buddy list entries
            var entryCnt:Number = msr.nextInteger(MessageConstants.VARIABLE_COUNT_LENGTH);
            var buddies:Object = new Object();
            for (i = 0; i < entryCnt; i++) {
                name = msr.nextPrefixedString(MessageConstants.USER_NAME_PREFIX_LENGTH);
                value = EsObjectCodec.decode(msr);
                buddies[name] = value;
            }
            message.setBuddies(buddies);
            
    
            return message;
        }
    }
}
