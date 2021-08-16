package com.electrotank.electroserver4.message.request {
    import com.electrotank.electroserver4.message.request.*;
    import com.electrotank.electroserver4.message.MessageType;
    import com.electrotank.electroserver4.room.Room;
    import com.electrotank.electroserver4.message.ValidationResponse;
    /**
     * This class is used to request joining a room. The CreateRoomRequest class is often used to create <i>or</i> join a room. Many developers don't use this request. When joining a room using this request the minimum information that you need to provide is the roomId and zoneId, and a password if required.<br/>
     * <br>When joining a room there are many things that you can be subscribed to receive events. 
     * <br><br>Subscription properties when joining a room (all of the following default to true):
     * <ul><li><code>setIsReceivingRoomListUpdates(bool)</code> - If true, you receive ZoneUpdateEvent events when rooms are added to or removed from this zone, or when the the total count of users in one of those rooms changes.
     * <li><code>setIsReceivingUserListUpdates(bool)</code> - If true, you receive UserListUpdateEvent events when the user list in your room changes.
     * <li><code>setIsReceivingRoomVariableUpdates(bool)</code> - If true, you receive the initial room variable list for your room and RoomVariableUpdateEvent events when room variables in your room are created, removed, or modified.
     * <li><code>setIsReceivingUserVariableUpdates(bool)</code> - If true, you receive the initial user variable list for new users joinin your room as well as UserVariableUpdateEvent events when new user variables are created, removed, or modified on a user.
     * <li><code>setIsReceivingVideoEvents(bool)</code> - If true, you receive UserListUpdateEvent event when users in the room start or stop streaming live video to the server. The stream name is part of that event.
     * <li><code>setIsReceivingRoomDetailUpdates(bool)</code> - If true, you receive UpdateRoomDetailsEvent events when room properties such as capacity, description, or the password changes.
     */
    
    public class JoinRoomRequest extends RequestImpl {

        private var zoneId:Number;
        private var roomId:Number;
        private var password:String;
        private var isReceivingRoomListUpdates:Boolean;
        private var isReceivingUserListUpdates:Boolean;
        private var isReceivingRoomVariableUpdates:Boolean;
        private var isReceivingUserVariableUpdates:Boolean;
        private var isReceivingVideoEvents:Boolean;
        private var isReceivingRoomDetailUpdates:Boolean;
        private var room:Room;
        /**
         * Creates a new instance of the JoinRoomRequest class.
         */
        public function JoinRoomRequest() {
            setMessageType(MessageType.JoinRoomRequest);
            setRoomId(-1);
            setZoneId(-1);
            setIsReceivingRoomListUpdates(true);
            setIsReceivingRoomDetailUpdates(true);
            setIsReceivingUserListUpdates(true);
            setIsReceivingRoomVariableUpdates(true);
            setIsReceivingUserVariableUpdates(true);
            setIsReceivingVideoEvents(true);
        }
        /**
         * The default is true. If true, you will receive UpdateRoomDetailsEvent events for all rooms in your zone. That includes description, capacity, password status, and room name.
         * @param    Set to true if you want to receive these updates.
         */
        public function setIsReceivingRoomDetailUpdates(isReceiving:Boolean):void {

            this.isReceivingRoomDetailUpdates = isReceiving;
        }
        /**
         * Returns the isReceivingRoomDetailUpdates property.
         * @return Returns the isReceivingRoomDetailUpdates property.
         */
        public function getIsReceivingRoomDetailUpdates():Boolean {
            return isReceivingRoomDetailUpdates;
        }
        public function getRoom():Room {
            return room;
        }
        /**
         * Returns the isReceivingVideoUpdates property.
         * @return Returns the isReceivingVideoUpdates property.
         */
        public function getIsReceivingVideoEvents():Boolean {
            return this.isReceivingVideoEvents;
        }
        /**
         * Default is true. If true, you will receive UserListUpdateEvent events when users in your room start or stop publishing live streams to the server.
         * @param    Set to true if you want to receive these events.
         */
        public function setIsReceivingVideoEvents(isReceiving:Boolean):void {

            this.isReceivingVideoEvents = isReceiving;
        }
        /**
         * The default is true. This is a user-level property used when joining a room. You will find this property in the JoinRoomRequest as well. If true, the user will receive add/remove updaes to the room list for the current zone. This is part of the ZoneUpdateEvent.
         * @param    Pass in true to receive room list updates with the ZoneUpdateEvent.
         */
        public function setIsReceivingRoomListUpdates(receivingRoomListUpdates:Boolean):void {

            isReceivingRoomListUpdates = receivingRoomListUpdates;
        }
        /**
         * Returns true if the user will receive room list updates.
         * @return Returns true if the user will receive room list updates.
         */
        public function getIsReceivingRoomListUpdates():Boolean {
            return isReceivingRoomListUpdates;
        }
        /**
         * The default is true. This is a user-level property used when joining a room. You will find this property in the JoinRoomRequest as well. If true, the user will receive updates to the user list for this room through the UserListUpdateEvent.
         * @param    Pass in true to receive UserListUpdateEvent events for this new room.
         */
        public function setIsReceivingUserListUpdates(receivingUserListUpdates:Boolean):void {

            isReceivingUserListUpdates = receivingUserListUpdates;
        }
        /**
         * Returns true if the user is set up to receive UserListUpdateEvent events for the new room.
         * @return Returns true if the user is set up to receive UserListUpdateEvent events for the new room.
         */
        public function getIsReceivingUserListUpdates():Boolean {
            return isReceivingUserListUpdates;
        }
        /**
         * The default is true. This is a user-level property used when joining a room. You will find this property in the JoinRoomRequest as well. If true, the user will receive RoomVariableUpdateEvent events for the newly created room.
         * @param    Pass in true to receive RoomVariableUpdateEvent events.
         */
        public function setIsReceivingRoomVariableUpdates(receivingRoomVariableUpdates:Boolean):void {

            isReceivingRoomVariableUpdates = receivingRoomVariableUpdates;
        }
        /**
         * Returns true if the user is set to receive RoomVariableUpdateEvent events.
         * @return Returns true if the user is set to receive RoomVariableUpdateEvent events.
         */
        public function getIsReceivingRoomVariableUpdates():Boolean {
            return isReceivingRoomVariableUpdates;
        }
        /**
         * The default is true. This is a user-level property used when joining a room. You will find this property in the JoinRoomRequest as well. If true, the user will receive UserVariableUpdateEvent events.
         * @param    Pass in true to receive UserVariableUpdateEvent events for the newly created room.
         */
        public function setIsReceivingUserVariableUpdates(receivingUserVariableUpdates:Boolean):void {

            isReceivingUserVariableUpdates = receivingUserVariableUpdates;
        }
        /**
         * Returns true if the user is set to receive UserVariableUpdateEvent events in the new room.
         * @return Returns true if the user is set to receive UserVariableUpdateEvent events in the new room.
         */
        public function getIsReceivingUserVariableUpdates():Boolean {
            return isReceivingUserVariableUpdates;
        }
    
     override public function validate():ValidationResponse {    
            var valid:Boolean = true;
            var problems:Array = new Array();
            var vr:ValidationResponse = new ValidationResponse(valid, problems);
            return vr;
        }
        
        /**
         * The zone id of the zone the holds the room.
         * @param    The id of the zone that holds the room.
         */
        public function setZoneId(zId:Number):void {

            zoneId = zId;
        }
        /**
         * Gets the id of the zone that holds the room.
         * @return Returns the id of the zone that holds the room.
         */
        public function getZoneId():Number {
            return zoneId;
        }
        /**
         * Sets the id of the room that you are trying to join.
         * @param    The id of the room that you are trying to join.
         */
        public function setRoomId(rId:Number):void {

            roomId = rId;
        }
        /**
         * Gets the id of the room that you are trying to join.
         * @return Retunrs the id of the room that youa re trying to join.
         */
        public function getRoomId():Number {
            return roomId;
        }
        /**
         * Sets the optional password for the room that you are trying to join.
         * @param    The password needed to joint the room.
         */
        public function setPassword(pwd:String):void {

            password = pwd;
        }
        /**
         * Returns the password you are using to join the room.
         * @return Returns the password you are using to join the room.
         */
        public function getPassword():String {
            return password;
        }
    }
}
