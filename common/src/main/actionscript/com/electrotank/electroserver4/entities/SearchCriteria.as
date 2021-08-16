package com.electrotank.electroserver4.entities {
    import com.electrotank.electroserver4.esobject.EsObject;
    /**
     * This class is used with the requests associated with the QuickJoinRequest and FindGamesRequest classes. The QuickJoinClass provides a way for you to quickly and easily find a game that is managed by the server and join it. The SearchCriteria class is used to narrow the list of games to those that you are interested in. 
     * <br/><br/>
     * See the QuickJoinRequest class for a full example.
     */
    
    public class SearchCriteria {

        private var gameType:String;
        private var locked:Boolean;
        private var gameDetails:EsObject;
        private var gameId:Number;
        private var lockedSet:Boolean;
        /**
         * Creates a new instance of the SearchCriteria class.
         */
        public function SearchCriteria() {
            setGameId(-1);
            lockedSet = false;
        }
        /**
         * Optional. Sets the id of the game you want to join. It is recommended that you use the JoinGameRequest class to join a game if you already know the game id.
         * @param    The id of the game you want to join.
         */
        public function setGameId(gameId:Number):void {

            this.gameId = gameId;
        }
        /**
         * Gets the id of the game you want to join.
         * @return The id of the game you want to join.
         */
        public function getGameId():Number {
            return gameId;
        }
        /**
         * Sets the custom search fields used to narrow the list of games found during the search.
         * @param    gameDetails
         */
        public function setGameDetails(gameDetails:EsObject):void {

            this.gameDetails = gameDetails;
        }
        /**
         * Gets the game details EsObject that is used to narrow the list of games found via the search.
         * @return
         */
        public function getGameDetails():EsObject {
            return gameDetails;
        }
        /**
         * Returns the lockedSet property. This is used internally to the API.
         * @private
         * @return True or false.
         */
        public function getLockedSet():Boolean {
            return lockedSet;
        }
        /**
         * If true then the search is only applied to locked games, if false it only applies to unlocked games, not used at all then the search applies to both locked and unlocked games.
         * @param    The locked property.
         */
        public function setLocked(locked:Boolean):void {

            lockedSet = true;
            this.locked = locked;
        }
        /**
         * Returns the locked property.
         * @return Returns the locked property.
         */
        public function getLocked():Boolean {
            return this.locked;
        }
        /**
         * Sets the game type. All searches must be applied to a game type. The game type is registered with the game on the server, such as Chess.
         * @param    The type of game to search against.
         */
        public function setGameType(gameType:String):void {

            this.gameType = gameType;
        }
        /**
         * Returns the game type.
         * @return  Returns the game type.
         */
        public function getGameType():String {
            return gameType;
        }
        
    }
}
