package com.electrotank.electroserver4.message.request {
    import com.electrotank.electroserver4.entities.SearchCriteria;
    import com.electrotank.electroserver4.esobject.EsObject;
    import com.electrotank.electroserver4.message.request.*;
    import com.electrotank.electroserver4.message.MessageType;
    import com.electrotank.electroserver4.room.Room;
    import com.electrotank.electroserver4.message.ValidationResponse;
    /**
     * @private
     */
    
    public class CreateOrJoinGameRequest extends RequestImpl {

        private var zoneName:String;
        private var password:String;
        private var gameDetails:EsObject;
        private var searchCriteria:SearchCriteria;
        private var gameType:String;
        private var createOnly:Boolean;
        private var isHidden:Boolean;
        private var isLocked:Boolean;
        public function CreateOrJoinGameRequest() {
            setMessageType(MessageType.CreateOrJoinGameRequest);
            setSearchCriteria(new SearchCriteria());
            setIsHidden(false);
            setIsLocked(false);
        }
        public function setCreateOnly(createOnly:Boolean):void {

            this.createOnly = createOnly;
            if (createOnly) {
                searchCriteria = null;
            }
        }
        public function setIsLocked(isLocked:Boolean):void {

            this.isLocked = isLocked;
        }
        public function getIsLocked():Boolean {
            return isLocked;
        }
        public function setIsHidden(isHidden:Boolean):void {

            this.isHidden = isHidden;
        }
        public function getIsHidden():Boolean {
            return isHidden;
        }
        public function setGameType(gameType:String):void {

            this.gameType = gameType;
        }
        public function getGameType():String {
            return gameType;
        }
        public function setZoneName(zoneName:String):void {

            this.zoneName = zoneName;
        }
        public function getZoneName():String {
            return zoneName;
        }
        public function setPassword(password:String):void {

            this.password = password;
        }
        public function getPassword():String {
            return password;
        }
        public function setGameDetails(gameDetails:EsObject):void {

            this.gameDetails = gameDetails;
        }
        public function getGameDetails():EsObject {
            return this.gameDetails;
        }
        public function setSearchCriteria(criteria:SearchCriteria):void {

            this.searchCriteria = criteria;
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
