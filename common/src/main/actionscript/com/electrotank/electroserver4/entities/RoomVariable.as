package com.electrotank.electroserver4.entities {
    import com.electrotank.electroserver4.entities.*;
    import com.electrotank.electroserver4.esobject.EsObject;
    /**
     * This class is used to represent a room variable. A room variable is a variable scoped to a room that you are in and stored on the server. All users in your room receive these variables on entering the room, and receive create, update, and delete events on variables after they are already in the room. 
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
    
    public class RoomVariable {

        private var persistent:Boolean;
        private var locked:Boolean;
        private var name:String;
        private var value:EsObject;
        /**
         * This class is used to represent a room variable. It is created internally to the API. Creating an instance of this class yourself isn't common.
         * @param    Name of the variable.
         * @param    EsObject value of the variable.
         * @param    True or false. If true, then the variable will stay around after the user that created it leaves. If false, then the variable will die when the user leaves.
         * @param    True or false. If true, then the variable's value cannot be changed until unlocked. It can still be deleted when locked.
         */
        public function RoomVariable(tmpname:String, tmpvalue:EsObject, perst:Boolean, lkd:Boolean) {
            setName(tmpname);
            setValue(tmpvalue);
            setPersistent(perst);
            setLocked(lkd);
        }
        /**
         * Sets the variable name.
         * @param    The variable name.
         */
        public function setName(name:String):void {

            this.name = name;
        }
        /**
         * Gets the variable name.
         * @return The variable name.
         */
        public function getName():String {
            return name;
        }
        /**
         * Sets the variable value.
         * @param    The variable value.
         */
        public function setValue(value:EsObject):void {

            this.value = value;
        }
        /**
         * Gets the variable value.
         * @return The variable value.
         */
        public function getValue():EsObject {
            return value;
        }
        /**
         * Sets the persistent property of the variable. If persistent is true the variable remains when the user leaves the room, else it is removed.
         * @param    True or false.
         */
        public function setPersistent(persistent:Boolean):void {

            this.persistent = persistent;
        }
        /**
         * Returns the persistent property of the variable.
         * @return True or false.
         */
        public function getPersistent():Boolean {
            return persistent;
        }
        /**
         * Sets the locked property of the variable. If locked is true then the variable's value cannot be updated. If false it can be updated.
         * @param    True or false.
         */
        public function setLocked(locked:Boolean):void {

            this.locked = locked;
        }
        /**
         * Gets the variable's locked property.
         * @return True or false.
         */
        public function getLocked():Boolean {
            return locked;
        }
    }
}
