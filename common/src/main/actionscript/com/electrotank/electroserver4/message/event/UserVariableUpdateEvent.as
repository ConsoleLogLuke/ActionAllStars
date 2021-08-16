package com.electrotank.electroserver4.message.event {
    import com.electrotank.electroserver4.message.MessageImpl;
    import com.electrotank.electroserver4.message.event.*;
    import com.electrotank.electroserver4.message.*;
    import com.electrotank.electroserver4.entities.*;
    import com.electrotank.electroserver4.user.*;
    
    public class UserVariableUpdateEvent extends EventImpl {

        //static update events
        static public var VariableCreated:Number = 1;
        static public var VariableUpdated:Number = 2;
        static public var VariableDeleted:Number = 3;
        //
        private var userId:String;
        private var actionId:Number;
        private var variable:UserVariable;
        private var _minorType:String;
        private var _user:User;
        private var variableName:String;
        public function UserVariableUpdateEvent() {
            setMessageType(MessageType.UserVariableUpdateEvent);
        }
        public function setVariableName(name:String):void {

            this.variableName = name;
        }
        public function getVariableName():String {
            return this.variableName;
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
        public function setUserId(num:String):void {

            userId = num;
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
        public function setVariable(v:UserVariable):void {

            variable = v;
        }
        public function getVariable():UserVariable {
            return variable;
        }
    }
}
