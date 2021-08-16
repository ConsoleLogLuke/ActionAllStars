package com.electrotank.electroserver4.message.event {
    import com.electrotank.electroserver4.message.MessageImpl;
    import com.electrotank.electroserver4.message.event.*;
    import com.electrotank.electroserver4.message.*;
    import com.electrotank.electroserver4.room.*;
    import com.electrotank.electroserver4.zone.*;
    
    public class ZoneUpdateEvent extends EventImpl {

        //static udpate actions
        static public var AddRoom:Number = 0;
        static public var DeleteRoom:Number = 1;
        static public var UpdateRoom:Number = 2;
        //
        private var zoneId:Number;
        private var roomId:Number;
        private var actionId:Number;
        private var roomCount:Number;
        private var __room:Room;
        private var _room:Room;
        private var _minorType:String;
        private var _zone:Zone;
        public function ZoneUpdateEvent() {
            setMessageType(MessageType.ZoneUpdateEvent);
        }
        public function set zone(z:Zone):void {

            _zone = z;
        }
        public function get zone():Zone {
            return _zone;
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
        public function setRoom(rm:Room):void {

            __room = rm;
        }
        public function getRoom():Room {
            return __room;
        }
        public function setRoomCount(num:Number):void {

            roomCount = num;
        }
        public function getRoomCount():Number {
            return roomCount;
        }
        public function setActionId(num:Number):void {

            actionId = num;
        }
        public function getActionId():Number {
            return actionId;
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
