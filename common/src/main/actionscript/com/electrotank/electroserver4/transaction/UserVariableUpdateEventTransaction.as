package com.electrotank.electroserver4.transaction {
    import com.electrotank.electroserver4.transaction.*;
    import com.electrotank.electroserver4.message.Message;
    import com.electrotank.electroserver4.message.event.*;
    import com.electrotank.electroserver4.ElectroServer;
    import com.electrotank.electroserver4.user.User;
    import com.electrotank.electroserver4.room.*;
    import com.electrotank.electroserver4.zone.*;
    import com.electrotank.electroserver4.user.*;
    import com.electrotank.electroserver4.entities.*;
    
    public class UserVariableUpdateEventTransaction extends TransactionImpl {

        override public function execute(mess:Message, es:ElectroServer):void {

            var message:UserVariableUpdateEvent = UserVariableUpdateEvent(mess);
            var UM:UserManager = es.getUserManager();
            var user:User = UM.getUserById(message.getUserId());
            var actionId:Number = message.getActionId();
            var uv:UserVariable;
            var type:String;
            if (actionId == UserVariableUpdateEvent.VariableCreated) {
                type = "created";
                uv = new UserVariable(message.getVariableName(), message.getVariable().getValue());
                user.addUserVariable(uv);
            } else if (actionId == UserVariableUpdateEvent.VariableUpdated) {
                type = "updated";
                uv = user.getUserVariable(message.getVariableName());
                uv.setValue(message.getVariable().getValue());
            } else if (actionId == UserVariableUpdateEvent.VariableDeleted) {
                type = "deleted";
                uv = user.getUserVariable(message.getVariableName());
                user.removeUserVariable(message.getVariableName());
            }
            message.user = user;
            message.minorType = type;
            es.dispatchEvent(message);
        }
    }
}
