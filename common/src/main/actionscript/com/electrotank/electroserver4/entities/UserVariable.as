package com.electrotank.electroserver4.entities {
    import com.electrotank.electroserver4.entities.*;
    import com.electrotank.electroserver4.esobject.EsObject;
    /**
     * This class represents a user variable for a user. A user variable is a variable stored on the server and scoped to a user. The name is a string and the value is an EsObject. All users in a room can see a user's variables. By default the users in a room receive updates when a room member's variables change.
     */
    
    public class UserVariable {

        private var name:String;
        private var value:EsObject;
        /**
         *  Creates a new instance of the UserVariable class
         * @param    The name of the variable.
         * @param    The value of the variable.
         */
        public function UserVariable(tmpname:String, tmpvalue:EsObject) {
            setName(tmpname);
            setValue(tmpvalue);
        }
        /**
         * Sets the name of the variable.
         * @param    The name of the variable.
         */
        public function setName(name:String):void {

            this.name = name;
        }
        /**
         * Gets the name of the variable.
         * @return The name of the variable.
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
