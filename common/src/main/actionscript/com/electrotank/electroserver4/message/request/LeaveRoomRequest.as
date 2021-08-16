package com.electrotank.electroserver4.message.request {
    import com.electrotank.electroserver4.message.request.*;
    import com.electrotank.electroserver4.message.MessageType;
    import com.electrotank.electroserver4.message.ValidationResponse;
    /**
     * This request allows you to leave a room. In ElectroServer 4 you can exist in multiple rooms at once, or no rooms. When you join a new room you need to request to leave the previous room if you no longer want to be in that room. Just build the request, give it the room and zone ids, and send it. When you've been removed from a room you'll receive a RoomLeftEvent. If you have also left the zone then you'll receive a ZoneLeftEvent. You can be moved into our out of rooms by server-side plugins or the Game Manager as well.
     * @example
        This example shows how to leave a room.
        <listing>
    import com.electrotank.electroserver4.ElectroServer;
    import com.electrotank.electroserver4.message.event.LeaveRoomEvent;
    import com.electrotank.electroserver4.message.MessageType;
    import com.electrotank.electroserver4.message.request.LeaveRoomRequest;
    import com.electrotank.electroserver4.room.Room;
    
    //
    var es:ElectroServer;//assume this is created elsewhere and a connection and login occurred.
    var myRoom:Room;//some room you are in
    function init():void {
        es.addEventListener(MessageType.LeaveRoomEvent, "onLeaveRoomEvent", this);
    }
    function leaveRoom():void {
        var lrr:LeaveRoomRequest = new LeaveRoomRequest();
        lrr.setRoomId(myRoom.getRoomId());
        es.send(lrr);
    }
    function onLeaveRoomEvent(e:LeaveRoomEvent):void {
        trace("Left room: "+e.getRoomId());
    }
    init();
    leaveRoom();
        </listing>
     */
    
    public class LeaveRoomRequest extends RequestImpl {

        private var roomId:Number;
        private var zoneId:Number;
        /**
         * Creates a new instance of the LeaveRoomRequest class.
         */
        public function LeaveRoomRequest() {
            setMessageType(MessageType.LeaveRoomRequest);
        }
    
     override public function validate():ValidationResponse {    
            var valid:Boolean = true;
            var problems:Array = new Array();
            var vr:ValidationResponse = new ValidationResponse(valid, problems);
            return vr;
        }
        /**
         * Sets the id of the room that you want to leave. 
         * @param    The id of the room you want to leave.
         */
        public function setRoomId(rId:Number):void {

            roomId = rId;
        }
        /**
         * Returns the id of the room you want to leave.
         * @return The id of the room you want to leave.
         */
        public function getRoomId():Number {
            return roomId;
        }
        /**
         * Sets the id of the zone you want to leave.
         * @param    The id of the zone you want to leave.
         */
        public function setZoneId(zId:Number):void {

            zoneId = zId;
        }
        /**
         * Returns the id of the zone you want to leave.
         * @return The id of the zone you want to leave.
         */
        public function getZoneId():Number {
            return zoneId;
        }
    }
}
