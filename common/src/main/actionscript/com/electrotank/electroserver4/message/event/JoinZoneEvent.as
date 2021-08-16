package com.electrotank.electroserver4.message.event {
    import com.electrotank.electroserver4.message.MessageImpl;
    import com.electrotank.electroserver4.message.event.*;
    import com.electrotank.electroserver4.message.*;
    import com.electrotank.electroserver4.zone.*;
    
    public class JoinZoneEvent extends EventImpl {

        private var zoneId:Number;
        private var zoneName:String;
        private var rooms:Array;
        private var _zone:Zone;
        public function JoinZoneEvent() {
            setMessageType(MessageType.JoinZoneEvent);
        }
        public function set zone(z:Zone):void {

            _zone = z;
        }
        public function get zone():Zone {
            return _zone;
        }
        public function setZoneId(num:Number):void {

            zoneId = num;
        }
        public function getZoneId():Number {
            return zoneId;
        }
        public function setZoneName(str:String):void {

            zoneName = str;
        }
        public function getZoneName():String {
            return zoneName;
        }
        public function setRooms(arr:Array):void {

            rooms = arr;
        }
        public function getRooms():Array {
            return rooms;
        }
    }
}
