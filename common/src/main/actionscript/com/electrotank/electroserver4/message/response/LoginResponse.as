package com.electrotank.electroserver4.message.response {
    import com.electrotank.electroserver4.message.MessageImpl;
    import com.electrotank.electroserver4.message.response.*;
    import com.electrotank.electroserver4.message.*;
    import com.electrotank.electroserver4.errors.*;
    import com.electrotank.electroserver4.esobject.EsObject;
    
    public class LoginResponse extends ResponseImpl {

        private var accepted:Boolean;
        private var esError:EsError;
        private var esObject:EsObject;
        private var userName:String;
        private var userId:String;
        private var userVariables:Array;
        private var buddies:Object;
        public function LoginResponse() {
            setMessageType(MessageType.LoginResponse);
        }
        public function setUserVariables(uv:Array):void {

            userVariables = uv;
        }
        public function getUserVariables():Array {
            return userVariables;
        }
        public function setBuddies(buds:Object):void {

            buddies = buds;
        }
        public function getBuddies():Object {
            return buddies;
        }
        public function setUserId(userId:String):void {

            this.userId = userId;
        }
        public function getUserId():String {
            return userId;
        }
        public function setUserName(userName:String):void {

            this.userName = userName;
        }
        public function getUserName():String {
            return userName;
        }
        public function get success():Boolean {
            return getAccepted();
        }
        public function setEsObject(eob:EsObject):void {

            esObject = eob;
        }
        public function getEsObject():EsObject {
            return esObject;
        }
        public function setAccepted(bool:Boolean):void {

            accepted = bool;
        }
        public function getAccepted():Boolean {
            return accepted;
        }
        public function setEsError(er:EsError):void {

            esError = er;
        }
        public function getEsError():EsError {
            return esError;
        }
    }
}
