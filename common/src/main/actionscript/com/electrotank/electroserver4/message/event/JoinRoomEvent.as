package com.electrotank.electroserver4.message.event {
    import com.electrotank.electroserver4.message.MessageImpl;
    import com.electrotank.electroserver4.message.event.*;
    import com.electrotank.electroserver4.message.*;
    import com.electrotank.electroserver4.room.*;
    
    public class JoinRoomEvent extends EventImpl {

        private var zoneId:Number;
        private var roomId:Number;
        private var roomName:String;
        private var zoneName:String;
        private var roomDescription:String;
        private var users:Array;
        private var roomVariables:Array;
        private var capacity:Number;
        private var isHidden:Boolean;
        private var hasPassword:Boolean;
        private var _room:Room;
        public function JoinRoomEvent() {
            setMessageType(MessageType.JoinRoomEvent);
            roomVariables = new Array();
        }
        public function set room(r:Room):void {

            _room = r;
        }
        public function get room():Room {
            return _room;
        }
        public function setCapacity(num:Number):void {

            capacity = num;
        }
        public function getCapacity():Number {
            return capacity;
        }
        public function setIsHidden(val:Boolean):void {

            isHidden = val;
        }
        public function getIsHidden():Boolean {
            return isHidden;
        }
        public function setHasPassword(val:Boolean):void {

            hasPassword = val;
        }
        public function getHasPassword():Boolean {
            return hasPassword;
        }
        public function setRoomVariables(arr:Array):void {

            roomVariables = arr;
        }
        public function getRoomVariables():Array {
            return roomVariables;
        }
        public function setUsers(arr:Array):void {

            users = arr;
        }
        public function getUsers():Array {
            return users;
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
        public function setZoneName(str:String):void {

            zoneName = str;
        }
        public function getZoneName():String {
            return zoneName;
        }
        public function setRoomName(str:String):void {

            roomName = str;
        }
        public function getRoomName():String {
            return roomName;
        }
        public function setRoomDescription(str:String):void {

            roomDescription = str;
        }
        public function getRoomDescription():String {
            return roomDescription;
        }
    }
}
