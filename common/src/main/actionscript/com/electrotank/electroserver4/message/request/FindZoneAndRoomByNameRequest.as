package com.electrotank.electroserver4.message.request {
    import com.electrotank.electroserver4.message.request.*;
    import com.electrotank.electroserver4.message.MessageType;
    import com.electrotank.electroserver4.message.ValidationResponse;
    /**
     * Find the room id and zone id for a room and zone given the room and zone names.
     */
    
    public class FindZoneAndRoomByNameRequest extends RequestImpl {

        private var zoneName:String;
        private var roomName:String;
        public function FindZoneAndRoomByNameRequest() {
            setMessageType(MessageType.FindZoneAndRoomByNameRequest);
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
    }
}
