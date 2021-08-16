package com.electrotank.electroserver4.message.request {
    import com.electrotank.electroserver4.message.request.*;
    import com.electrotank.electroserver4.message.MessageType;
    import com.electrotank.electroserver4.message.ValidationResponse;
    /**
     * This request allows a user in a room to update details about that room. These details include one or more of the following:
     * <ul>
     * <li><code>setRoomName(string)</code> - Updates the room's name.
     * <li><code>setPassword(string)</code> - Creates or updates the room's password.
     * <li><code>setDescription(string)</code> - Creates or updates the room's description.
     * <li><code>setCapacity(number)</code> - Changes the room's capacity. Capacity refers to the number of users allowed in the room at maximum. The default is -1, which is no limit.
     * <li><code>setHidden(boolean)</code> - Changes the hidden property of the room. The default is false. If true the room appears to be deleted and not to exist to users not in it.
     * </ul>
     */
    
    public class UpdateRoomDetailsRequest extends RequestImpl {

        private var zoneId:Number;
        private var roomId:Number;
        private var roomNameUpdate:Boolean;
        private var roomName:String;
        private var capacityUpdate:Boolean;
        private var capacity:Number;
        private var descriptionUpdate:Boolean;
        private var description:String;
        private var passwordUpdate:Boolean;
        private var password:String;
        private var hiddenUpdate:Boolean;
        private var hidden:Boolean;
        /**
         * Creates a new instance of the UpdateRoomDetailsRequest class.
         */
        public function UpdateRoomDetailsRequest() {
            setMessageType(MessageType.UpdateRoomDetailsRequest);
            setHiddenUpdate(false);
            setPasswordUpdate(false);
            setDescriptionUpdate(false);
            setCapacityUpdate(false);
            setRoomNameUpdate(false);
        }
    
     override public function validate():ValidationResponse {    
            var valid:Boolean = true;
            var problems:Array = new Array();
            var vr:ValidationResponse = new ValidationResponse(valid, problems);
            return vr;
        }
        /**
         * Sets the hidden property of the room.
         * @param    The hidden property of the room.
         */
        public function setHidden(isHidden:Boolean):void {

            setHiddenUpdate(true);
            hidden = isHidden;
        }
        /**
         * Gets the hidden property of the room.
         * @return The hidden property of the room.
         */
        public function getHidden():Boolean {
            return hidden;
        }
        private function setHiddenUpdate(val:Boolean):void {

            hiddenUpdate = val;
        }
        /**
         * @private
         */
        public function isHiddenUpdate():Boolean {
            return hiddenUpdate
        }
        /**
         * Gets the updated password.
         * @return The updated password.
         */
        public function getPassword():String {
            return password;
        }
        /**
         * Updates the password property.
         * @param    The new password.
         */
        public function setPassword(password:String):void {

            setPasswordUpdate(true);
            this.password = password;
        }
        /**
         * @private
         */
        public function isPasswordUpdate():Boolean {
            return passwordUpdate;
        }
        private function setPasswordUpdate(val:Boolean):void {

            passwordUpdate = val;
        }
        /**
         * Updates the description property.
         * @param    The description property.
         */
        public function setDescription(description:String):void {

            setDescriptionUpdate(true);
            this.description = description;
        }
        /**
         * Returns the description property.
         * @return The description property.
         */
        public function getDescription():String {
            return description;
        }
        private function setDescriptionUpdate(val:Boolean):void {

            descriptionUpdate = val;
        }
        /**
         * @private
         */
        public function isDescriptionUpdate():Boolean {
            return descriptionUpdate;
        }
        /**
         * Changes the capacity of the room.
         * @param    The new capacity of the room.
         */
        public function setCapacity(capacity:Number):void {

            setCapacityUpdate(true);
            this.capacity = capacity;
        }
        public function getCapacity():Number {
            return capacity;
        }
        private function setCapacityUpdate(val:Boolean):void {

            capacityUpdate = val;
        }
        /**
         * @private
         */
        public function isCapacityUpdate():Boolean {
            return capacityUpdate;
        }
        /**
         * Changes the room name.
         * @param    The new room name.
         */
        public function setRoomName(roomName:String):void {

            setRoomNameUpdate(true);
            this.roomName = roomName;
        }
        /**
         * Returns the new room name.
         * @return Returns the new room name.
         */
        public function getRoomName():String {
            return roomName;
        }
        private function setRoomNameUpdate(val:Boolean):void {

            roomNameUpdate = val;
        }
        /**
         * @private
         */
        public function isRoomNameUpdate():Boolean {
            return roomNameUpdate;
        }
        /**
         * The id of the zone that holds the room.
         * @param    The zone id.
         */
        public function setZoneId(zId:Number):void {

            zoneId = zId;
        }
        /**
         * Returns the id of the zone that holds the room.
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
         * The id of the room.
         * @return  The room id.
         */
        public function getRoomId():Number {
            return roomId;
        }
    }
}
