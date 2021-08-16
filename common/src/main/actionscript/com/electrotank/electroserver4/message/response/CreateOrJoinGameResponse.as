package com.electrotank.electroserver4.message.response {
    import com.electrotank.electroserver4.message.MessageImpl;
    import com.electrotank.electroserver4.message.response.*;
    import com.electrotank.electroserver4.message.*;
    import com.electrotank.electroserver4.errors.*;
    import com.electrotank.electroserver4.esobject.EsObject;
    
    public class CreateOrJoinGameResponse extends ResponseImpl {

        private var successful:Boolean;
        private var zoneId:Number;
        private var roomId:Number;
        private var esError:EsError;
        private var gameDetails:EsObject;
        private var gameId:Number;
        public function CreateOrJoinGameResponse() {
            setMessageType(MessageType.CreateOrJoinGameResponse);
        }
        public function setGameId(gameId:Number):void {

            this.gameId = gameId;
        }
        public function getGameId():Number {
            return gameId;
        }
        public function setGameDetails(gameDetails:EsObject):void {

            this.gameDetails = gameDetails;
        }
        public function getGameDetails():EsObject {
            return gameDetails;
        }
        public function setSuccessful(successful:Boolean):void {

            this.successful = successful;
        }
        public function getSuccessful():Boolean {
            return successful;
        }
        public function setZoneId(zoneId:Number):void {

            this.zoneId = zoneId;
        }
        public function getZoneId():Number {
            return zoneId;
        }
        public function setRoomId(roomId:Number):void {

            this.roomId = roomId;
        }
        public function getRoomId():Number {
            return roomId;
        }
        public function setEsError(esError:EsError):void {

            this.esError = esError;
        }
        public function getEsError():EsError {
            return esError;
        }
    }
}
