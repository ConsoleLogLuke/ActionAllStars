package com.electrotank.electroserver4.message.request {
    import com.electrotank.electroserver4.entities.SearchCriteria;
    import com.electrotank.electroserver4.message.request.*;
    import com.electrotank.electroserver4.message.MessageType;
    import com.electrotank.electroserver4.room.Room;
    import com.electrotank.electroserver4.message.ValidationResponse;
    /**
     * This request asks the Game Manager for a list of games based on a game type and search criteria.
     */
    
    public class FindGamesRequest extends RequestImpl {

        private var searchCriteria:SearchCriteria;
        public function FindGamesRequest() {
            setMessageType(MessageType.FindGamesRequest);
        }
        public function setSearchCriteria(searchCriteria:SearchCriteria):void {

            this.searchCriteria = searchCriteria;
        }
        public function getSearchCriteria():SearchCriteria {
            return searchCriteria;
        }
    
     override public function validate():ValidationResponse {    
            var valid:Boolean = true;
            var problems:Array = new Array();
            var vr:ValidationResponse = new ValidationResponse(valid, problems);
            return vr;
        }
        
    }
}
