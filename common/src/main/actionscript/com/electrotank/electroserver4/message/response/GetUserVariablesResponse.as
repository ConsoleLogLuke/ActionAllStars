package com.electrotank.electroserver4.message.response {
    import com.electrotank.electroserver4.entities.UserVariable;
    import com.electrotank.electroserver4.message.MessageImpl;
    import com.electrotank.electroserver4.message.response.*;
    import com.electrotank.electroserver4.message.*;
    import com.electrotank.electroserver4.errors.*;
    import com.electrotank.electroserver4.esobject.EsObject;
    
    public class GetUserVariablesResponse extends ResponseImpl {

        private var userVariables:Array;
        private var userVariablesByName:Object;
        private var userName:String;
        public function GetUserVariablesResponse() {
            setMessageType(MessageType.GetUserVariablesResponse);
            userVariables = new Array();
            userVariablesByName = new Object();
        }
        public function setUserName(userName:String):void {

            this.userName = userName;
        }
        public function getUserName():String {
            return userName;
        }
        public function addVariable(name:String, esob:EsObject):void {

            var uv:UserVariable = new UserVariable(name, esob);
            userVariablesByName[name] = uv;
            userVariables.push(uv);
        }
        public function getUserVariables():Array {
            return userVariables;
        }
        public function getUserVariableByName(name:String):UserVariable {
            return userVariablesByName[name];
        }
        public function doesUserVariableExist(name:String):Boolean {
            return userVariablesByName[name] != null;
        }
    }
}
