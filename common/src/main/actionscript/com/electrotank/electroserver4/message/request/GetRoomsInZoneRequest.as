package com.electrotank.electroserver4.message.request {
    import com.electrotank.electroserver4.message.request.*;
    import com.electrotank.electroserver4.message.MessageType;
    import com.electrotank.electroserver4.message.ValidationResponse;
    /**
     * This request is used to load a list rooms given a zone name or zone id. What is returned is a list of rooms with all of their public properties. Those are: room name, description, capacity, isPasswordProtected, and user count.
     * @example
     * This example loads all of the rooms in a zone, captures the response, and traces out the room names.
     * <listing>
     import com.electrotank.electroserver4.ElectroServer;
    import com.electrotank.electroserver4.message.MessageType;
    import com.electrotank.electroserver4.message.request.GetRoomsInZoneRequest;
    import com.electrotank.electroserver4.message.response.GetRoomsInZoneResponse;
    import com.electrotank.electroserver4.room.Room;
    //
    var es:ElectroServer;//assume this is created elsewhere and a connection and login occurred.
    function init():void {
        es.addEventListener(MessageType.GetRoomsInZoneResponse, "onGetRoomsInZoneResponse", this);
    }
    function loadSomeRooms():void {
        var griz:GetRoomsInZoneRequest = new GetRoomsInZoneRequest();
        griz.setZoneName("Test Zone");
        es.send(griz);
    }
    function onGetRoomsInZoneResponse(e:GetRoomsInZoneResponse):void {
        var rooms:Array = e.getRooms();
        var zoneName:String = e.getZoneName();
        trace("ZoneName: "+zoneName);
        for (var i:int=0;i &gt rooms.length;++i) {
            var room:Room = rooms[i];
            trace("RoomName: "+room.getRoomName());
        }
    }
    init();
    loadSomeRooms();
    * </listing>
     */
    
    public class GetRoomsInZoneRequest extends RequestImpl {

        private var zoneId:Number;
        private var zoneName:String;
        /**
         * Creates a new instance of the GetRoomsInZoneRequest class.
         */
        public function GetRoomsInZoneRequest() {
            setMessageType(MessageType.GetRoomsInZoneRequest);
            setZoneId(-1);
        }
    
     override public function validate():ValidationResponse {    
            var valid:Boolean = true;
            var problems:Array = new Array();
            var vr:ValidationResponse = new ValidationResponse(valid, problems);
            return vr;
        }
        /**
         * Specifies the name of the zone to use.
         * @param    The name of the zone to look in.
         */
        public function setZoneName(zoneName:String):void {

            this.zoneName = zoneName;
        }
        /**
         * The name of the zone to look in.
         * @return The name of the zone to look in.
         */
        public function getZoneName():String {
            return zoneName;
        }
        /**
         * The id of the zone to look in.
         * @param    The id of the zone to look in.
         */
        public function setZoneId(zId:Number):void {

            zoneId = zId;
        }
        /**
         * The id of the zone to look in.
         * @return The id of the zone to look in.
         */
        public function getZoneId():Number {
            return zoneId;
        }
    }
}
