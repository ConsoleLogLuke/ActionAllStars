package com.electrotank.electroserver4.message.request {
    import com.electrotank.electroserver4.entities.SearchCriteria;
    import com.electrotank.electroserver4.esobject.EsObject;
    import com.electrotank.electroserver4.message.Message;
    import com.electrotank.electroserver4.message.request.*;
    import com.electrotank.electroserver4.message.MessageType;
    import com.electrotank.electroserver4.room.Room;
    import com.electrotank.electroserver4.message.ValidationResponse;
    /**
     * This request allows you to join a specific game managed by the Game Manager by specifying a game type and game id.
     */
    
    public class JoinGameRequest extends RequestImpl {

        private var password:String;
        private var gameType:String;
        private var gameId:Number;
        private var gameIdSet:Boolean;
        /**
         * Creates a new instance of the JoinGameRequest class.
         */
        public function JoinGameRequest() {
            gameIdSet = false;
            //setMessageType(MessageType.CreateOrJoinGameRequest);
            setIsRealServerMessage(false);
            //setCriteria(new SearchCriteria());
        }
        
     override public function getRealMessage():Message {
            var criteria:SearchCriteria = new SearchCriteria();
            criteria.setGameType(getGameType());
            criteria.setGameId(getGameId());
            var mes:CreateOrJoinGameRequest = new CreateOrJoinGameRequest();
            mes.setZoneName(" ");
            mes.setGameType(getGameType());
            mes.setSearchCriteria(criteria);
            mes.setPassword(getPassword());
            
            return Message(mes);
        }
        /**
         * Sets the id of the game you want to join.
         * @param    The id of the game you want to join.
         */
        public function setGameId(gameId:Number):void {

            this.gameId = gameId;
        }
        /**
         * The id of the game you want to join.
         * @return The id of the game you want to join.
         */
        public function getGameId():Number {
            return gameId;
        }
        /**
         * The type of game you want to join. Game type is something that is registered on the server that defined the game, liked Chess.
         * @param    The type of game you want to join.
         */
        public function setGameType(gameType:String):void {

            gameIdSet = true;
            this.gameType = gameType;
        }
        /**
         * The type of game you want to join.
         * @return The type of game you want to join.
         */
        public function getGameType():String {
            return gameType;
        }
        /**
         * If a password is needed to join this game, specify it here.
         * @param    The password needed to join the game, if any.
         */
        public function setPassword(password:String):void {

            this.password = password;
        }
        /**
         * The password being used to join the game.
         * @return  The passowd being used to join the game.
         */
        public function getPassword():String {
            return password;
        }
    
     override public function validate():ValidationResponse {    
            var valid:Boolean = true;
            var problems:Array = new Array();
            if (getGameType() == null) {
                problems.push("getGameType() cannot return null");
            }
            if (!gameIdSet) {
                problems.push("Must set gameId using setGameId(gameId)");
            }
            if (problems.length > 0) {
                valid = false;
            }
            var vr:ValidationResponse = new ValidationResponse(valid, problems);
            return vr;
        }
        
    }
}
