package com.electrotank.electroserver4.message.event {
    import com.electrotank.electroserver4.message.MessageImpl;
    import com.electrotank.electroserver4.message.event.*;
    import com.electrotank.electroserver4.message.*;
    import com.electrotank.electroserver4.room.*;
    
    public class UpdateRoomDetailsEvent extends EventImpl {

        private var zoneId:Number;
        private var roomId:Number;
        private var roomNameUpdate:Boolean;
        private var roomName:String;
        private var capacityUpdate:Boolean;
        private var capacity:Number;
        private var descriptionUpdate:Boolean;
        private var description:String;
        private var passwordUpdate:Boolean;
        private var password:String;
        private var hiddenUpdate:Boolean;
        private var hidden:Boolean;
        private var _room:Room;
        public function UpdateRoomDetailsEvent() {
            setMessageType(MessageType.UpdateRoomDetailsEvent);
            setHiddenUpdate(false);
            setPasswordUpdate(false);
            setDescriptionUpdate(false);
            setCapacityUpdate(false);
            setRoomNameUpdate(false);
        }
        public function set room(r:Room):void {

            _room = r;
        }
        public function get room():Room {
            return _room;
        }
        public function setHidden(val:Boolean):void {

            setHiddenUpdate(true);
            hidden = val;
        }
        public function getHidden():Boolean {
            return hidden;
        }
        public function setHiddenUpdate(val:Boolean):void {

            hiddenUpdate = val;
        }
        public function isHiddenUpdate():Boolean {
            return hiddenUpdate
        }
        public function getPassword():String {
            return password;
        }
        public function setPassword(str:String):void {

            setPasswordUpdate(true);
            password = str;
        }
        public function isPasswordUpdate():Boolean {
            return passwordUpdate;
        }
        public function setPasswordUpdate(val:Boolean):void {

            passwordUpdate = val;
        }
        public function setDescription(str:String):void {

            setDescriptionUpdate(true);
            description = str;
        }
        public function getDescription():String {
            return description;
        }
        public function setDescriptionUpdate(val:Boolean):void {

            descriptionUpdate = val;
        }
        public function isDescriptionUpdate():Boolean {
            return descriptionUpdate;
        }
        public function setCapacity(num:Number):void {

            setCapacityUpdate(true);
            capacity = num;
        }
        public function getCapacity():Number {
            return capacity;
        }
        public function setCapacityUpdate(val:Boolean):void {

            capacityUpdate = val;
        }
        public function isCapacityUpdate():Boolean {
            return capacityUpdate;
        }
        public function setRoomName(str:String):void {

            setRoomNameUpdate(true);
            roomName = str;
        }
        public function getRoomName():String {
            return roomName;
        }
        public function setRoomNameUpdate(val:Boolean):void {

            roomNameUpdate = val;
        }
        public function isRoomNameUpdate():Boolean {
            return roomNameUpdate;
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
