package com.electrotank.electroserver4.message.request {
    import com.electrotank.electroserver4.message.request.*;
    import com.electrotank.electroserver4.message.MessageType;
    import com.electrotank.electroserver4.esobject.EsObject;
    import com.electrotank.electroserver4.message.ValidationResponse;
    /**
     * This request allows you to create or update a user variable on yourself. A user variable is a name value pair stored on the server and scoped to a user. The name is a string and the value is an EsObject. By default, all users in a room that you are in can see your user variables, and receive update events when they change. 
     * @example
     * This example shows how to create a user variable, update it, and capture the UserVariableUpdateEvent and trace what is going on.
     * <listing>
     import com.electrotank.electroserver4.ElectroServer;
    import com.electrotank.electroserver4.entities.UserVariable;
    import com.electrotank.electroserver4.esobject.EsObject;
    import com.electrotank.electroserver4.message.event.UserVariableUpdateEvent;
    import com.electrotank.electroserver4.message.MessageType;
    import com.electrotank.electroserver4.message.request.UpdateUserVariableRequest;
    import com.electrotank.electroserver4.user.User;
    var es:ElectroServer;//Assume a connection was created elsewhere and you're logged in.
    function init():void {
        es.addEventListener(MessageType.UserVariableUpdateEvent, "onUserVariableUpdatedEvent", this);
    }
    function createAndUpdateUserVariable():void {
        //create the var
        var uuvr:UpdateUserVariableRequest = new UpdateUserVariableRequest();
        uuvr.setName("Test");
        var esob:EsObject = new EsObject();
        esob.setString("TestVar", "hello there");
        uuvr.setValue(esob);
        //send it
        es.send(uuvr);
        /////////////
        //update the var
        //
        uuvr = new UpdateUserVariableRequest();
        uuvr.setName("Test");
        esob = new EsObject();
        esob.setString("TestVar", "i said hello!");
        //send it
        es.send(uuvr);
    }
    function onUserVariableUpdatedEvent(e:UserVariableUpdateEvent):void {
        var u:User = e.user;
        var name:String = e.getVariableName();
        trace("User variable name: "+name);
        switch (e.getActionId()) {
            case UserVariableUpdateEvent.VariableCreated:
                var uv:UserVariable = u.getUserVariable(name);
                trace("User variable created");
                trace("User variable value: "+uv.getValue().getString("Test"));
                break;
            case UserVariableUpdateEvent.VariableUpdated:
                var uv:UserVariable = u.getUserVariable(name);
                trace("User variable updated.");
                trace("User variable value: "+uv.getValue().getString("Test"));
                break;
            case UserVariableUpdateEvent.VariableDeleted:
                trace("User variable deleted.");
                break;
            default:
                trace("Update action not handled: "+e.getActionId());
                break;
        }
    }
    init();
    createAndUpdateUserVariable();
    * </listing>
     */
    
    public class UpdateUserVariableRequest extends RequestImpl {

        private var name:String;
        private var value:EsObject;
        /**
         * Creates a new instance of the UpdateUserVariableRequest.
         */
        public function UpdateUserVariableRequest() {
            setMessageType(MessageType.UpdateUserVariableRequest);
        }
    
     override public function validate():ValidationResponse {    
            var valid:Boolean = true;
            var problems:Array = new Array();
            if (getValue() == null) {
                problems.push("getValue() must not return null.");
            }
            if (getName() == null) {
                problems.push("getName() must not return null.");
            }
            valid = problems.length == 0;
            var vr:ValidationResponse = new ValidationResponse(valid, problems);
            return vr;
        }
        /**
         * Sets the name of the variable to create or update.
         * @param    The name of the variable to create or udpate.
         */
        public function setName(name:String):void {

            this.name = name;
        }
        /**
         * Gets the name of the variable to create or udpate.
         * @return The name of the variable to create or udpate.
         */
        public function getName():String {
            return name;
        }
        /**
         * Sets the value of the variable.
         * @param    The value of the variable.
         */
        public function setValue(value:EsObject):void {

            this.value = value;
        }
        /**
         * Gets the value of the variable.
         * @return The value of the variable.
         */
        public function getValue():EsObject {
            return value;
        }
    }
}
