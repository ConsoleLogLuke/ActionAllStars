package com.electrotank.electroserver4.message.response {
    import com.electrotank.electroserver4.message.MessageImpl;
    import com.electrotank.electroserver4.message.response.*;
    import com.electrotank.electroserver4.message.*;
    
    public class GetUsersInRoomResponse extends ResponseImpl {

        private var users:Array;
        private var roomId:Number;
        private var zoneId:Number;
        public function GetUsersInRoomResponse() {
            setMessageType(MessageType.GetUsersInRoomResponse);
        }
        public function setUsers(arr:Array):void {

            users = arr;
        }
        public function getUsers():Array {
            return users;
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
