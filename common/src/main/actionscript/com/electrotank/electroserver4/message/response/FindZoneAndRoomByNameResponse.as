package com.electrotank.electroserver4.message.response {
    import com.electrotank.electroserver4.message.MessageImpl;
    import com.electrotank.electroserver4.message.response.*;
    import com.electrotank.electroserver4.message.*;
    import com.electrotank.electroserver4.room.*;
    
    public class FindZoneAndRoomByNameResponse extends ResponseImpl {

        private var roomAndZoneList:Array;
        public function FindZoneAndRoomByNameResponse() {
            setMessageType(MessageType.FindZoneAndRoomByNameResponse);
        }
        public function setRoomAndZoneList(arr:Array):void {

            roomAndZoneList = arr;
        }
        public function getRoomAndZoneList():Array {
            return roomAndZoneList;
        }
    }
}
