package com.electrotank.electroserver4.message.event {
    import com.electrotank.electroserver4.message.MessageImpl;
    import com.electrotank.electroserver4.message.event.*;
    import com.electrotank.electroserver4.message.*;
    import com.electrotank.electroserver4.user.*;
    import com.electrotank.electroserver4.esobject.EsObject;
    
    public class PrivateMessageEvent extends EventImpl {

        private var userId:String;
        private var userName:String;
        private var message:String;
        private var esObject:EsObject;
        private var _user:User;
        public function PrivateMessageEvent() {
            setMessageType(MessageType.PrivateMessageEvent);
        }
        public function setEsObject(eob:EsObject):void {

            esObject = eob;
        }
        public function getEsObject():EsObject {
            return esObject;
        }
        public function set user(u:User):void {

            _user = u;
        }
        public function get user():User {
            return _user;
        }
        public function setUserName(str:String):void {

            userName = str;
        }
        public function getUserName():String {
            return userName;
        }
        public function setUserId(num:String):void {

            userId = num;
        }
        public function getUserId():String {
            return userId;
        }
        public function setMessage(mess:String):void {

            message = mess;
        }
        public function getMessage():String {
            return message;
        }
    }
}
