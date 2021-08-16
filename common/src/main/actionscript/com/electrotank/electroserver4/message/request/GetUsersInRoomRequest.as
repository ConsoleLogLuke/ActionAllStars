package com.electrotank.electroserver4.message.request {
    import com.electrotank.electroserver4.message.request.*;
    import com.electrotank.electroserver4.message.MessageType;
    import com.electrotank.electroserver4.message.ValidationResponse;
    /**
     * Given a room id and zone id, this request loads the list of users found in a specific room.
     */
    
    public class GetUsersInRoomRequest extends RequestImpl {

        private var roomId:Number;
        private var zoneId:Number;
        public function GetUsersInRoomRequest() {
            setMessageType(MessageType.GetUsersInRoomRequest);
        }
    
     override public function validate():ValidationResponse {    
            var valid:Boolean = true;
            var problems:Array = new Array();
            var vr:ValidationResponse = new ValidationResponse(valid, problems);
            return vr;
        }
        /**
         * The id of the room.
         * @param    The id of the room.
         */
        public function setRoomId(rId:Number):void {

            roomId = rId;
        }
        /**
         * The id of the room.
         * @return The id of the room.
         */
        public function getRoomId():Number {
            return roomId;
        }
        /**
         * The id of the zone.
         * @param    The id of the zone.
         */
        public function setZoneId(zId:Number):void     {

            zoneId = zId;
        }
        /**
         * The id of the zone.
         * @return The id of the zone.
         */
        public function getZoneId():Number {
            return zoneId;
        }
    }
}
