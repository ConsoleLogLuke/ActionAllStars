package com.electrotank.electroserver4.message.response {
    import com.electrotank.electroserver4.message.MessageImpl;
    import com.electrotank.electroserver4.message.response.*;
    import com.electrotank.electroserver4.message.*;
    import com.electrotank.electroserver4.room.*;
    
    public class GetRoomsInZoneResponse extends ResponseImpl {

        private var zoneId:Number;
        private var zoneName:String;
        private var rooms:Array;
        public function GetRoomsInZoneResponse() {
            setMessageType(MessageType.GetRoomsInZoneResponse);
            rooms = new Array();
            setZoneId(-1);
        }
        public function setZoneName(str:String):void {

            zoneName = str;
        }
        public function getZoneName():String {
            return zoneName;
        }
        public function setZoneId(num:Number):void {

            zoneId = num;
        }
        public function getZoneId():Number {
            return zoneId;
        }
        public function addRoom(room:Room):void {

            getRooms().push(room);
        }
        public function getRooms():Array {
            return rooms;
        }
    }
}
