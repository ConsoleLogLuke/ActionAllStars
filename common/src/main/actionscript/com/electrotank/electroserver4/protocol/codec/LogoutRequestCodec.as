package com.electrotank.electroserver4.protocol.codec {
    import com.electrotank.electroserver4.MessageConstants;
    import com.electrotank.electroserver4.protocol.codec.*;
    import com.electrotank.electroserver4.protocol.*;
    import com.electrotank.electroserver4.message.Message;
    import com.electrotank.electroserver4.message.request.*;
    import com.electrotank.electroserver4.esobject.EsObject;
    
    public class LogoutRequestCodec extends MessageCodecImpl {

        override public function encode(writer:MessageWriter, mess:Message):void {

            var request:LogoutRequest = LogoutRequest(mess);
            
            // Should we drop all connections from this user?
            writer.writeBoolean(request.getDropAllConnections());
            
            // If we are not dropping all connections, are we at least dropping the current connection?
            if(!request.getDropAllConnections()) {
                writer.writeBoolean(request.getDropConnection());
            }
    
        }
    }
}
