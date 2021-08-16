package com.electrotank.electroserver4.message.event {
    import com.electrotank.electroserver4.message.MessageImpl;
    import com.electrotank.electroserver4.message.event.*;
    import com.electrotank.electroserver4.message.*;
    import com.electrotank.electroserver4.room.*;
    import com.electrotank.electroserver4.entities.*;
    import com.electrotank.electroserver4.esobject.EsObject;
    
    public class RoomVariableUpdateEvent extends EventImpl {

        //static update actions
        static public var VariableCreated:Number = 1;
        static public var VariableUpdated:Number = 2;
        static public var VariableDeleted:Number = 3;
        //
        private var roomId:Number;
        private var zoneId:Number;
        private var name:String;
        private var value:EsObject;
        private var locked:Boolean;
        private var lockChanged:Boolean;
        private var valueChanged:Boolean;
        private var updateAction:Number;
        private var persistent:Boolean;
        private var _room:Room;
        private var _minorType:String;
        private var _variable:RoomVariable;
        public function RoomVariableUpdateEvent() {
            setMessageType(MessageType.RoomVariableUpdateEvent);
        }
        public function set room(r:Room):void {

            _room = r;
        }
        public function get room():Room {
            return _room;
        }
        public function set minorType(s:String):void {

            _minorType = s;
        }
        public function get minorType():String {
            return _minorType;
        }
        public function set variable(v:RoomVariable):void {

            _variable = v;
        }
        public function get variable():RoomVariable {
            return _variable;
        }
        public function setPersistent(val:Boolean):void {

            persistent = val;
        }
        public function getPersistent():Boolean {
            return persistent;
        }
        public function setUpdateAction(num:Number):void {

            updateAction = num;
        }
        public function getUpdateAction():Number {
            return updateAction;
        }
        public function setLockChanged(val:Boolean):void {

            lockChanged = val;
        }
        public function getLockChanged():Boolean {
            return lockChanged;
        }
        public function setValueChanged(val:Boolean):void {

            valueChanged = val;
        }
        public function getValueChanged():Boolean {
            return valueChanged;
        }
        public function setName(str:String):void {

            name = str;
        }
        public function getName():String {
            return name;
        }
        public function setValue(str:EsObject):void {

            value = str;
        }
        public function getValue():EsObject {
            return value;
        }
        public function getLocked():Boolean {
            return locked;
        }
        public function setLocked(val:Boolean):void {

            locked = val;
        }
        public function setRoomId(num:Number):void {

            roomId = num;
        }
        public function getRoomId():Number {
            return roomId;
        }
        public function setZoneId(num:Number):void {

            zoneId = num;
        }
        public function getZoneId():Number {
            return zoneId;
        }
    }
}
