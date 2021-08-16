package com.electrotank.electroserver4.message.request {
    import com.electrotank.electroserver4.message.request.*;
    import com.electrotank.electroserver4.message.MessageType;
    import com.electrotank.electroserver4.esobject.EsObject;
    import com.electrotank.electroserver4.message.ValidationResponse;
    /**
     * This class allows you to create a room variable. A room variable is a variable scoped to a room that you are in and stored on the server. All users in your room receive these variables on entering the room, and receive create, update, and delete events on variables after they are already in the room. 
     * <br><br>Room variables have a string name and store an EsObject value. Room variables have the boolean properties of locked and persistent. The default values are locked=false and persistent=false. If locked=true, then the value cannot be modified until unlocked (it can still be deleted). If locked=false, then it can be modified. If persistent=false, then when the user that created it leaves the room the variable is removed. If persistent=true, then when the user leaves the room the variable stays.
     * @example
     * This example shows how to create a room variable and capture the event. The event is fired when a variable is created, updated, or deleted.
     * <listing>
     import com.electrotank.electroserver4.ElectroServer;
    import com.electrotank.electroserver4.entities.RoomVariable;
    import com.electrotank.electroserver4.esobject.EsObject;
    import com.electrotank.electroserver4.message.event.RoomVariableUpdateEvent;
    import com.electrotank.electroserver4.message.MessageType;
    import com.electrotank.electroserver4.message.request.CreateRoomVariableRequest;
    import com.electrotank.electroserver4.room.Room;    
    //
    var es:ElectroServer;//Assume this was created, connection established, and login established already
    var myRoom:Room;//A reference to some room you are in.
    //
    function init():void {
        es.addEventListener(MessageType.RoomVariableUpdateEvent, "onRoomVariableUpdateEvent", this);
    }
    function createRoomVariable():void {
        //The value of the variable is an EsObject
        var eob:EsObject = new EsObject();
        eob.setString("LoopName", "Happy.mp3");
        eob.setInteger("Volume", 80);
        //
        var crr:CreateRoomVariableRequest = new CreateRoomVariableRequest();
        crr.setName("MusicInfo");
        crr.setValue(eob);
        crr.setRoomId(myRoom.getRoomId());
        crr.setZoneId(myRoom.getZone().getZoneId());
        crr.setLocked(false);
        crr.setPersistent(false);
        //
        es.send(crr);
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
    createRoomVariable();
    * </listing>
     */
    
    public class CreateRoomVariableRequest extends RequestImpl {

        private var roomId:Number;
        private var zoneId:Number;
        private var name:String;
        private var value:EsObject;
        private var locked:Boolean;
        private var persistent:Boolean;
        /**
         * Creates a new instance of the CrateRoomVariableRequest class.
         */
        public function CreateRoomVariableRequest() {
            setMessageType(MessageType.CreateRoomVariableRequest);
            setLocked(false);
            setPersistent(false);
        }
     override public function validate():ValidationResponse {    
            var valid:Boolean = true;
            var problems:Array = new Array();
            var vr:ValidationResponse = new ValidationResponse(valid, problems);
            return vr;
        }
        /**
         * Sets the name of the new room variable to crate.
         * @param    The name of the new variable.
         */
        public function setName(name:String):void {

            this.name = name;
        }
        /**
         * Returns the name of the new variable.
         * @return Returns the name of the new variable
         */
        public function getName():String {
            return name;
        }
        /**
         * Sets the EsObject value of the room variable.
         * @param    The EsObject value of the room variable.
         */
        public function setValue(eob:EsObject):void {

            value = eob;
        }
        /**
         * Gets the EsObject value of the room variable.
         * @return Returns the EsObject value of the room variable.
         */
        public function getValue():EsObject {
            return value;
        }
        /**
         * The default is false. If true, then the room variable cannot be udpated
         * @param    val
         */
        public function setLocked(locked:Boolean):void {

            this.locked = locked;
        }
        /**
         * 
         * @return
         */
        public function getLocked():Boolean {
            return locked;
        }
        public function setPersistent(val:Boolean):void {

            persistent = val;
        }
        public function getPersistent():Boolean {
            return persistent;
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
