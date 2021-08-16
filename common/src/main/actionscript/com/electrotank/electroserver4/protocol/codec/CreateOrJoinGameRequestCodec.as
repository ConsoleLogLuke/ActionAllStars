package com.electrotank.electroserver4.protocol.codec {
    import com.electrotank.electroserver4.esobject.EsObject;
    import com.electrotank.electroserver4.MessageConstants;
    import com.electrotank.electroserver4.protocol.codec.*;
    import com.electrotank.electroserver4.protocol.*;
    import com.electrotank.electroserver4.message.Message;
    import com.electrotank.electroserver4.message.request.*;
    
    public class CreateOrJoinGameRequestCodec extends MessageCodecImpl {

        override public function encode(writer:MessageWriter, message:Message):void {

            var request:CreateOrJoinGameRequest = CreateOrJoinGameRequest(message);
            
            writer.writeString(request.getGameType());
            writer.writeString(request.getZoneName());
            if(request.getPassword() == null || request.getPassword().length == 0) {
                writer.writeBoolean(false);
            } else {
                writer.writeBoolean(true);
                writer.writeString(request.getPassword());
            }
            var details:EsObject = request.getGameDetails();
            if(details == null) {
                writer.writeBoolean(false);
            } else {
                writer.writeBoolean(true);
                EsObjectCodec.encode(writer, details);
            }
            writer.writeBoolean(request.getIsLocked());//locked
            writer.writeBoolean(request.getIsHidden());
            SearchCriteriaCodec.encode(writer, request.getSearchCriteria());
            
            
        }
    
    }
}
