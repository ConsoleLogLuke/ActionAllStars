package com.electrotank.electroserver4.protocol.codec {
    import com.electrotank.electroserver4.esobject.EsObject;
    import com.electrotank.electroserver4.MessageConstants;
    import com.electrotank.electroserver4.protocol.codec.*;
    import com.electrotank.electroserver4.protocol.*;
    import com.electrotank.electroserver4.message.Message;
    import com.electrotank.electroserver4.message.event.*;
    import com.electrotank.electroserver4.message.response.*;
    import com.electrotank.electroserver4.message.request.*;
    import com.electrotank.electroserver4.zone.Zone;
    
    public class GetUserVariablesResponseCodec extends MessageCodecImpl {

        override public function decode(reader:MessageReader):Message {
            var message:GetUserVariablesResponse = new GetUserVariablesResponse();
                var requestId:String = reader.nextInteger(MessageConstants.MESSAGE_ID_SIZE).toString();
            message.setUserName(reader.nextString());
            
            var cnt:Number = reader.nextInteger();
            for (var i:Number = 0; i < cnt; i++) {
                var name:String = reader.nextString();
                var esob:EsObject = EsObjectCodec.decode(reader);
                message.addVariable(name, esob);
            }
            
            return message;
        }
    }
}
