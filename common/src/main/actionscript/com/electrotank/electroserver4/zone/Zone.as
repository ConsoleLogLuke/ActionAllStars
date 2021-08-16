package com.electrotank.electroserver4.zone {
    import com.electrotank.electroserver4.zone.*;
    import com.electrotank.electroserver4.room.*;
    /**
     * This class is used to represent a zone on the server. Much like a room is a collection of users, a zone is a collection of rooms. A zone cannot be created or destroyed by itself. When a room is created a zone name is specified. If that zone doesn't exist, it is created. When no more rooms exist in that zone, it is removed.
     * <br/><br/>If you loaded the list of zones by the GetZoneRequest, the response will contain a list of Zone class instances with a name and id property on each. If you belong to a room in a zone and left the join subscriptions to their default settings, then you will know the following about the zone that holds your room:
     * <ul>
     * <li>Zone Id - Id of the zone.
     * <li>Zone Name - Name of the zone.
     * <li>Rooms - An array of rooms in the zone. Each element is a Room instance containing that room's public properties. If you happen to belong to that room then it contains more information.
     * </ul>
     */
    
    public class Zone {

        private var zoneId:Number;
        private var zoneName:String;
        private var rooms:Array;
        private var roomsById:Object;
        private var roomsByName:Object;
        private var joinedRooms:Array;
        /**
         * Creates a new instance of the Zone class.
         */
        public function Zone() {
            rooms = new Array();
            roomsById = new Object();
            roomsByName = new Object();
            joinedRooms = new Array();
        }
        /**
         * Gets a list of rooms in this zone that you happen to be joined to.
         * @return
         */
        public function getJoinedRooms():Array {
            return joinedRooms;
        }
        /**
         * Adds a room to the joinedRooms list.
         * @param    The room to add.
         */
        public function addJoinedRoom(room:Room):void {

            joinedRooms.push(room);
        }
        /**
         * Removes a room from the joinedRoom list.
         * @param    Room to remove.
         */
        public function removeJoinedRoom(room:Room):void {

            for (var i:Number=0;i<joinedRooms.length;++i) {
                if (joinedRooms[i] == room) {
                    joinedRooms.splice(i, 1);
                    break;
                }
            }
        }
        /**
         * Adds a room to the room list. As rooms are added to the zone on the server the client is informed of this.
         * @param    Room to add.
         */
        public function addRoom(room:Room):void {

            if (roomsById[room.getRoomId()] == null) {
                getRooms().push(room);
                roomsById[room.getRoomId()] = room;
                roomsByName[room.getRoomName()] = room;
            } else {
                trace("Error: tried to add a room with an id that already exists. roomId: "+room.getRoomId()+" roomName: "+room.getRoomName());
            }
        }
        /**
         * Checks to see if a room exists base don the id passed in.
         * @param    Id of the room.
         * @return True or false.
         */
        public function doesRoomExist(id:Number):Boolean {
            return getRoomById(id) != null;
        }
        /**
         * Gets a room by name.
         * @param    Name of the room.
         * @return Reference to the room whose name was passed in.
         */
        public function getRoomByName(name:String):Room {
            return roomsByName[name];
        }
        /**
         * Gets a room based on an id.
         * @param    Id of the room to find.
         * @return Room whose id was passed in.
         */
        public function getRoomById(id:Number):Room {
            return roomsById[id];
        }
        /**
         * Removes a room based on a room id.
         * @param    Id of room to remove.
         */
        public function removeRoom(roomId:Number):void {

            var room:Room = getRoomById(roomId);
            if (room == null) {
                trace("Error: tried to remove a room and the roomId was not found. roomId: "+roomId);
            } else {
                roomsById[roomId] = null;
                roomsByName[room.getRoomName()] = null;
                for (var i:Number=0;i<getRooms().length;++i) {
                    if (getRooms()[i] == room) {
                        getRooms().splice(i, 1);
                        break;
                    }
                }
            }
        }
        /**
         * Gets the room list. Each element is an instance of the Room class.
         * @return The room list.
         */
        public function getRooms():Array {
            return rooms;
        }
        /**
         * Sets the id of the zone.
         * @param    Id of the zone.
         */
        public function setZoneId(num:Number):void {

            zoneId = num;
        }
        /**
         * Gets the zone id.
         * @return The id of the zone.
         */
        public function getZoneId():Number {
            return zoneId;
        }
        /**
         * Sets the name of the zone.
         * @param    The name of the zone.
         */
        public function setZoneName(name:String):void {

            zoneName = name;
        }
        /**
         * Gets the name of the zone.
         * @return The name of the zone.
         */
        public function getZoneName():String {
            return zoneName;
        }
    }
}
