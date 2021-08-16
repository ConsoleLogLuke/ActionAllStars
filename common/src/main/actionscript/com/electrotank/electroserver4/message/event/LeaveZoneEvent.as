package com.electrotank.electroserver4.message.event {
    import com.electrotank.electroserver4.message.MessageImpl;
    import com.electrotank.electroserver4.message.event.*;
    import com.electrotank.electroserver4.message.*;
    import com.electrotank.electroserver4.zone.*;
    
    public class LeaveZoneEvent extends EventImpl {

        private var zoneId:Number;
        private var _zone:Zone;
        public function LeaveZoneEvent() {
            setMessageType(MessageType.LeaveZoneEvent);
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
    }
}
