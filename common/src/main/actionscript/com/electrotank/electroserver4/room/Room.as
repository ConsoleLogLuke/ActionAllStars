package com.electrotank.electroserver4.room {
    import com.electrotank.electroserver4.room.*;
    import com.electrotank.electroserver4.user.*;
    import com.electrotank.electroserver4.zone.Zone;
    import com.electrotank.electroserver4.entities.*;
    /**
     * This class represents a room. This room class is internally created by the API to represent rooms. If you are joined to a room and have all of the default settings, then all properties in this room should stay up to date. When creating or joining a room you have the choice to subscribe to many room-based events, such as room variable and user variable updates.
     * <br/><br/>If you are viewing a room class instance for a room that you are not in, then only the public information will be populated. That includes:
     * <ul>
     * <li>Room Id - The id of the room.
     * <li>Zone Id - The id of the zone that holds the room.
     * <li>Description - The optional string description of the room.
     * <li>isPasswordProtected - If this is true that means a password is needed to join.
     * <li>User Count - The number of users in the room.
     * </ul>
     */
    
    public class Room {

        private var zoneId:Number;
        private var roomId:Number;
        private var roomName:String;
        private var userCount:Number;
        private var users:Array;
        private var usersById:Object;
        private var zone:Zone;
        private var hasPassword:Boolean;
        private var description:String;
        private var capacity:Number;
        private var isHidden:Boolean;
        private var password:String;
        private var roomVariables:Array;
        private var roomVariablesByName:Object;
        private var isJoined:Boolean;
        /**
         * Creates a new instance of the Room class.
         */
        public function Room() {
            users = new Array();
            usersById = new Object();
            roomVariables = new Array();
            roomVariablesByName = new Object();
            setIsJoined(false);
        }
        /**
         * Returns true if you are joined to this room, false otherwise.
         * @return True or false.
         */
        public function getIsJoined():Boolean {
            return this.isJoined;
        }
        /**
         * Sets the isJoined property of the class intance. It is set to true if you are joined to the room.
         * @param    True or false.
         */
        public function setIsJoined(isJoined:Boolean):void {

            this.isJoined = isJoined;
        }
        /**
         * Checks to see if a room variable exist based on a name. If it exists then the method returns true. If it does not exist, then the method returns false.
         * @param    The name of the room variable.
         * @return True or false.
         */
        public function doesRoomVariableExist(name:String):Boolean {
            return roomVariablesByName[name] != null;
        }
        /**
         * Used internally to add a room variable.
         * @param    Room variable to add to the room.
         */
        public function addRoomVariable(rv:RoomVariable):void {

            getRoomVariables().push(rv);
            roomVariablesByName[rv.getName()] = rv;
        }
        /**
         * Used internally to remove a room variable.
         * @param    Name of room variable to remove.
         */
        public function removeRoomVariable(name:String):void {

            for (var i:Number=0;i<getRoomVariables().length;++i) {
                var rv:RoomVariable = getRoomVariables()[i];
                if (rv.getName() == name) {
                    getRoomVariables().splice(i, 1);
                    break;
                }
            }
            delete roomVariablesByName[name];
        }
        /**
         * Finds a room variable based on the name and returns it.
         * @param    Name of the room variable.
         * @return Room variable instance.
         */
        public function getRoomVariable(name:String):RoomVariable {
            return roomVariablesByName[name];
        }
        /**
         * Sets the entire list of room variables.
         * @param    List of room variables.
         */
        public function setRoomVariables(arr:Array):void {

            roomVariables = new Array();
            for (var i:Number=0;i<arr.length;++i) {
                var rv:RoomVariable = arr[i];
                addRoomVariable(rv);
            }
        }
        /**
         * Gets the entire list of room variables.
         * @return The entire list of room variables.
         */
        public function getRoomVariables():Array {
            return roomVariables;
        }
        /**
         * Sets the room's password.
         * @param    str
         */
        public function setPassword(str:String):void {

            password = str;
        }
        /**
         * Gets the room's password.
         * @return The room's password.
         */
        public function getPassword():String {
            return password;
        }
        /**
         * Sets the isHidden property of the room. If isHidden is true, then the room does not appear to exist to users not in the room.
         * @param    True or false.
         */
        public function setIsHidden(val:Boolean):void {

            isHidden = val;
        }
        /**
         * Gets the hidden status.
         * @return True or false.
         */
        public function getIsHidden():Boolean {
            return isHidden;
        }
        /**
         * Sets the capacity of the room. If -1 then there is no limit. If 1 or greater, then that is the total number of users allowed to join.
         * @param    The room capacity.
         */
        public function setCapacity(num:Number):void {

            capacity = num;
        }
        /**
         * Gets the room capacity. If -1 then there is no limit.
         * @return Gets the room capacity.
         */
        public function getCapacity():Number {
            return capacity;
        }
        /**
         * Sets the description property of the room.
         * @param    The description property of the room.
         */
        public function setDescription(des:String):void {

            description = des;
        }
        /**
         * Gets the description property of the room.
         * @return The description property of the room.
         */
        public function getDescription():String {
            return description;
        }
        /**
         * Sets the hasPassword property of the room. If true then a password is required to join the room.
         * @param    True or false.
         */
        public function setHasPassword(val:Boolean):void {

            hasPassword = val;
        }
        /**
         * Gets the hasPassword property.
         * @return The hasPassword property.
         */
        public function getHasPassword():Boolean {
            return hasPassword;
        }
        /**
         * Adds a usre to the room. This is used internally by the API.
         * @param    The user to be added to the room.
         */
        public function addUser(user:User):void {

            if (getUserById(user.getUserId()) == null) {
                usersById[user.getUserId()] = user;
                getUsers().push(user);
            } else {
                trace("Error: tried to add a user and that id is in use. userId: "+user.getUserId()+" - userName: "+user.getUserName());
            }
            setUserCount(getUsers().length);
        }
        /**
         * Removes a user from the room.
         * @param    The id of the user to remove.
         */
        public function removeUser(userId:String):void {

            var user:User = getUserById(userId);
            delete usersById[userId];
            for (var i:Number=0;i<getUsers().length;++i) {
                if (user == getUsers()[i]) {
                    getUsers().splice(i, 1);
                    break;
                }
            }
            setUserCount(getUsers().length);
        }
        /**
         * Sets the zone that the room is in.
         * @param    The zone tha tthe room is in.
         */
        public function setZone(tmpzone:Zone):void {

            zone = tmpzone;
        }
        /**
         * Gets the zone that the room is in.
         * @return The zone that the room is in.
         */
        public function getZone():Zone {
            return zone;
        }
        /**
         * Gets the full user list for this room.
         * @return The full user list for this room.
         */
        public function getUsers():Array {
            return users;
        }
        /**
         * Gets a user based on a user id.
         * @param    The user id.
         * @return The user who has the id passed in.
         */
        public function getUserById(str:String):User {
            return usersById[str];
        }
        /**
         * Sets the id of the zone that holds the room.
         * @param    The id of the zone that holds the room.
         */
        public function setZoneId(zId:Number):void {

            zoneId = zId;
        }
        /**
         * Gets the id of the zone that holds the room.
         * @return The id of the zone that holds the room.
         */
        public function getZoneId():Number {
            return zoneId;
        }
        /**
         * Sets the id of the room.
         * @param    The id of the room.
         */
        public function setRoomId(rId:Number):void {

            roomId = rId;
        }
        /**
         * Gets the id of the room.
         * @return The id of the room.
         */
        public function getRoomId():Number {
            return roomId;
        }
        /**
         * Sets the name of the room.
         * @param    The name of the room.
         */
        public function setRoomName(name:String):void {

            roomName = name;
        }
        /**
         * Gets the name of the room.
         * @return The name of the room.
         */
        public function getRoomName():String {
            return roomName;
        }
        /**
         * Sets the user count for the room.
         * @param    The user count for the room.
         */
        public function setUserCount(count:Number):void {

            userCount = count;
        }
        /**
         * Gets the user count for the room.
         * @return The user count for the room.
         */
        public function getUserCount():Number {
            return userCount;
        }
    }
}
