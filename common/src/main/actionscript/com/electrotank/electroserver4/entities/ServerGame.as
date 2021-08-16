package com.electrotank.electroserver4.entities {
    import com.electrotank.electroserver4.esobject.EsObject;
    /**
     * This class is used to represent a game on the server. When a client sends a FindGamesRequest, a FindGamesResponse is reached. The FindGamesResponse contains a list of games found. Each game is represented by an instance of this class.
     */
    
    public class ServerGame {

        private var passwordProtected:Boolean;
        private var gameDetails:EsObject;
        private var locked:Boolean;
        private var gameId:Number;
        /**
         * Creates a new instance of the ServerGame class.
         */
        public function ServerGame() {
            
        }
        /**
         * Sets the passwordProtected property. If true, then the server game requires a password to join.
         * @param    True or false.
         */
        public function setPasswordProtected(passwordProtected:Boolean):void {

            this.passwordProtected = passwordProtected;
        }
        /**
         * Gets the passwordProtected property of the game.
         * @return The password protected property of the game.
         */
        public function getPasswordProtected():Boolean {
            return passwordProtected;
        }
        /**
         * Sets the game details property of the game. Every game has a public property represented by an EsObject.
         * @param    The game details property of the game.
         */
        public function setGameDetails(gameDetails:EsObject):void {

            this.gameDetails = gameDetails;
        }
        /**
         * Gets the game details property of the game. Every game has a public property represented by an EsObject.
         * @return The game details property of the game.
         */
        public function getGameDetails():EsObject {
            return gameDetails;
        }
        /**
         * Sets the locked property of the game. If true that means the game is locked and cannot be joined.
         * @param    The locked property of the game.
         */
        public function setLocked(locked:Boolean):void {

            this.locked = locked;
        }
        /**
         * Gets the locked property of the game.
         * @return The locked property of the game.
         */
        public function getLocked():Boolean {
            return locked;
        }
        /**
         * Sets the id of the game.
         * @param    The id of the game.
         */
        public function setGameId(gameId:Number):void {

            this.gameId = gameId;
        }
        /**
         * Gets the game id.
         * @return Returns the game id.
         */
        public function getGameId():Number {
            return gameId;
        }
    }
}
