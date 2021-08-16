package com.electrotank.electroserver4.protocol.codec {
    import com.electrotank.electroserver4.MessageConstants;
    import com.electrotank.electroserver4.protocol.codec.*;
    import com.electrotank.electroserver4.protocol.*;
    import com.electrotank.electroserver4.message.Message;
    import com.electrotank.electroserver4.message.request.*;
    import com.electrotank.electroserver4.esobject.EsObject;
    
    public class GetUserVariablesRequestCodec extends MessageCodecImpl {

        override public function encode(writer:MessageWriter, mess:Message):void {

            var request:GetUserVariablesRequest = GetUserVariablesRequest(mess);
            
            writer.writeString(request.getUserName());
            var uvs:Array = request.getUserVariableNames();
            trace(writer)
            writer.writeInteger(uvs.length);
            for (var i:Number=0;i<uvs.length;++i) {
                writer.writeString(uvs[i]);
            }
        }
    }
}
