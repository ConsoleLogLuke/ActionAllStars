package com.electrotank.electroserver4.message.request {
    import com.electrotank.electroserver4.message.request.*;
    import com.electrotank.electroserver4.message.MessageType;
    import com.electrotank.electroserver4.esobject.EsObject;
    import com.electrotank.electroserver4.esobject.EsObjectMap;
    import com.electrotank.electroserver4.message.ValidationResponse;
    /**
     * This class is used to log into the server. By default all that is required here is that you create the request and populate it with a unique user name string. Since login systems can be implemented many different ways depending on the needs of the company or the application being created we have provided a lot of flexibility here. If you want to do anything more than the default login, then you must implement a Login Event Handler on the server. That Login Event Handler can assign you a user name, check your user name and password against a database, or just let you through as-is.
     * @example
     *     This shows how to log into the server in the most basic way.
     * <listing>
    import com.electrotank.electroserver4.ElectroServer;
    import com.electrotank.electroserver4.errors.EsError;
    import com.electrotank.electroserver4.message.MessageType;
    import com.electrotank.electroserver4.message.request.*;
    import com.electrotank.electroserver4.message.response.*;
    import com.electrotank.electroserver4.message.event.*;
    //
    private var es:ElectroServer;//Assume the connection has already been established.
    //Build the request
    var lr:LoginRequest = new LoginRequest();
    lr.setUserName("yoda");
    //Send it
    es.send(lr);
    //Listen for the response
    es.addEventListener(MessageType.LoginResponse, "onLoginResponse", this);
    function onLoginResponse(e:LoginResponse):void {
        if (e.getAccepted()) {
            trace("Logged in!");
        } else if (!e.getAccepted()){
            var err:EsError = e.getEsError();
            trace("Login failed: "+err.getDescription());
        }
    }
     * </listing>
     */
    
    public class LoginRequest extends RequestImpl {

        private var userName:String;
        private var password:String;
        private var pairs:Array;
        private var userVariables:Array;
        private var sharedSecret:String;
        private var isAutoDiscoverProtocol:Boolean;
        private var protocols:Array;
        private var esObject:EsObject;
        private var isAdditionalLoginRequest:Boolean;
        /**
         * Creates a new instance of the LoginRequest class.
         */
        public function LoginRequest() {
            setMessageType(MessageType.LoginRequest);//This is overridden below in 'setSharedSecret'
            isAdditionalLoginRequest = false;
            pairs = new Array();
            protocols = new Array();
            userVariables = new Array();
            setIsAutoDiscoverProtocol(true);
        }
    
     override public function validate():ValidationResponse {    
            var valid:Boolean = true;
            var problems:Array = new Array();
            if (isAdditionalLoginRequest && (userName != null && userName != "")) {
                problems.push("Additional login request requires a null UserName");
            }
            if (problems.length > 0) {
                valid = false;
            }
            var vr:ValidationResponse = new ValidationResponse(valid, problems);
            return vr;
        }
        /**
         * @private
         */
        public function setSharedSecret(sharedSecret:String):void {

            this.sharedSecret = sharedSecret;
            setMessageType(MessageType.AdditionalLoginRequest);//Change the message type if this is an addition login request
            isAdditionalLoginRequest = true;
        }
        /**
         * @private
         */
        public function getSharedSecret():String {
            return sharedSecret;
        }
        /**
         * Sets the option EsObjec to be sent to the server.
         * @param    The optional EsObjec to be sent to the server.
         */
        public function setEsObject(esObject:EsObject):void {

            this.esObject = esObject;
        }
        /**
         * Gets the optional EsObject.
         * @return
         */
        public function getEsObject():EsObject {
            return esObject;
        }
        public function setProtocols(protocols:Array):void {

            this.protocols = protocols;
        }
        public function getProtocols():Array {
            return this.protocols;
        }
        public function setIsAutoDiscoverProtocol(isAutoDiscoverProtocol:Boolean):void {

            this.isAutoDiscoverProtocol = isAutoDiscoverProtocol;
        }
        public function getIsAutoDiscoverProtocol():Boolean {
            return isAutoDiscoverProtocol;
        }
        /**
         * Gets the optional user variables to be set during login.
         * @return Returns the optional user variables to be set during login.
         */
        public function getUserVariables():Array {
            return userVariables;
        }
        /**
         * Adds a user variable to be set during login.
         * @param    Variable name.
         * @param    Variable value.
         */
        public function addUserVariable(name:String, value:EsObject):void {

            var map:EsObjectMap = new EsObjectMap(name, value);
            getUserVariables().push(map);
        }
        /**
         * Sets a list of user variables to be set during login.
         * @param    List of user variables.
         */
        public function setUserVariables(arr:Array):void {

            userVariables = arr;
        }
        /**
         * The name to be used during login. This can be null if a Login Event Handler is being used on the server to assign you a user name.
         * @param    Name to be used during login.
         */
        public function setUserName(userName:String):void {

            this.userName = userName;
        }
        /**
         * Returns the name to be used during login.
         * @return
         */
        public function getUserName():String {
            return userName;
        }
        /**
         * Sets an optional login password. Passwords are only used by custom-written Login Event Handlers on the server.
         * @param    Password string.
         */
        public function setPassword(password:String):void {

            this.password = password;
        }
        /**
         * Returns the optional password.
         * @return Returns the optional password.
         */
        public function getPassword():String {
            return password;
        }
    }
}
