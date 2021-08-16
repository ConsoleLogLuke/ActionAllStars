package com.electrotank.electroserver4.errors {
    import com.electrotank.electroserver4.errors.*;
    /**
     * This class is used to represent a type of error, like UserNamExists or RoomNotFound. All error types are established as static variables in the Errors class.
     */
    
    public class EsError {

        private var id:Number;
        private var description:String;
        /**
         * Creates a new instance of the EsError class.
         * @param    Numeric error id.
         * @param    Short description of the error.
         */
        public function EsError(tmpid:Number, desc:String) {
            id = tmpid;
            description = desc;
        }
        /**
         * Gets the error description.
         * @return Returns the error description.
         */
        public function getDescription():String {
            return description;
        }
        /**
         * Gets the error id.
         * @return The error id.
         */
        public function getId():Number {
            return id;
        }
    }
}
