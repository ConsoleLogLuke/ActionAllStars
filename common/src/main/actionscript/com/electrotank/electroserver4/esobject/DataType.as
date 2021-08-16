package com.electrotank.electroserver4.esobject {
    /**
     * This class is used internally to map a data type to an EsObject property associated with an id.
     */
    
    public class DataType {

    
        /**
         * Represents the Integer data type.
         */
        static public var Integer:DataType = new DataType('0', "integer");
        /**
         * Represents the String data type.
         */
        static public var EsString:DataType = new DataType('1', "string")
        /**
         * Represents the Double data type.
         */
        static public var Double:DataType = new DataType('2', "double"); 
        /**
         * Represents the Float data type.
         */
        static public var Float:DataType = new DataType('3', "float");
        /**
         * Represents the Boolean data type.
         */
        static public var EsBoolean:DataType = new DataType('4', "boolean");
        /**
         * Represents the Byte data type.
         */
        static public var Byte:DataType = new DataType('5', "byte");
        /**
         * Represents the Character data type.
         */
        static public var Character:DataType = new DataType('6', "character");
        /**
         * Represents the Long data type.
         */
        static public var Long:DataType = new DataType('7', "long");
        /**
         * Represents the Short data type.
         */
        static public var Short:DataType = new DataType('8', "short");
        /**
         * Represents the EsObject data type.
         */
           static public var EsObject:DataType = new DataType('9', "esobject");
        /**
         * Represents the EsObjectArray data type.
         */
        static public var EsObjectArray:DataType = new DataType('a', "esobject_array");
        /**
         * Represents the IntegerArray data type.
         */
        static public var IntegerArray:DataType = new DataType('b', "integer_array");
        /**
         * Represents the StringArray data type.
         */
        static public var StringArray:DataType = new DataType('c', "string_array");
        /**
         * Represents the DoubleArray data type.
         */
        static public var DoubleArray:DataType = new DataType('d', "double_array");
        /**
         * Represents the FloatArray data type.
         */
        static public var FloatArray:DataType = new DataType('e', "float_array");
        /**
         * Represents the BooleanArray data type.
         */
        static public var BooleanArray:DataType = new DataType('f', "boolean_array");
        /**
         * Represents the ByteArray data type.
         */
        static public var EsByteArray:DataType = new DataType('g', "byte_array");
        /**
         * Represents the CharacterArray data type.
         */
        static public var CharacterArray:DataType = new DataType('h', "character_array"); 
        /**
         * Represents the LongArray data type.
         */
        static public var LongArray:DataType = new DataType('i', "long_array");
        /**
         * Represents the ShortArray data type.
         */
        static public var ShortArray:DataType = new DataType('j', "short_array");
        /**
         * Represents the Number data type.
         */
        static public var EsNumber:DataType = new DataType('k', "number");
        /**
         * Represents the NumberArray data type.
         */
        static public var NumberArray:DataType = new DataType('l', "number_array");
        
        static private var typesByIndicator:Object;
        static private var typesByName:Object;
        
        /**
         * Registers a new data type.
         * @param    The data type.
         */
        static public function register(dt:DataType):void {

            if (typesByIndicator == null) {
                typesByIndicator = new Object();
            }
            if (typesByName == null) {
                typesByName = new Object();
            }
            typesByIndicator[dt.getIndicator()] = dt;
            typesByName[dt.getName()] = dt;
        }
        /**
         * Finds a data type by the id used to represent it.
         * @param    The id used to represent the data type.
         * @return The data type.
         */
        static public function findTypeByIndicator(id:String):DataType {
            return typesByIndicator[id];
        }
        /**
         * Finds a data type by the name used to represent it.
         * @param    The name used to represent the data type.
         * @return The data type.
         */
        static public function findTypeByName(name:String):DataType {
            return typesByName[name];
        }
        
        
        private var indicator:String;
        private var name:String;
        /**
         * Creates a new instance of the DataType class and registers it.
         * @param    The id used to represent the data type.
         * @param    The name of the data type.
         */
        public function DataType(ind:String, nm:String) {
            indicator = ind;
            name = nm;
            register(this);
        }
        /**
         * Returns the id of a data type.
         * @return The id of a data type.
         */
        public function getIndicator():String {
            return indicator;
        }
        /**
         * Gets the name of a data type.
         * @return
         */
        public function getName():String {
            return name;
        }
    }
}
