package com.electrotank.electroserver4.message.request {
    import com.electrotank.electroserver4.message.request.*;
    import com.electrotank.electroserver4.message.MessageType;
    import com.electrotank.electroserver4.esobject.EsObject;
    import com.electrotank.electroserver4.message.ValidationResponse;
    /**
     * This request is used to send private messages to one or more users at once. A private message can contain an optional EsObject. A private message can be sent from any user to any other user. Rooms play no part in this. <br/>
     * Private messages can be intercepted by a Private Message Event Handler on the server and modified or killed. Private message filtering can be enabled using the web-based administrator.
     * @example
     *     This shows how to send a private message to one user. It also shows how to capture the PrivateMessageEvent.
     *     <listing>
    import com.electrotank.electroserver4.ElectroServer;
    import com.electrotank.electroserver4.message.MessageType;
    import com.electrotank.electroserver4.message.request.*;
    import com.electrotank.electroserver4.message.response.*;
    import com.electrotank.electroserver4.message.event.*;
    
    private var es:ElectroServer;
    function init():void {
        es.addEventListener(MessageType.PrivateMessageEvent, "onPrivateMessageEvent", this);
    }
    function sendPrivateMessage(message:String, userName:String):void {
        //build the request
        var pmr:PrivateMessageRequest = new PrivateMessageRequest();
        pmr.setMessage(message);
        pmr.setUserNames([userName]);
        //send it
        es.send(pmr);
    }
    function onPrivateMessageEvent(e:PrivateMessageEvent):void {
        var from:String = e.getUserName();
        var message:String = e.getMessage();
        trace(from+": "+message);
    }
    init();
    sendPrivateMessage("Hello world", ["fluffy323"]);
    *     </listing>
     */
    
    public class PrivateMessageRequest extends RequestImpl {

        private var message:String;
        private var pairs:Array;
        private var users:Array;
        private var userNames:Array;
        private var esObject:EsObject;
        /**
         * Creates a new instance of the PrivateMessageRequest class.
         */
        public function PrivateMessageRequest() {
            setMessageType(MessageType.PrivateMessageRequest);
            setUsers(new Array());
            setUserNames(new Array());
        }
    
     override public function validate():ValidationResponse {    
            var valid:Boolean = true;
            var problems:Array = new Array();
            if (getUsers().length == 0 && getUserNames().length == 0) {
                problems.push("getUsers() is empty.");
            }
            if (getUsers() == null) {
                problems.push("getUsers() returned null.");
            }
            if (getMessage() == null) {
                problems.push("getMessage() returned null.");
            }
            if (problems.length > 0) {
                valid = false;
            }
            var vr:ValidationResponse = new ValidationResponse(valid, problems);
            return vr;
        }
        /**
         * An array of user names of the users to whom the message will be sent.
         * @param    An array of user names of the users to whom the message will be sent.
         */
        public function setUserNames(names:Array):void {

            userNames = names;
        }
        /**
         * Returns the list of user names to whom this message will be sent. 
         * @return Returns the list of user names to whom this message will be sent. 
         */
        public function getUserNames():Array {
            return userNames;
        }
        /**
         * Sets the list of users to whom this message will be sent.
         * @param    The list of users to whom this message will be sent.
         */
        public function setUsers(users:Array):void {

            this.users = users;
        }
        /**
         * Returns the list of users to whom this message will be sent.
         * @return Returns the list of users to whom this message will be sent.
         */
        public function getUsers():Array {
            return users;
        }
        /**
         * Sets the optional EsObject that will be sent along with this message.
         * @param    The optional EsObject that will be sent along with this message.
         */
        public function setEsObject(eob:EsObject):void {

            esObject = eob;
        }
        /**
         * Returns the optional EsObject.
         * @return Returns the optional EsObject.
         */
        public function getEsObject():EsObject {
            return esObject;
        }
        /**
         * Sets the message text to be sent.
         * @param    The message text to be sent.
         */
        public function setMessage(message:String):void {

            this.message = message;
        }
        /**
         * Returns the message text to be sent.
         * @return Returns the message text to be sent.
         */
        public function getMessage():String {
            return message;
        }
    }
}
