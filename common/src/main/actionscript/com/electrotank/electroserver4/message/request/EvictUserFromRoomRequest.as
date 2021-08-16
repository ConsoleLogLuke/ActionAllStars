package com.electrotank.electroserver4.message.request {
    import com.electrotank.electroserver4.message.request.*;
    import com.electrotank.electroserver4.message.MessageType;
    import com.electrotank.electroserver4.message.ValidationResponse;
    /**
     * This request allows a room operator to kick a user from the room.
     */
    
    public class EvictUserFromRoomRequest extends RequestImpl {

        private var zoneId:Number;
        private var roomId:Number;
        private var userId:String;
        private var reason:String;
        private var ban:Boolean;
        private var duration:Number;
        /**
         * Creates a new instance of the EvictUserFromRoomRequest.
         */
        public function EvictUserFromRoomRequest() {
            setMessageType(MessageType.EvictUserFromRoomRequest);
            ban = false;
        }
        public function isBan():Boolean {
            return ban;
        }
        public function setBan(val:Boolean):void {

            ban = val;
        }
        public function setDuration(num:Number):void {

            duration = num;
        }
        public function getDuration():Number {
            return duration;
        }
        public function setReason(str:String):void {

            reason = str;
        }
        public function getReason():String {
            return reason;
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
