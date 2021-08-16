package com.electrotank.electroserver4.message.event {
    import com.electrotank.electroserver4.message.MessageImpl;
    import com.electrotank.electroserver4.message.event.*;
    import com.electrotank.electroserver4.message.*;
    import com.electrotank.electroserver4.room.*;
    import com.electrotank.electroserver4.user.*;
    
    public class UserListUpdateEvent extends EventImpl {

        //static update actions
        static public var AddUser:Number = 0;
        static public var DeleteUser:Number = 1;
        static public var UpdateUser:Number = 2;
        static public var OperatorGranted:Number = 3;
        static public var OperatorRevoked:Number = 4;
        static public var SendingVideoStream:Number = 5;
        static public var StoppingVideoStream:Number = 6;
        //
        private var roomId:Number;
        private var zoneId:Number;
        private var actionId:Number;
        private var userId:String;
        private var userName:String;
        private var userVariables:Array;
        private var _user:User;
        private var _room:Room;
        private var _minorType:String;
        private var isSendingVideo:Boolean;
        private var videoStreamName:String;
        public function UserListUpdateEvent() {
            setMessageType(MessageType.UserListUpdateEvent);
        }
        public function setIsSendingVideo(isSending:Boolean):void {

            this.isSendingVideo = isSending;
        }
        public function setUser(u:User):void {

            user  = u;
        }
        public function getUser():User {
            return user;
        }
        public function getIsSendingVideo():Boolean {
            return this.isSendingVideo;
        }
        public function setVideoStreamName(streamName:String):void {

            this.videoStreamName = streamName;
        }
        public function getVideoStreamName():String {
            return this.videoStreamName;
        }
        public function set room(r:Room):void {

            _room = r;
        }
        public function get room():Room {
            return _room;
        }
        public function set minorType(s:String):void {

            _minorType = s;
        }
        public function get minorType():String {
            return _minorType;
        }
        public function set user(u:User):void {

            _user = u;
        }
        public function get user():User {
            return _user;
        }
        public function setUserVariables(arr:Array):void {

            userVariables = arr;
        }
        public function getUserVariables():Array {
            return userVariables;
        }
        public function setUserName(str:String):void {

            userName = str;
        }
        public function getUserName():String {
            return userName;
        }
        public function setUserId(str:String):void {

            userId = str;
        }
        public function getUserId():String {
            return userId;
        }
        public function setActionId(num:Number):void {

            actionId = num;
        }
        public function getActionId():Number {
            return actionId;
        }
        public function setRoomId(num:Number):void {

            roomId = num;
        }
        public function getRoomId():Number {
            return roomId;
        }
        public function setZoneId(num:Number):void {

            zoneId = num;
        }
        public function getZoneId():Number {
            return zoneId;
        }
    }
}
