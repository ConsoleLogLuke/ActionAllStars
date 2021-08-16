package com.electrotank.electroserver4.message.event {
    import com.electrotank.electroserver4.message.MessageImpl;
    import com.electrotank.electroserver4.message.event.*;
    import com.electrotank.electroserver4.message.*;
    import com.electrotank.electroserver4.room.*;
    
    public class LeaveRoomEvent extends EventImpl {

        private var roomId:Number;
        private var zoneId:Number;
        private var _room:Room;
        public function LeaveRoomEvent() {
            setMessageType(MessageType.LeaveRoomEvent);
        }
        public function set room(r:Room):void {

            _room = r;
        }
        public function get room():Room {
            return _room;
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
