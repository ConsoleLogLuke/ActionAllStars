package com.electrotank.electroserver4.message.request {
    import com.electrotank.electroserver4.message.request.*;
    import com.electrotank.electroserver4.message.MessageType;
    import com.electrotank.electroserver4.message.ValidationResponse;
    /**
     * This request is used for one room operator to request that another user in the room be granted operator privelages.
     */
    
    public class AddRoomOperatorRequest extends RequestImpl {

        private var userId:String;
        private var zoneId:Number;
        private var roomId:Number;
        /**
         * Creates a new AddRoomOperatorRequest.
         */
        public function AddRoomOperatorRequest() {
            setMessageType(MessageType.AddRoomOperatorRequest);
        }
     override public function validate():ValidationResponse {    
            var valid:Boolean = true;
            var problems:Array = new Array();
            var vr:ValidationResponse = new ValidationResponse(valid, problems);
            return vr;
        }
        /**
         * Sets the user id of the user to be added as a room operator.
         * @param    The user id of the user to be added as a room operator.
         */
        public function setUserId(userId:String):void {

            this.userId = userId;
        }
        /**
         * Gets the user id for the user to be added as a room operator.
         * @return The user id of the user to be added as a room operator.
         */
        public function getUserId():String {
            return userId;
        }
        /**
         * Sets the zone id for the zone that contains the room.
         * @param    The zone id for the zone that contains the room.
         */
        public function setZoneId(zId:Number):void {

            zoneId = zId;
        }
        /**
         * Gets the zone id for the zone that contains the room.
         * @return
         */
        public function getZoneId():Number {
            return zoneId;
        }
        /**
         * Sets the room id of the room for which the user should be granted operator status.
         * @param    The room id of the room for which the user should be granted operator status.
         */
        public function setRoomId(rId:Number):void {

            roomId = rId;
        }
        /**
         * Gets the room id of the room for which the user should be granted operator status.
         * @return The room id of the room for which the user should be granted operator status.
         */
        public function getRoomId():Number {
            return roomId;
        }
    }
}
