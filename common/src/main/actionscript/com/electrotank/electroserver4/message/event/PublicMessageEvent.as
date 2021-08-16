package com.electrotank.electroserver4.message.event {
    import com.electrotank.electroserver4.message.MessageImpl;
    import com.electrotank.electroserver4.message.event.*;
    import com.electrotank.electroserver4.message.*;
    import com.electrotank.electroserver4.user.*;
    import com.electrotank.electroserver4.room.*;
    import com.electrotank.electroserver4.esobject.EsObject;
    
    public class PublicMessageEvent extends EventImpl {

        private var zoneId:Number;
        private var roomId:Number;
        private var userId:String;
        private var userName:String;
        private var message:String;
        private var esObject:EsObject;
        private var userNameIncluded:Boolean;
        private var _user:User;
        private var _room:Room;
        public function PublicMessageEvent() {
            setMessageType(MessageType.PublicMessageEvent);
        }
        public function setEsObject(eob:EsObject):void {

            esObject = eob;
        }
        public function getEsObject():EsObject {
            return esObject;
        }
        public function set room(r:Room):void {

            _room = r;
        }
        public function get room():Room {
            return _room;
        }
        public function set user(u:User):void {

            _user = u;
        }
        public function get user():User {
            return _user;
        }
        public function setUserName(str:String):void {

            userName = str;
        }
        public function getUserName():String {
            return userName;
        }
        public function setUserNameIncluded(val:Boolean):void {

            userNameIncluded = val;
        }
        public function isUserNameIncluded():Boolean {
            return userNameIncluded;
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
        public function setUserId(num:String):void {

            userId = num;
        }
        public function getUserId():String {
            return userId;
        }
        public function setMessage(mess:String):void {

            message = mess;
        }
        public function getMessage():String {
            return message;
        }
    }
}
