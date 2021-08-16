package com.electrotank.electroserver4.message.request {
    import com.electrotank.electroserver4.message.request.*;
    import com.electrotank.electroserver4.message.MessageType;
    import com.electrotank.electroserver4.esobject.EsObject;
    import com.electrotank.electroserver4.message.ValidationResponse;
    /**
     * This class is used to load user variables for a user. You can specify which variables you are interested in.
     */
    
    public class GetUserVariablesRequest extends RequestImpl {

        private var userName:String;
        private var userVariableNames:Array;
        /**
         * Creates a new instance of the GetUserVariablesRequest class.
         */
        public function GetUserVariablesRequest() {
            setMessageType(MessageType.GetUserVariablesRequest);
            userVariableNames = new Array();
        }
        
     override public function validate():ValidationResponse {    
            var valid:Boolean = true;
            var problems:Array = new Array();
            if (getUserName() == null) {
                problems.push("A username must be specified.");
            }
            if (problems.length != 0) {
                valid = false;
            }
            var vr:ValidationResponse = new ValidationResponse(valid, problems);
            return vr;
        }
        /**
         * Sets the name of the user you want to know about.
         * @param    The name of the user you want to know about.
         */
        public function setUserName(userName:String):void {

            this.userName = userName;
        }
        /**
         * The name of the user you want to know about.
         * @return The name of the user you want to know about.
         */
        public function getUserName():String {
            return this.userName;
        }
        /**
         * Add a user variable name that you are interested in.
         * @param    User variable name that you are interested in.
         */
        public function addUserVariableName(name:String):void {

            getUserVariableNames().push(name);
        }
        /**
         * The list of names that you've added.
         * @return The list of names that you've added.
         */
        public function getUserVariableNames():Array {
            return userVariableNames;
        }
    }
}
