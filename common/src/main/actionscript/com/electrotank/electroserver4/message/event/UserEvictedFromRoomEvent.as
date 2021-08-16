package com.electrotank.electroserver4.message.event {
    import com.electrotank.electroserver4.message.MessageImpl;
    import com.electrotank.electroserver4.message.event.*;
    import com.electrotank.electroserver4.message.*;
    import com.electrotank.electroserver4.user.*;
    
    public class UserEvictedFromRoomEvent extends EventImpl {

        private var zoneId:Number;
        private var roomId:Number;
        private var userId:String;
        private var reason:String;
        private var ban:Boolean;
        private var duration:Number;
        private var _user:User;
        public function UserEvictedFromRoomEvent() {
            setMessageType(MessageType.UserEvictedFromRoomEvent);
            ban = false;
        }
        public function set user(u:User):void {

            _user = u;
        }
        public function get user():User {
            return _user;
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
