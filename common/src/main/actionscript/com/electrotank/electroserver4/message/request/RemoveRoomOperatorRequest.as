package com.electrotank.electroserver4.message.request {
    import com.electrotank.electroserver4.message.request.*;
    import com.electrotank.electroserver4.message.MessageType;
    import com.electrotank.electroserver4.message.ValidationResponse;
    /**
     * This class allows one room operator to remove another room operator. A room operator has special privelages in a room, such as being able to kick and ban users.
     */
    
    public class RemoveRoomOperatorRequest extends RequestImpl {

        private var userId:String;
        private var zoneId:Number;
        private var roomId:Number;
        /**
         * Creates a new instance of the RemoveRoomOperatorRequest.
         */
        public function RemoveRoomOperatorRequest() {
            setMessageType(MessageType.RemoveRoomOperatorRequest);
        }
    
     override public function validate():ValidationResponse {    
            var valid:Boolean = true;
            var problems:Array = new Array();
            var vr:ValidationResponse = new ValidationResponse(valid, problems);
            return vr;
        }
        public function setUserId(str:String):void {

            userId = str;
        }
        public function getUserId():String {
            return userId;
        }
        public function setZoneId(num:Number):void {

            zoneId = num;
        }
        public function getZoneId():Number {
            return zoneId;
        }
        public function setRoomId(num:Number):void {

            roomId = num;
        }
        public function getRoomId():Number {
            return roomId;
        }
    }
}
