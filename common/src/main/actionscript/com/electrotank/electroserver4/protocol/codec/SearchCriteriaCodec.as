package com.electrotank.electroserver4.protocol.codec {
    import com.electrotank.electroserver4.esobject.*;
    import com.electrotank.electroserver4.MessageConstants;
    import com.electrotank.electroserver4.protocol.codec.*;
    import com.electrotank.electroserver4.protocol.*;
    import com.electrotank.electroserver4.message.Message;
    import com.electrotank.electroserver4.message.request.*;
    import com.electrotank.electroserver4.entities.SearchCriteria;
    
    
    public class SearchCriteriaCodec extends MessageCodecImpl {

    
    
        static public function encode(writer:MessageWriter, criteria:SearchCriteria):void {

            
            if(criteria == null) {
                writer.writeBoolean(false);
            } else {
                writer.writeBoolean(true);
                if(criteria.getGameId() == -1) {
                    writer.writeBoolean(false);
                } else {
                    writer.writeBoolean(true);
                    writer.writeInteger(criteria.getGameId());
                }
            
                writer.writeString(criteria.getGameType());
                writer.writeBoolean(criteria.getLockedSet());
                if (criteria.getLockedSet()) {
                    writer.writeBoolean(criteria.getLocked());
                }
                var details:EsObject = criteria.getGameDetails();
                if(details == null) {
                    writer.writeBoolean(false);
                } else {
                    writer.writeBoolean(true);
                    EsObjectCodec.encode(writer, details);
                }
            }
        }
    
    
    }
}
