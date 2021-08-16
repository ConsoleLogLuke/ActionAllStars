package com.electrotank.electroserver4.protocol.codec {
    import com.electrotank.electroserver4.errors.Errors;
    import com.electrotank.electroserver4.errors.EsError;
    import com.electrotank.electroserver4.esobject.EsObject;
    import com.electrotank.electroserver4.MessageConstants;
    import com.electrotank.electroserver4.protocol.codec.*;
    import com.electrotank.electroserver4.protocol.*;
    import com.electrotank.electroserver4.message.Message;
    import com.electrotank.electroserver4.message.request.*;
    import com.electrotank.electroserver4.entities.*;
    import com.electrotank.electroserver4.plugin.*;
    
    public class GateWayKickUserRequestCodec extends MessageCodecImpl {

        override public function encode(writer:MessageWriter, mess:Message):void {

            var request:GateWayKickUserRequest = GateWayKickUserRequest(mess);
            
        }
        
        override public function decode(msr:MessageReader):Message {
    
            var message:GateWayKickUserRequest = new GateWayKickUserRequest();
    
            /*
            var userId:String = msr.nextLong();
            var esError:EsError = Errors.getErrorById(msr.nextInteger());
            message.setEsError(esError);
            
            if (msr.nextBoolean()) {
                var esObject:EsObject = EsObjectCodec.decode(msr);
                message.setEsObject(esObject);
            }
            */
    
            return message;
    
        }
        
    }
}
