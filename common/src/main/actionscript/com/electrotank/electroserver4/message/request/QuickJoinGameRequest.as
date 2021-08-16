package com.electrotank.electroserver4.message.request {
    import com.electrotank.electroserver4.entities.SearchCriteria;
    import com.electrotank.electroserver4.esobject.EsObject;
    import com.electrotank.electroserver4.message.Message;
    import com.electrotank.electroserver4.message.request.*;
    import com.electrotank.electroserver4.message.MessageType;
    import com.electrotank.electroserver4.room.Room;
    import com.electrotank.electroserver4.message.ValidationResponse;
    /**
     * This class lets you quickly create or join a game using ElectroServer's built-in Game Manager. The game type specified must be registered with ElectroServer (That is not done via the client).
     * <br>This request first tries to find a game to join. If it doesn't find a game, then it creates one and joins you to it. Here are the fields used to find a game:
     * <br><b>setSearchCriteria(SearchCriteria)</b> - Existing games are defined by their game type and by their game details EsObject. The SearchCriteria class lets you specify match requirements used during the server. If you only want to join a game using the IceWorld.xml map, then that can be automated in this way. See the SearchCriteria class for more information.
     * <br><br>Here is what is used to create a game if one isn't found:
     * <br><b>setGameType(string)</b> - In order for a game to be managed by the Game Manager it must be registered with the server, for instance Chess. That game type is then specified here so the correct game type is used on the server.
     * <br><b>setGameDetails(EsObject)</b> - This is an EsObject that is acts as a public property for the game. The game plugin(s) can view and edit this object and other users see it in the game list associated with this game. 
     * <br><b>setPassword(string)</b> - Optional. If you want the game to be password protected then just set a password during the game creation.
     * <br><b>setZoneName(string)</b> - This is the zone in which the game will be created. Any string name will do.
     * @example
     * This example shows how to create a new game and capture the CreateOrJoinGameResponse.
     * <listing>
    import com.electrotank.electroserver4.ElectroServer;
    import com.electrotank.electroserver4.entities.SearchCriteria;
    import com.electrotank.electroserver4.errors.EsError;
    import com.electrotank.electroserver4.esobject.EsObject;
    import com.electrotank.electroserver4.message.MessageType;
    import com.electrotank.electroserver4.message.request.QuickJoinGameRequest;
    import com.electrotank.electroserver4.message.response.CreateOrJoinGameResponse;
    //
    var es:ElectroServer;//Assume this was created, connection established, and login established already
    //
    function init():void {
        es.addEventListener(MessageType.CreateOrJoinGameResponse, "onCreateOrJoinGameResponse", this);
    }
    function quickJoinGame():void {
        //custom game details that are associtated with the game on the server
        var gameDetails:EsObject = new EsObject();
        gameDetails.setString("Map", "RoughTerrain.xml");
        gameDetails.setInteger("TimeLimit", 100000);
        //Create the search criteria. This is used to try to find a game to join.
        var sc:SearchCriteria = new SearchCriteria();
        sc.setGameType("TankGame");//mandatory
        sc.setGameDetails(gameDetails);//optional. use the game details as a search constraint, and use it below in case a match wasn't found.
        //build the request
        var cgr:QuickJoinGameRequest = new QuickJoinGameRequest();
        cgr.setZoneName("Game Zone");//Used if a game isn't found and one needs to be created.
        cgr.setGameDetails(gameDetails);//Used if a game isn't found and one needs to be created.
        cgr.setGameType("TankGame");//Used if a game isn't found and one needs to be created.
        cgr.setSearchCriteria(sc);//Used to find an existing game
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
    quickJoinGame();
     * </listing>
    */
    
    public class QuickJoinGameRequest extends RequestImpl {

        private var password:String;
        private var zoneName:String;
        private var gameDetails:EsObject;
        private var searchCriteria:SearchCriteria;
        private var gameType:String;
        /**
         * Creates a new instance of the QuickJoinGameRequest class.
         */
        public function QuickJoinGameRequest() {
            //setMessageType(MessageType.CreateOrJoinGameRequest);
            setIsRealServerMessage(false);
            //setCriteria(new SearchCriteria());
        }
        
     override public function getRealMessage():Message {
            if (searchCriteria == null) {
                searchCriteria = new SearchCriteria();
            }
            if (searchCriteria.getGameType() == null) {
                searchCriteria.setGameType(getGameType());
            }
            var mes:CreateOrJoinGameRequest = new CreateOrJoinGameRequest();
            mes.setZoneName(getZoneName());
            mes.setGameType(getGameType());
            mes.setGameDetails(getGameDetails());
            mes.setSearchCriteria(getSearchCriteria());
            mes.setPassword(getPassword());
            
            return Message(mes);
        }
        /**
         * Sets the name of the zone to create the game in if a game isn't found to join.
         * @param    The name of the zone to create the game in if a game isn't found to join.
         */
        public function setZoneName(zoneName:String):void {

            this.zoneName = zoneName;
        }
        /**
         * Name of the zone to used when creating a game.
         * @return Name of the zone to use when creating a game.
         */
        public function getZoneName():String {
            return zoneName;
        }
        /**
         * Game type as registered on the server.
         * @param    The type of game registered with ElectroServer.
         */
        public function setGameType(gameType:String):void {

            this.gameType = gameType;
        }
        /**
         * The type of game registered with ElectroServer.
         * @return The type of game registered with ElectroServer.
         */
        public function getGameType():String {
            return gameType;
        }
        /**
         * Optional password to be used when joining a game or creating one.
         * @param    Optional password to be used when joining a game or creating one.
         */
        public function setPassword(password:String):void {

            this.password = password;
        }
        /**
         * Password to be used when joining or creating a game.
         * @return Password to be used when joining or creating a game.
         */
        public function getPassword():String {
            return password;
        }
        /**
         * The EsObjec to be used if a game is being created.
         * @param    The EsObjec to be used if a game is being created.
         */
        public function setGameDetails(gameDetails:EsObject):void {

            this.gameDetails = gameDetails;
        }
        /**
         * The EsObjec to be used if a game is being created.
         * @return The EsObjec to be used if a game is being created.
         */
        public function getGameDetails():EsObject {
            return this.gameDetails;
        }
        /**
         * The class used to inform the Game Manager what type of game to look for. Game type and specific fields on the game details object can be used to limit the search.
         * @param    SearchCriteria class instance.
         */
        public function setSearchCriteria(criteria:SearchCriteria):void {

            this.searchCriteria = criteria;
        }
        /**
         * Gets the SearchCriteria class instance.
         * @return Returns the SearchCriteria class instance.
         */
        public function getSearchCriteria():SearchCriteria {
            return searchCriteria;
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
