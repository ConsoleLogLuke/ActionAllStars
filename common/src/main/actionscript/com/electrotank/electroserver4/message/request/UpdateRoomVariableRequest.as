package com.electrotank.electroserver4.message.request {
    import com.electrotank.electroserver4.message.request.*;
    import com.electrotank.electroserver4.message.MessageType;
    import com.electrotank.electroserver4.esobject.EsObject;
    import com.electrotank.electroserver4.message.ValidationResponse;
    /**
     * This class allows you to update an existing room variable. You identify a room variable by room id, zone id, and name. You can update a variables value and locked property. The value of the variable is an EsObject.
     * @example
     * This example shows how to update a room variable, and how to capture the RoomVariableUpdateEvent to see what has changed.
     * <listing>
    import com.electrotank.electroserver4.entities.RoomVariable;
    import com.electrotank.electroserver4.esobject.EsObject;
    import com.electrotank.electroserver4.message.event.RoomVariableUpdateEvent;
    import com.electrotank.electroserver4.message.MessageType;
    import com.electrotank.electroserver4.message.request.UpdateRoomVariableRequest;
    import com.electrotank.electroserver4.room.Room;
    //
    var es:ElectroServer;//Assume this was created, connection established, and login established already
    var myRoom:Room;//A reference to some room you are in.
    //
    function init():void {
        es.addEventListener(MessageType.RoomVariableUpdateEvent, "onRoomVariableUpdateEvent", this);
    }
    function updateRoomVariable():void {
        //The value of the variable is an EsObject
        var eob:EsObject = new EsObject();
        eob.setString("LoopName", "Sad.mp3");
        eob.setInteger("Volume", 50);
        //
        var urvr:UpdateRoomVariableRequest = new UpdateRoomVariableRequest();
        urvr.setName("MusicInfo");
        urvr.setValue(eob);
        urvr.setRoomId(myRoom.getRoomId());
        urvr.setZoneId(myRoom.getZone().getZoneId());
        urvr.setLocked(true);
        //
        es.send(urvr);
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
    updateRoomVariable();
     * </listing>
     */
    
    public class UpdateRoomVariableRequest extends RequestImpl {

        private var roomId:Number;
        private var zoneId:Number;
        private var name:String;
        private var value:EsObject;
        private var locked:Boolean;
        private var lockChanged:Boolean;
        private var valueChanged:Boolean;
        /**
         * Creates a new instance of the UpdateRoomVariableRequest class.
         */
        public function UpdateRoomVariableRequest() {
            setMessageType(MessageType.UpdateRoomVariableRequest);
            lockChanged = false;
            valueChanged = false;
        }
    
     override public function validate():ValidationResponse {    
            var valid:Boolean = true;
            var problems:Array = new Array();
            var vr:ValidationResponse = new ValidationResponse(valid, problems);
            return vr;
        }
        /**
         * @private
         */
        public function hasValueChanged():Boolean {
            return valueChanged;
        }
        /**
         * Sets the new value for the room variable.
         * @param    The new value for the room variable.
         */
        public function setValue(value:EsObject):void {

            valueChanged = true;
            this.value = value;
        }
        /**
         * @private
         */
        public function hasLockStatusChanged():Boolean {
            return lockChanged;
        }
        /**
         * Specifies the name of the room variable to be updated.
         * @param    The name of the room variable to be updated.
         */
        public function setName(name:String):void {

            this.name = name;
        }
        /**
         * Gets the name of the room variable.
         * @return The name of the room variable.
         */
        public function getName():String {
            return name;
        }
        /**
         * Gets the new value of the room variable.
         * @return
         */
        public function getValue():EsObject {
            return value;
        }
        /**
         * Gets the locked property.
         * @return The locked property.
         */
        public function getLocked():Boolean {
            return locked;
        }
        /**
         * Sets the new locked property.
         * @param    The new locked property.
         */
        public function setLocked(locked:Boolean):void {

            lockChanged = true;
            this.locked = locked;
        }
        /**
         * Specifies the id of the room that has this variable.
         * @param    The id of the room that has the variable.
         */
        public function setRoomId(rId:Number):void {

            roomId = rId;
        }
        /**
         * Gets the id of the room that has the variable.
         * @return
         */
        public function getRoomId():Number {
            return roomId;
        }
        /**
         * Specifies the id of the zone that holds the room.
         * @param    The id of the zone that holds the room.
         */
        public function setZoneId(zId:Number):void {

            zoneId = zId;
        }
        /**
         * The id of the zone that holds the room.
         * @return The id of the zone that holds the room.
         */
        public function getZoneId():Number {
            return zoneId;
        }
    }
}
