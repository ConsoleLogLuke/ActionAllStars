package com.electrotank.electroserver4.message.event {
    import com.electrotank.electroserver4.entities.UserVariable;
    import com.electrotank.electroserver4.message.MessageImpl;
    import com.electrotank.electroserver4.message.event.*;
    import com.electrotank.electroserver4.message.*;
    import com.electrotank.electroserver4.user.User;
    import com.electrotank.electroserver4.esobject.EsObject;
        /**
         * This class represents the BuddyStatusUpdatedEvent. When a buddy logs in or logs out that buddys status has changed and is reported using this event. 
         */
    
    public class BuddyStatusUpdatedEvent extends EventImpl {

        /**
         * Buddy logged in.
         */
        static public var LoggedIn:Number = 0;
        /**
         * Buddy logged out.
         */
        static public var LoggedOut:Number = 1;
        private var actionId:Number;
        private var userId:String;
        private var userName:String;
        private var user:User;
        private var esObject:EsObject;
        private var hasEsObject:Boolean;
        /**
         * Creates a new BuddyStatusUpdatedEvent instance.
         */
        public function BuddyStatusUpdatedEvent() {
            setMessageType(MessageType.BuddyStatusUpdatedEvent);
        }
        /**
         * @private
         */
        public function setHasEsObject(val:Boolean):void {

            hasEsObject = val;
        }
        /**
         * Returns true if there is an EsObject.
         * @return True or false.
         */
        public function getHasEsObject():Boolean {
            return hasEsObject;
        }
        /**
         * @private
         */
        public function setEsObject(ob:EsObject):void {

            esObject = ob;
        }
        /**
         * Returns the EsObject.
         * @return The EsObject.
         */
        public function getEsObject():EsObject {
            return esObject;
        }
        /**
         * @private
         */
        public function setUser(u:User):void {

            user = u;
        }
        /**
         * Returns the User.
         * @return The User.
         */
        public function getUser():User {
            return user;
        }
        /**
         * @private
         */
        public function setActionId(num:Number):void {

            actionId = num;
        }
        /**
         * Returns the action id. It will have the value of either LoggedIn or LoggedOut.
         * @return
         */
        public function getActionId():Number {
            return actionId;
        }
        /**
         * @private
         */
        public function setUserId(str:String):void {

            userId = str;
        }
        /**
         * @private
         */
        public function getUserId():String {
            return userId;
        }
        /**
         * @private
         */
        public function setUserName(str:String):void {

            userName = str;
        }
        /**
         * Gets the user's name;
         * @return
         */
        public function getUserName():String {
            return userName;
        }
    }
}
