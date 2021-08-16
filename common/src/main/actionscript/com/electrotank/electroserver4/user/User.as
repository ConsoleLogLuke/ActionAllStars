package com.electrotank.electroserver4.user {
    import com.electrotank.electroserver4.user.*;
    import com.electrotank.electroserver4.entities.*;
    import com.electrotank.electroserver4.utils.*;
    /**
     * 
     * This class is used to represent a user. It contains the user's name, user variables, and other useful methods.
     */
    
    public class User {

        private var userName:String;
        private var userId:String;
        private var userVariables:Array;
        private var userVariablesByName:Object;
        private var references:Number;
        private var isMe:Boolean;
        private var isSendingVideo:Boolean;
        private var videoStreamName:String;
        /**
         * Creates a new instance of the User class.
         */
        public function User() {
            setIsMe(false);
            setIsSendingVideo(false);
            setUserVariables(new Array());
            userVariablesByName = new Object();
            setReferences(0);
        }
        /**
         * @private
         */
        public function setVideoStreamName(videoStreamName:String):void {

            this.videoStreamName = videoStreamName;
        }
        /**
         * 
         * If the user is broadcasting a live feed (web cam) then getIsSendingVideo() is true and this method returns the stream name.<br>When users start or stop streaming a video the UserListUpdateEvent event is fired with the appropriate action.
         * @return String name of the user's video stream
         * @see com.electrotank.electroserver4.message.event.UserListUpdateEvent
         */
        public function getVideoStreamName():String {
            return this.videoStreamName;
        }
        /**
         * @private
         */
        public function setIsSendingVideo(isSending:Boolean):void {

            this.isSendingVideo = isSending;
        }
        /**
         *  
         * If the user is currently broadcasting live video then this returns true.
         * @return True if the user is broadcasting live video, false if not.
         * @see #getVideoStreamName
         */
        public function getIsSendingVideo():Boolean {
            return this.isSendingVideo;
        }
        /**
         * 
         * This method returns true if this user represents you and false if it does not.
         * @return True if the user represents you, false if it does not.
         */
        public function getIsMe():Boolean {
            return isMe;
        }
        /**
         * @private
         */
        public function setIsMe(isMe:Boolean):void {

            this.isMe = isMe;
        }
        /**
         * @private
         */
        public function getRealUserId():String {
            var str:String;
            /*
            var df:DiffeHellman = new DiffeHellman();
            var bigInt = df.str2bigInt(getUserId(), 36, 0);
            var str = df.bigInt2str(bigInt, 10);
            //--next 2 lines convert it back to original
            //var bigInt = df.str2bigInt(str, 10, 0);
            //var str = df.bigInt2str(bigInt, 36);
            */
            return str;
        }
        /**
         * @private
         */
        public function setReferences(num:Number):void {

            references = num;
        }
        /**
         * @private
         */
        public function getReferences():Number {
            return references;
        }
        /**
         * 
         * This gets an array of UserVariables that are associated with this user. For a full description of UserVariables see the UserVariable class.
         * @return Returns an array of UserVariable objects.
         * @see com.electrotank.electroserver4.entities.UserVariable
         * @see com.electrotank.electroserver4.message.event.UserVariableUpdateEvent
         */
        public function getUserVariables():Array {
            return userVariables;
        }
        /**
         * @private
         */
        public function setUserVariables(arr:Array):void {

            userVariables = new Array();
            for (var i:Number=0;i<arr.length;++i) {
                addUserVariable(arr[i]);
            }
        }
        /**
         * Checks to see if a user variable exists by name. If it does, then it returns true. If it does not, then it returns false.
         * @param    Name of the user variable.
         * @return True or false
         */
        public function doesUserVariableExist(name:String):Boolean {
            return userVariablesByName[name] != null;
        }
        /**
         * @private
         */
        public function addUserVariable(userVariable:UserVariable):void {

            if (doesUserVariableExist(userVariable.getName())) {
                removeUserVariable(userVariable.getName());
            }
            getUserVariables().push(userVariable);
            userVariablesByName[userVariable.getName()] = userVariable;
        }
        /**
         * @private
         */
        public function removeUserVariable(name:String):void {

            var uv:UserVariable = userVariablesByName[name];
            for (var i:Number=0;i<getUserVariables().length;++i) {
                if (getUserVariables()[i] == uv) {
                    getUserVariables().splice(i, 1);
                    break;
                }
            }
            delete userVariablesByName[name];
        }
        /**
         *  
         * Gets the UserVariable stored on this user associated with the name provided. For a full description of UserVariables see the UserVariable class.
         * @param    name: The name of the user variable to get.
         * @return A UserVariable
         * @see com.electrotank.electroserver4.entities.UserVariable
         * @see com.electrotank.electroserver4.message.event.UserVariableUpdateEvent
         */
        public function getUserVariable(name:String):UserVariable {
            return userVariablesByName[name];
        }
        /**
         * @private
         */
        public function setUserName(str:String):void {

            userName = str;
        }
        /**
         * 
         * Gets the user's user name. This is a string value that uniquely identifies the user on the server.
         * @return The user's name.
         */
        public function getUserName():String {
            return userName;
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
    }
}
