package com.electrotank.electroserver4.message.request {
    import com.electrotank.electroserver4.entities.SearchCriteria;
    import com.electrotank.electroserver4.esobject.EsObject;
    import com.electrotank.electroserver4.message.Message;
    import com.electrotank.electroserver4.message.request.*;
    import com.electrotank.electroserver4.message.MessageType;
    import com.electrotank.electroserver4.room.Room;
    import com.electrotank.electroserver4.message.ValidationResponse;
    /**
     * This class lets you create a new game using the Game Manager. The game type specified must be registered with ElectroServer (That is not done via the client). To create a new game the game type must be specified (like Chess) and a zone name is specified.
     * There are other optional things that can be specified when creating a game as well. 
     * <br><b>Game Details</b> - This is an EsObject that is acts as a public property for the game. The game plugin(s) can view and edit this object and other users see it in the game list associated with this game. 
     * <br><b>Password</b> - If you want the game to be password protected then just set a password during the game creation.
     * <br><b>Hidden</b> - By default a new game is not hidden. If you set it to be hidden on create then it does not show up in the game list, but users can still join it if they know the game id.
     * <br><b>Locked</b> - By default a new game is not locked. If you set it to be locked on create then users cannot join that game until it is unlocked.
     * @example
     * This example shows how to create a new game and capture the CreateOrJoinGameResponse.
     * <listing>
    import com.electrotank.electroserver4.ElectroServer;
    import com.electrotank.electroserver4.errors.EsError;
    import com.electrotank.electroserver4.esobject.EsObject;
    import com.electrotank.electroserver4.message.MessageType;
    import com.electrotank.electroserver4.message.request.CreateGameRequest;
    import com.electrotank.electroserver4.message.response.CreateOrJoinGameResponse;
    //
    var es:ElectroServer;//Assume this was created, connection established, and login established already
    //
    function init():void {
        es.addEventListener(MessageType.CreateOrJoinGameResponse, "onCreateOrJoinGameResponse", this);
    }
    function createGame():void {
        //custom game details that are associtated with the game on the server
        var gameDetails:EsObject = new EsObject();
        gameDetails.setString("Map", "RoughTerrain.xml");
        gameDetails.setInteger("TimeLimit", 100000);
        //build the request
        var cgr:CreateGameRequest = new CreateGameRequest();
        cgr.setZoneName("Game Zone");
        cgr.setGameDetails(gameDetails);
        cgr.setGameType("TankGame");
        //send it
        es.send(cgr);
    }
    function onCreateOrJoinGameResponse(e:CreateOrJoinGameResponse):void {
        if (e.getSuccessful()) {
            trace("Joined game");
            var gameDetails:EsObject = e.getGameDetails();
            var gameId:Number = e.getGameId();
        } else {
            trace("Failed to create or join game.");
            var err:EsError = e.getEsError();
            trace(err.getDescription());
        }
    }
    init();
    createGame();
     * </listing>
     */
    
    public class CreateGameRequest extends RequestImpl {

        private var password:String;
        private var zoneName:String;
        private var gameDetails:EsObject;
        private var gameType:String;
        private var isHidden:Boolean;
        private var isLocked:Boolean;
        /**
         * Creates a new instance of CreateGameRequest.
         */
        public function CreateGameRequest() {
            //setMessageType(MessageType.CreateOrJoinGameRequest);
            setIsRealServerMessage(false);
            setIsHidden(false);
            setIsLocked(false);
        }
        
     override public function getRealMessage():Message {
            var mes:CreateOrJoinGameRequest = new CreateOrJoinGameRequest();
            mes.setZoneName(getZoneName());
            mes.setGameType(getGameType());
            mes.setGameDetails(getGameDetails());
            mes.setCreateOnly(true);
            mes.setPassword(getPassword());
            mes.setIsHidden(getIsHidden());
            mes.setIsLocked(getIsLocked());
            
            return Message(mes);
        }
        /**
         * The default setting is false. If true, the game is created locked. Users cannot join a locked game. The locked status of a game can be changed by a plugin in that game room.
         * @param    Set to true to start a game off locked, false to not.
         */
        public function setIsLocked(isLocked:Boolean):void {

            this.isLocked = isLocked;
        }
        /**
         * Returns the locked property for the new game to be created.
         * @return The locked property
         */
        public function getIsLocked():Boolean {
            return isLocked;
        }
        /**
         * The default setting is false. If set to true then the game is created hidden. A hidden game is not visible in a game list but can still be joined by someone who knows the game id. The hidden status can be updated by a plugin in the game room.
         * @param    Set to true if you want the game to be hidden from the game list.
         */
        public function setIsHidden(isHidden:Boolean):void {

            this.isHidden = isHidden;
        }
        /**
         * Returns the hidden property of the new game to be created.
         * @return The hidden property.
         */
        public function getIsHidden():Boolean {
            return isHidden;
        }
        /**
         * Sets the name of the zone in which to create the game. If that zone doesn't exist then it will be created. 
         * @param    The name of the zone in which to crate the game.
         */
        public function setZoneName(zoneName:String):void {

            this.zoneName = zoneName;
        }
        /**
         * The name of the zone in which to create the game.
         * @return The name of the zone in which to create the game.
         */
        public function getZoneName():String {
            return zoneName;
        }
        /**
         * The game type as registered on the server. In order for a game to be created its type must be registered on the server. See the Game Manager documentation for the server. 
         * @param    The type of game to create.
         */
        public function setGameType(gameType:String):void {

            this.gameType = gameType;
        }
        /**
         * Returns the type of game to be created.
         * @return The type of game to be created.
         */
        public function getGameType():String {
            return gameType;
        }
        /**
         * This is optional. If you want your new game to be password protected then set it here.
         * @param    The optional password to use.
         */
        public function setPassword(password:String):void {

            this.password = password;
        }
        /**
         * Returns the password, if one exists, to be used in the new game.
         * @return The password to be used in the new game.
         */
        public function getPassword():String {
            return password;
        }
        /**
         * This is optional. When users view the game list they see a game details EsObject associated with each game. That EsObject is a merge of the optional object set here and the default game details object that is used for the registered game type. The game details object can be viewed by the game plugin(s) and modified at any time. It is typically used to show custom game properties such as the level map being used or the pot limit in a game of poker.
         * @param    An EsObject.
         */
        public function setGameDetails(gameDetails:EsObject):void {

            this.gameDetails = gameDetails;
        }
        /**
         * Returns the optional EsObject to be used as the game's game details.
         * @return
         */
        public function getGameDetails():EsObject {
            return this.gameDetails;
        }
    
     override public function validate():ValidationResponse {    
            var valid:Boolean = true;
            var problems:Array = new Array();
            if (getGameType() == null) {
                problems.push("getGameType() cannot return null");
            }
            if (getZoneName() == null) {
                problems.push("getZoneName() cannot return null");
            }
            if (problems.length > 0) {
                valid = false;
            }
            var vr:ValidationResponse = new ValidationResponse(valid, problems);
            return vr;
        }
        
    }
}
