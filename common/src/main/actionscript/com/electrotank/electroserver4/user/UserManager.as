package com.electrotank.electroserver4.user {
    import com.electrotank.electroserver4.entities.UserVariable;
    import com.electrotank.electroserver4.user.*;
    /**
     * This class is used to manage all users that the client knows about. If a client is in 3 rooms and can see flamer_311 in each room, then there is only one User instance that represents that use. That single user instance is referred to from the three Room instances. A user being in your buddy list works this way too. When it is detected that a user in the User Manager has no references to it, it is removed to clean up.
     * <br/><br/>This class can be used to find any user by name, get a full list of all users that you can see, or just run a check to see if a user exists from your perspective.
     */
    
    public class UserManager {

        private var users:Array;
        private var usersById:Object;
        private var me:User;
        private var usersByName:Object;
        /**
         * Creates a new instance of the UserManager class.
         */
        public function UserManager() {
            users = new Array();
            usersById = new Object();
            usersByName = new Object();
        }
        /**
         * Sets the reference to yourself. This is a permanent reference so that your own User class intance won't be removed.
         * @param    User that represents you.
         */
        public function setMe(u:User):void {

            me = u;
        }
        /**
         * Gets User that represents you.
         * @return User that represents you.
         */
        public function getMe():User {
            return me;
        }
        /**
         * Adds a user.
         * @param    The User to add.
         */
        public function addUser(u:User):void {

            getUsers().push(u);
            usersById[u.getUserId()] = u;
            usersByName[u.getUserName()] = u;
        }
        /**
         * Adds a reference to a User.
         * @param    The User for which to add a reference.
         */
        public function addReference(u:User):void {

            u.setReferences(u.getReferences()+1);
        }
        /**
         * Removes a refence to a User.
         * @param    User for whom a reference is removed.
         */
        public function removeReference(u:User):void {

            if (getUserByName(u.getUserName()) != null) {
                u.setReferences(u.getReferences()-1);
                if (u.getReferences() == 0) {
                    removeUser(u);
                }
            } else {
                trace("Error: tried to remove reference to a user that wasn't being managed by the UserManager. Name: " + u.getUserName());
            }
        }
        /**
         * Removes a user.
         * @param    User to remove.
         */
        private function removeUser(u:User):void {

            if (getUserByName(u.getUserName()) != null) {
                for (var i:Number=0;i<getUsers().length;++i) {
                    if (getUsers()[i] == u) {
                        getUsers().splice(i, 1);
                        break;
                    }
                }
                usersById[u.getUserId()] = null;
                usersByName[u.getUserName()] = null;
            } else {
                trace("Error: tried to remove a user that isn't being managed by the UserManager. Name: " + u.getUserName());
            }
        }
        /**
         * Useful method that allows you to check to see if a specific user is currently being managed by your instnace of the UserManager. This doesn't mean that user is logged into the server or not, it just checks to see if that user is managed here.
         * @param    Id of the User.
         * @return True or false.
         */
        public function doesUserExist(id:String):Boolean {
            return getUserById(id) != null;
        }
        /**
         * Gets a User based on id.
         * @param    The id of the User.
         * @return The User whose id was passed in.
         */
        public function getUserById(id:String):User {
            return usersById[id];
        }
        /**
         * Gets a User based on the name.
         * @param    Name of the User to find.
         * @return The User with the name passed in.
         */
        public function getUserByName(name:String):User {
            return usersByName[name];
        }
        /**
         * Gets the full list of managed users.
         * @return The full list of managed users.
         */
        public function getUsers():Array {
            return users;
        }
    }
}
