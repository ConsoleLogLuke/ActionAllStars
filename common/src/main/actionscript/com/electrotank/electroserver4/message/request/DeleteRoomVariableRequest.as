package com.electrotank.electroserver4.message.request {
    import com.electrotank.electroserver4.message.request.*;
    import com.electrotank.electroserver4.message.MessageType;
    import com.electrotank.electroserver4.message.ValidationResponse;
    /**
     * This class allows you to delete a room variable for a room that you are in. A locked room variable can still be deleted.
     * @example
     * This example shows how to delete a room variable and capture the event. The event is fired when a variable is created, updated, or deleted.
     * <listing>
     import com.electrotank.electroserver4.ElectroServer;
    import com.electrotank.electroserver4.entities.RoomVariable;
    import com.electrotank.electroserver4.esobject.EsObject;
    import com.electrotank.electroserver4.message.event.RoomVariableUpdateEvent;
    import com.electrotank.electroserver4.message.MessageType;
    import com.electrotank.electroserver4.message.request.DeleteRoomVariableRequest;
    import com.electrotank.electroserver4.room.Room;    
    //
    var es:ElectroServer;//Assume this was created, connection established, and login established already
    var myRoom:Room;//A reference to some room you are in.
    //
    function init():void {
        es.addEventListener(MessageType.RoomVariableUpdateEvent, "onRoomVariableUpdateEvent", this);
    }
    function deleteRoomVariable():void {
        var drr:DeleteRoomVariableRequest = new DeleteRoomVariableRequest();
        drr.setName("MusicInfo");
        drr.setRoomId(myRoom.getRoomId());
        drr.setZoneId(myRoom.getZone().getZoneId());
        //
        es.send(drr);
    }
    function onRoomVariableUpdateEvent(e:RoomVariableUpdateEvent):void {
        //name of the variable affected
        var varName:String = e.getName();
        //reference to the room that holds the variable
        var room:Room = es.getZoneManager().getZoneById(e.getZoneId()).getRoomById(e.getRoomId());
        trace("Room variable name: "+varName);
        switch (e.getUpdateAction()) {
            case RoomVariableUpdateEvent.VariableCreated:
                trace("Variable created");
                var rv:RoomVariable = room.getRoomVariable(name);
                trace("Room variable value: "+rv.getValue());//Will just trace out an object reference of the EsObject;
                break;
            case RoomVariableUpdateEvent.VariableUpdated:
                trace("Variable updated");
                var rv:RoomVariable = room.getRoomVariable(name);
                trace("Room variable value: "+rv.getValue());//Will just trace out an object reference of the EsObject;
                break;
                break;
            case RoomVariableUpdateEvent.VariableDeleted:
                trace("Variable deleted");
                break;
            default:
                trace("Action not handled: "+e.getUpdateAction());
                break;
        }
    }
    init();
    deleteRoomVariable();
    * </listing>
    * */
    
    public class DeleteRoomVariableRequest extends RequestImpl {

        private var roomId:Number;
        private var zoneId:Number;
        private var name:String;
        /**
         * Creates a new instance of the DeleteRoomVariableRequest class.
         */
        public function DeleteRoomVariableRequest() {
            setMessageType(MessageType.DeleteRoomVariableRequest);
        }
     override public function validate():ValidationResponse {    
            var valid:Boolean = true;
            var problems:Array = new Array();
            var vr:ValidationResponse = new ValidationResponse(valid, problems);
            return vr;
        }
        /**
         * The name of the room variable to delete.
         * @param    Name of the room variable to delete.
         */
        public function setName(name:String):void {

            this.name = name;
        }
        /**
         * The name of the room variable to delete.
         * @return  Returns the name of the room variable to delete.
         */
        public function getName():String {
            return name;
        }
        /**
         * The id of the room that contains the room variable.
         * @param    The id of the room that contains the room variable.
         */
        public function setRoomId(rId:Number):void {

            roomId = rId;
        }
        /**
         * The id of the room that contains the room variable.
         * @return The id of the room that contains the room variable.
         */
        public function getRoomId():Number {
            return roomId;
        }
        /**
         * The id of the zone that contains the room.
         * @param    The id of the zone that contains the room.
         */
        public function setZoneId(zId:Number):void {

            zoneId = zId;
        }
        /**
         * The id of the zone that contains the room.
         * @return The id of the zone that contains the room.
         */
        public function getZoneId():Number {
            return zoneId;
        }
    }
}
