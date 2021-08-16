package com.electrotank.electroserver4.protocol.codec {
    import com.electrotank.electroserver4.entities.SearchCriteria;
    import com.electrotank.electroserver4.MessageConstants;
    import com.electrotank.electroserver4.protocol.codec.*;
    import com.electrotank.electroserver4.protocol.*;
    import com.electrotank.electroserver4.message.Message;
    import com.electrotank.electroserver4.message.request.*;
    
    public class FindGamesRequestCodec extends MessageCodecImpl {

        public function getDefaultMessageSize():Number {
            return 1024;
        }
        
        override public function encode(writer:MessageWriter, message:Message):void {

            var request:FindGamesRequest = FindGamesRequest(message);
            
            var criteria:SearchCriteria = request.getSearchCriteria();
            SearchCriteriaCodec.encode(writer, criteria);
            
        }
    
    }
}
