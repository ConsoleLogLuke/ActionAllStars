package com.electrotank.electroserver4.esobject {
    import com.electrotank.electroserver4.esobject.EsObjectDataHolder;
    import com.electrotank.electroserver4.esobject.DataType;
     import flash.utils.ByteArray;
     import flash.xml.XMLNode;
    /**
     * This class is used to represent an EsObject. EsObject is used all through the API on both the client and server side of ElectroServer. It is a way to create an object with strictly typed properties. This object can be of unlimited depth and is understood by ActionScript 2, ActionScript 3, Java and any other language that has an ElectroServer API. With EsObject the client and server, or ActionScript and Java, can exchange custom deep data representations. EsObject is serialized with the smallest footprint possible. It is significantly smaller than other object serializers such as JSON and WDDX (xml serializer).
     * <br/><br/>EsObject supports the following properties. Most are availabe in both ActionScript 2, and all are available in ActionScript 3.
     * <br/><ul>
     * <li>String and string array
     * <li>Boolean and boolean array
     * <li>EsObject and EsObject array
     * <li>Integer and integer array
     * <li>Double and double array
     * <li>Float and float array
     * <li>Number and number array
     * <li>Long and long array - ActionScript 3 only
     * <li>Short and short array
     * <li>Byte and byte array - ActionScript 3 only
     * <li>Character and character array
     * </ul>
     * @example
     * This example shows how to create a new EsObject and populate it with data.
     * <listing>
    import com.electrotank.electroserver4.esobject.EsObject;
    var esob:EsObject = new EsObject();
    esob.setString("MyName", "Jobe");
    esob.setInteger("MyAge", 32);
    //create 2nd ob to place in first
    var esob2:EsObject = new EsObject();
    esob2.setString("TestVar", "test value");
    esob2.setBoolean("IsProgrammer", true);
    //place 2nd ob in first
    esob.setEsObject("MySecondOb", esob2);
    
     * </listing>
     */
    
    public class EsObject {

        private var data:Object;
        private var list:Array;
        /**
         * Creates a new instance of the EsObject class.
         */
        public function EsObject() {
            data = new Object();
            list = new Array();
        }
     public function toString(tabs:String=null):String {
            var esobStr:String = "{EsObject:\n";
            if (tabs == null) {
                tabs = "";
            }
            tabs += "\t";
            for (var i:Number=0;i<getEntries().length;++i) {
                var dh:EsObjectDataHolder = getEntries()[i];
                var name:String = dh.getName();
                esobStr += tabs+name+":"+dh.getDataType().getName()+" = ";
                var tb:String = tabs + "\t";
     var arr:Array;
                switch(dh.getDataType()) {
                    case DataType.EsObject:
                        esobStr += dh.getRawValue().toString(tabs);
                        break;
                    case DataType.Byte:
                    case DataType.Character:
                    case DataType.Double:
                    case DataType.EsBoolean:
                    case DataType.EsNumber:
                    case DataType.EsString:
                    case DataType.Float:
                    case DataType.Integer:
                    case DataType.Long:
                    case DataType.Short:
                        esobStr += dh.getRawValue().toString();
                        break;
                    case DataType.BooleanArray:
                    case DataType.CharacterArray:
                    case DataType.DoubleArray:
                    case DataType.EsByteArray:
                    case DataType.FloatArray:
                    case DataType.IntegerArray:
                    case DataType.LongArray:
                    case DataType.NumberArray:
                    case DataType.ShortArray:
                    case DataType.StringArray:
                        esobStr += "\n" + tb +"[\n"
     arr = dh.getRawValue() as Array;
                        for (var j:Number = 0; j < arr.length;++j) {
                            esobStr += tb+arr[j];
                            if (j != arr.length -1) {
                                esobStr += ",\n";
                            }
                        }
                        esobStr += "\n"+tb+"]";
                        break;
                    case DataType.EsObjectArray:
                        esobStr += "\n"+tb +"[\n"
     var obArr:Array = dh.getRawValue() as Array;
                        for (var k:Number = 0; k < obArr.length;++k) {
                            var eob:EsObject = obArr[k];
                            esobStr += tb+eob.toString(tabs);
                            if (k != obArr.length -1) {
                                esobStr += ",\n";
                            }
                        }
                        esobStr += "\n"+tb+"]";
                        break;
                    default:
                        trace("EsObject.toString() data type not supported: "+dh.getDataType().getName());
                        break;
                }
                if (i != getEntries().length -1) {
                    esobStr += "\n";
                }
            }
            esobStr += "\n"+tabs+"}";
            return esobStr;
        }
     public function toXML(tabs:String=null):String {
            if (tabs == null) {
                tabs = "";
            }
            tabs += "\t";
            var esobStr:String = "";
            if (tabs == "\t") {
                esobStr += "<Variable>";
            }
            esobStr += "\n";
            for (var i:Number=0;i<getEntries().length;++i) {
                var dh:EsObjectDataHolder = getEntries()[i];
                var name:String = dh.getName();
                esobStr += tabs + "<Variable name='" + name + "' type='" + dh.getDataType().getName() + "' >";
                var tb:String = tabs+"\t";
     var arr:Array;
                switch(dh.getDataType()) {
                    case DataType.EsObject:
                        esobStr += dh.getEsObjectValue().toXML(tabs);
                        esobStr += "\n"+tabs;
                        break;
                    //case DataType.Byte:
                    case DataType.Character:
                    case DataType.Double:
                    case DataType.EsBoolean:
                    case DataType.EsNumber:
                    case DataType.EsString:
                    case DataType.Float:
                    case DataType.Integer:
                    case DataType.Long:
                    case DataType.Short:
                        esobStr += dh.getRawValue().toString();
                        break;
                    case DataType.Byte:
                        var byteIn:Number = Number(dh.getRawValue());
                        var byteString:String = byteIn.toString(16);
                        if (byteString.length < 2) {
                            byteString = "0" + byteString;
                        }
                        esobStr += byteString;
                        break;
                    case DataType.BooleanArray:
                    case DataType.CharacterArray:
                    case DataType.DoubleArray:
                    case DataType.EsByteArray:
                    case DataType.FloatArray:
                    case DataType.IntegerArray:
                    case DataType.LongArray:
                    case DataType.NumberArray:
                    case DataType.ShortArray:
                    case DataType.StringArray:
                        //esobStr += "\n"+tb +"<Entry>\n"
     arr = dh.getRawValue() as Array;
                        for (var j:Number = 0; j < arr.length;++j) {
                            esobStr += "\n"+tb+"<Entry>"+arr[j].toString()+"</Entry>";
                        }
                        esobStr += "\n"+tabs;
                        break;
                    case DataType.EsObjectArray:
     var obArr:Array = dh.getRawValue() as Array;
                        for (var k:Number = 0; k < obArr.length;++k) {
                            var eob:EsObject = obArr[k];
                            esobStr += "\n"+tb+"<Entry>"+eob.toXML(tabs+"\t")+"\n"+tb+"</Entry>";
                        }
                        esobStr += "\n"+tabs;
                        break;
                    default:
                        trace("EsObject.toString() data type not supported: "+dh.getDataType().getName());
                        break;
                }
                esobStr += "</Variable>";
                if (i != getEntries().length -1) {
                    esobStr += "\n";
                }
            }
            if (tabs == "\t") {
                esobStr += "\n</Variable>";
            }
            //esobStr += "\n";
            return esobStr;
        }
        public function fromXML(info:XMLNode):void {

            var children:Array = info.childNodes;
            for (var i:Number = 0; i < children.length;++i) {
                var child:XMLNode = children[i];
                var atts:Object = child.attributes;
                var name:String = atts.name;
                var dataType:DataType = DataType.findTypeByName(atts.type);
                var value:String;
                var arr:Array = new Array();
                var kids:Array;
                var kid:XMLNode;
                var j:Number;
                var esob:EsObject;
                switch(dataType) {
                    case DataType.EsObject:
                        esob = new EsObject();
                        esob.fromXML(child);
                        setEsObject(name, esob);
                        break;
                    case DataType.Byte:
                        value = child.firstChild.nodeValue;
     setByte(name, int(value));
                        break;
                    case DataType.Character:
                        value = child.firstChild.nodeValue;
                        setChar(name, value);
                        break;
                    case DataType.Double:
                        value = child.firstChild.nodeValue;
                        setDouble(name, Number(value));
                        break;
                    case DataType.EsBoolean:
                        value = child.firstChild.nodeValue;
                        setBoolean(name, value.toLowerCase() == "true" ? true : false);
                        break;
                    case DataType.EsNumber:
                        value = child.firstChild.nodeValue;
                        setNumber(name, Number(value));
                        break;
                    case DataType.EsString:
                        value = child.firstChild.nodeValue;
                        setString(name, value);
                        break;
                    case DataType.Float:
                        value = child.firstChild.nodeValue;
                        setFloat(name, Number(value));
                        break;
                    case DataType.Integer:
                        value = child.firstChild.nodeValue;
                        setInteger(name, Number(value));
                        break;
                    case DataType.Long:
                        value = child.firstChild.nodeValue;
                        setLong(name, value);
                        break;
                    case DataType.Short:
                        value = child.firstChild.nodeValue;
                        setShort(name, Number(value));
                        break;
                    case DataType.StringArray:
                        kids = child.childNodes;
                        for (j = 0; j < kids.length;++j) {
                            kid = kids[j];
                            arr[j] = kid.firstChild.nodeValue;
                        }
                        setStringArray(name, arr);
                        break;
                    case DataType.CharacterArray:
                        kids = child.childNodes;
                        for (j = 0; j < kids.length;++j) {
                            kid = kids[j];
                            arr[j] = kid.firstChild.nodeValue;
                        }
                        setCharArray(name, arr);
                        break;
                    case DataType.LongArray:
                        kids = child.childNodes;
                        for (j = 0; j < kids.length;++j) {
                            kid = kids[j];
                            arr[j] = kid.firstChild.nodeValue;
                        }
                        setLongArray(name, arr);
                        break;
                    case DataType.DoubleArray:
                        kids = child.childNodes;
                        for (j = 0; j < kids.length;++j) {
                            kid = kids[j];
                            arr[j] = Number(kid.firstChild.nodeValue);
                        }
                        setDoubleArray(name, arr);
                        break;
                    case DataType.FloatArray:
                        kids = child.childNodes;
                        for (j = 0; j < kids.length;++j) {
                            kid = kids[j];
                            arr[j] = Number(kid.firstChild.nodeValue);
                        }
                        setFloatArray(name, arr);
                        break;
                    case DataType.IntegerArray:
                        kids = child.childNodes;
                        for (j = 0; j < kids.length;++j) {
                            kid = kids[j];
     arr[j] = int(kid.firstChild.nodeValue);
                        }
                        setIntegerArray(name, arr);
                        break;
                    case DataType.NumberArray:
                        kids = child.childNodes;
                        for (j = 0; j < kids.length;++j) {
                            kid = kids[j];
                            arr[j] = Number(kid.firstChild.nodeValue);
                        }
                        setNumberArray(name, arr);
                        break;
                    case DataType.ShortArray:
                        kids = child.childNodes;
                        for (j = 0; j < kids.length;++j) {
                            kid = kids[j];
                            arr[j] = Number(kid.firstChild.nodeValue);
                        }
                        setShortArray(name, arr);
                        break;
                    case DataType.BooleanArray:
                        kids = child.childNodes;
                        for (j = 0; j < kids.length;++j) {
                            kid = kids[j];
                            arr[j] = kid.firstChild.nodeValue.toLowerCase() == "true" ? true : false;
                        }
                        setBooleanArray(name, arr);
                        break;
                    case DataType.EsByteArray:
                        break;
                    case DataType.EsObjectArray:
                        kids = child.childNodes;
                        for (j = 0; j < kids.length;++j) {
                            kid = kids[j];
                            esob = new EsObject();
                            esob.fromXML(kid);
                            arr[j] = esob;
                        }
                        setEsObjectArray(name, arr);
                        break;
                    default:
                        trace("EsObject.toString() data type not supported: "+dataType.getName());
                        break;
                }
            }
        }
        /**
         * Checks to see if a property exists on the EsObject. If it does then true is returned. Otherwise, false is returned.
         * @param    The name of the property to check for.
         * @return True or false.
         */
        public function doesPropertyExist(name:String):Boolean {
            return data[name] != null;
        }
        /**
         * Returns the number of properties on the object.
         * @return The number of properties on the object.
         */
        public function getSize():Number {
            return list.length;
        }
        /**
         * Returns the list of entries on the object. The value of each entry is of type EsObjectDataHolder.
         * @return The list of entries on the object.
         */
        public function getEntries():Array {
            return list;
        }
        /**
         * Used internally. Puts a value on the EsObject.
         * @param    The name of the property.
         * @param    The value of the property.
         */
        private function put(name:String, value:EsObjectDataHolder):void {

            value.setName(name);
            if (data[name] != null) {
                var oldValue:EsObjectDataHolder = data[name];
                for (var i:Number = 0; i < list.length;++i) {
                    if (list[i] == oldValue) {
                        list.splice(i, 1);
                        break;
                    }
                }
                data[name] = null;
            }
            data[name] = value;
            list.push(value);
        }
        /**
         * Returns the DataType of a property based on its name.
         * @param    The name of the property.
         * @return The DataType of property.
         */
        public function getDataType(name:String):DataType {
            return getHolderForName(name).getDataType();
        }
        /**
         * Sets an integer ont onto the EsObject.
         * @param    The name of the integer.
         * @param    The value of the integer.
         */
        public function setInteger(name:String, value:Number):void {

            var esh:EsObjectDataHolder = new EsObjectDataHolder();
            esh.setRawValue(value);
            esh.setDataType(DataType.Integer);
            esh.setIntValue(value);
            put(name, esh);
        }
        /**
         * Sets a string onto the EsObject.
         * @param    Name of the string.
         * @param    Value of the string.
         */
        public function setString(name:String, value:String):void {

            var esh:EsObjectDataHolder = new EsObjectDataHolder();
            esh.setRawValue(value);
            esh.setDataType(DataType.EsString);
            esh.setStringValue(value);
            put(name, esh);
        }
        /**
         * Sets a double onto the EsObject.
         * @param    Name of the EsObject.
         * @param    Value of the EsObject.
         */
        public function setDouble(name:String, value:Number):void {

            var esh:EsObjectDataHolder = new EsObjectDataHolder();
            esh.setRawValue(value);
            esh.setDataType(DataType.Double);
            esh.setDoubleValue(value);
            put(name, esh);
        }
        /**
         * Sets a float onto the EsObject.
         * @param    Name of the float.
         * @param    Value of the float.
         */
        public function setFloat(name:String, value:Number):void {

            var esh:EsObjectDataHolder = new EsObjectDataHolder();
            esh.setRawValue(value);
            esh.setDataType(DataType.Float);
            esh.setFloatValue(value);
            put(name, esh);
        }
        /**
         * Sets a boolean onto the EsObject.
         * @param    Name of the boolean.
         * @param    Value of the boolean.
         */
        public function setBoolean(name:String, value:Boolean):void {

            var esh:EsObjectDataHolder = new EsObjectDataHolder();
            esh.setRawValue(value);
            esh.setDataType(DataType.EsBoolean);
            esh.setBooleanValue(value);
            put(name, esh);
        }
        
        /**
         * Sets a byte onto the EsObject.
         * @param    Name of the byte.
         * @param    Value of the byte.
         */
     public function setByte(name:String, value:int):void {
            
            var esh:EsObjectDataHolder = new EsObjectDataHolder();
            esh.setRawValue(value);
            esh.setDataType(DataType.Byte);
            esh.setByteValue(value);
            put(name, esh);
        }
        
        /**
         * Sets a character onto the EsObject.
         * @param    Name of the character.
         * @param    Value of the character.
         */
        public function setChar(name:String, value:String):void {

            var esh:EsObjectDataHolder = new EsObjectDataHolder();
            esh.setRawValue(value);
            esh.setDataType(DataType.Character);
            esh.setCharValue(value);
            put(name, esh);
        }
        /**
         * Sets a long onto the EsObject.
         * @param    Name of the long.
         * @param    Value of the long.
         */
        public function setLong(name:String, value:String):void {

            var esh:EsObjectDataHolder = new EsObjectDataHolder();
            esh.setRawValue(value);
            esh.setDataType(DataType.Long);
            esh.setLongValue(value);
            put(name, esh);
        }
        /**
         * Sets a short onto the EsObject.
         * @param    Name of the short.
         * @param    Value of the short.
         */
        public function setShort(name:String, value:Number):void {

            var esh:EsObjectDataHolder = new EsObjectDataHolder();
            esh.setRawValue(value);
            esh.setDataType(DataType.Short);
            esh.setShortValue(value);
            put(name, esh);
        }
        /**
         * Sets an EsObject onto the EsObject.
         * @param    Name of the EsObject.
         * @param    Value of the EsObject.
         */
        public function setEsObject(name:String, value:EsObject):void {

            var esh:EsObjectDataHolder = new EsObjectDataHolder();
            esh.setRawValue(value);
            esh.setDataType(DataType.EsObject);
            esh.setEsObjectValue(value);
            put(name, esh);
        }
        /**
         * Sets a number onto the EsObject.
         * @param    Name of the number.
         * @param    Value of the number.
         */
        public function setNumber(name:String, value:Number):void {

            var esh:EsObjectDataHolder = new EsObjectDataHolder();
            esh.setRawValue(value);
            esh.setDataType(DataType.EsNumber);
            esh.setNumberValue(value);
            put(name, esh);
        }
        /**
         * Sets an array of integers onto the EsObject.
         * @param    Name of the array.
         * @param    The array.
         */
        public function setIntegerArray(name:String, value:Array):void {

            var esh:EsObjectDataHolder = new EsObjectDataHolder();
            esh.setRawValue(value);
            esh.setDataType(DataType.IntegerArray);
            esh.setIntArrayValue(value);
            put(name, esh);
        }
        
        /**
         * Sets an array of strings onto the EsObject.
         * @param    Name of the array.
         * @param    The array.
         */
        public function setStringArray(name:String, value:Array):void {

            var esh:EsObjectDataHolder = new EsObjectDataHolder();
            esh.setRawValue(value);
            esh.setDataType(DataType.StringArray);
            esh.setStringArrayValue(value);
            put(name, esh);
        }
        
        /**
         * Sets an array of doubles onto the EsObject.
         * @param    Name of the array.
         * @param    The array.
         */
        public function setDoubleArray(name:String, value:Array):void {

            var esh:EsObjectDataHolder = new EsObjectDataHolder();
            esh.setRawValue(value);
            esh.setDataType(DataType.DoubleArray);
            esh.setDoubleArrayValue(value);
            put(name, esh);
        }
        
        /**
         * Sets an array of floats onto the EsObject.
         * @param    Name of the array.
         * @param    The array.
         */
        public function setFloatArray(name:String, value:Array):void {

            var esh:EsObjectDataHolder = new EsObjectDataHolder();
            esh.setRawValue(value);
            esh.setDataType(DataType.FloatArray);
            esh.setFloatArrayValue(value);
            put(name, esh);
        }
        /**
         * Sets an array of booleans onto the EsObject.
         * @param    Name of the array.
         * @param    The array.
         */
        public function setBooleanArray(name:String, value:Array):void {

            var esh:EsObjectDataHolder = new EsObjectDataHolder();
            esh.setRawValue(value);
            esh.setDataType(DataType.BooleanArray);
            esh.setBooleanArrayValue(value);
            put(name, esh);
        }
        
        /**
         * Sets an array of bytes onto the EsObject.
         * @param    Name of the array.
         * @param    The array.
         */
     
        public function setByteArray(name:String, value:ByteArray):void {

            var esh:EsObjectDataHolder = new EsObjectDataHolder();
            esh.setRawValue(value);
            esh.setDataType(DataType.EsByteArray);
            esh.setByteArrayValue(value);
            put(name, esh);
        }
     
        
        /**
         * Sets an array of characters onto the EsObject.
         * @param    Name of the array.
         * @param    The array.
         */
        public function setCharArray(name:String, value:Array):void {

            var esh:EsObjectDataHolder = new EsObjectDataHolder();
            esh.setRawValue(value);
            esh.setDataType(DataType.CharacterArray);
            esh.setCharArrayValue(value);
            put(name, esh);
        }
        
        /**
         * Sets an array of longs onto the EsObject.
         * @param    Name of the array.
         * @param    The array.
         */
        public function setLongArray(name:String, value:Array):void {

            var esh:EsObjectDataHolder = new EsObjectDataHolder();
            esh.setRawValue(value);
            esh.setDataType(DataType.LongArray);
            esh.setLongArrayValue(value);
            put(name, esh);
        }
        
        /**
         * Sets an array of shorts onto the EsObject.
         * @param    Name of the array.
         * @param    The array.
         */
        public function setShortArray(name:String, value:Array):void {

            var esh:EsObjectDataHolder = new EsObjectDataHolder();
            esh.setRawValue(value);
            esh.setDataType(DataType.ShortArray);
            esh.setShortArrayValue(value);
            put(name, esh);
        }
        
        /**
         * Sets an array of EsObjects onto the EsObject.
         * @param    Name of the array.
         * @param    The array.
         */
        public function setEsObjectArray(name:String, value:Array):void {

            var esh:EsObjectDataHolder = new EsObjectDataHolder();
            esh.setRawValue(value);
            esh.setDataType(DataType.EsObjectArray);
            esh.setEsObjectArrayValue(value);
            put(name, esh);
        }
        
        /**
         * Sets an array of numbers onto the EsObject.
         * @param    Name of the array.
         * @param    The array.
         */
        public function setNumberArray(name:String, value:Array):void {

            var esh:EsObjectDataHolder = new EsObjectDataHolder();
            esh.setRawValue(value);
            esh.setDataType(DataType.NumberArray);
            esh.setNumberArrayValue(value);
            put(name, esh);
        }
        
        private function getHolderForName(name:String):EsObjectDataHolder {
            var holder:EsObjectDataHolder = data[name];
            if(holder == null) {
               throw new Error("Unable to locate variable named '" + name + "' on EsObject");
            }
            return holder;
        }
        /**
         * Gets the value of the property based on a name..
         * @param    Name of the property.
         * @return The value of the property.
         */
        public function getInteger(name:String):Number {
            return getHolderForName(name).getIntValue();
        }
        
        /**
         * Gets the value of the property based on a name..
         * @param    Name of the property.
         * @return The value of the property.
         */
        public function getString(name:String):String {
            return getHolderForName(name).getStringValue();
        }
        
        /**
         * Gets the value of the property based on a name..
         * @param    Name of the property.
         * @return The value of the property.
         */
        public function getDouble(name:String):Number {
            return getHolderForName(name).getDoubleValue();
        }
        
        /**
         * Gets the value of the property based on a name..
         * @param    Name of the property.
         * @return The value of the property.
         */
        public function getFloat(name:String):Number {
            return getHolderForName(name).getFloatValue();
        }
        
        /**
         * Gets the value of the property based on a name..
         * @param    Name of the property.
         * @return The value of the property.
         */
        public function getBoolean(name:String):Boolean {
            return getHolderForName(name).getBooleanValue();
        }
        
        /**
         * Gets the value of the property based on a name..
         * @param    Name of the property.
         * @return The value of the property.
         */
     public function getByte(name:String):int {
            return getHolderForName(name).getByteValue();
        }
        
        /**
         * Gets the value of the property based on a name..
         * @param    Name of the property.
         * @return The value of the property.
         */
        public function getChar(name:String):String {
            return getHolderForName(name).getCharValue();
        }
        
        /**
         * Gets the value of the property based on a name..
         * @param    Name of the property.
         * @return The value of the property.
         */
        public function getLong(name:String):String {
            return getHolderForName(name).getLongValue();
        }
        
        /**
         * Gets the value of the property based on a name..
         * @param    Name of the property.
         * @return The value of the property.
         */
        public function getShort(name:String):Number {
            return getHolderForName(name).getShortValue();
        }
        
        /**
         * Gets the value of the property based on a name..
         * @param    Name of the property.
         * @return The value of the property.
         */
        public function getEsObject(name:String):EsObject {
            return getHolderForName(name).getEsObjectValue();
        }
            
        /**
         * Gets the value of the property based on a name..
         * @param    Name of the property.
         * @return The value of the property.
         */
        public function getNumber(name:String):Number {
            return getHolderForName(name).getNumberValue();
        }
        
        /**
         * Gets the value of the property based on a name..
         * @param    Name of the property.
         * @return The value of the property.
         */
        public function getIntegerArray(name:String):Array {
            return getHolderForName(name).getIntArrayValue();
        }
        
        /**
         * Gets the value of the property based on a name..
         * @param    Name of the property.
         * @return The value of the property.
         */
        public function getStringArray(name:String):Array {
            return getHolderForName(name).getStringArrayValue();
        }
        
        /**
         * Gets the value of the property based on a name..
         * @param    Name of the property.
         * @return The value of the property.
         */
        public function getDoubleArray(name:String):Array {
            return getHolderForName(name).getDoubleArrayValue();
        }
        
        /**
         * Gets the value of the property based on a name..
         * @param    Name of the property.
         * @return The value of the property.
         */
        public function getFloatArray(name:String):Array {
            return getHolderForName(name).getFloatArrayValue();
        }
        
        /**
         * Gets the value of the property based on a name..
         * @param    Name of the property.
         * @return The value of the property.
         */
        public function getBooleanArray(name:String):Array {
            return getHolderForName(name).getBooleanArrayValue();
        }
        
        /**
         * Gets the value of the property based on a name..
         * @param    Name of the property.
         * @return The value of the property.
         */
     
        public function getByteArray(name:String):ByteArray {
            return getHolderForName(name).getByteArrayValue();
        }
    
        
        /**
         * Gets the value of the property based on a name..
         * @param    Name of the property.
         * @return The value of the property.
         */
        public function getCharArray(name:String):Array {
            return getHolderForName(name).getCharArrayValue();
        }
        
        /**
         * Gets the value of the property based on a name..
         * @param    Name of the property.
         * @return The value of the property.
         */
        public function getLongArray(name:String):Array {
            return getHolderForName(name).getLongArrayValue();
        }
        
        /**
         * Gets the value of the property based on a name..
         * @param    Name of the property.
         * @return The value of the property.
         */
        public function getShortArray(name:String):Array {
            return getHolderForName(name).getShortArrayValue();
        }
        
        /**
         * Gets the value of the property based on a name..
         * @param    Name of the property.
         * @return The value of the property.
         */
        public function getEsObjectArray(name:String):Array {
            return getHolderForName(name).getEsObjectArrayValue();
        }
        
        /**
         * Gets the value of the property based on a name..
         * @param    Name of the property.
         * @return The value of the property.
         */
        public function getNumberArray(name:String):Array {
            return getHolderForName(name).getNumberArrayValue();
        }
        
        /**
         * Remove a variable from the EsObject that has the name passed in.
         * @param    Name of the variable to remove.
         */
        public function removeVariable(name:String):void {

            delete data[name];
            for (var i:Number=0;i<list.length;++i) {
                var dh:EsObjectDataHolder = list[i];
                if (dh.getName() == name) {
                    list.splice(i, 1);
                    break;
                }
            }
        }
        
        /**
         * Completely clears out the EsObject.
         */
        public function removeAll():void {

            data = new Object();
            list = new Array();
        }
        /**
         * Gets the value of a variable before it has been cast to any data type.
         * @param    Name of the variable to get.
         * @return The raw value of the variable.
         */
        public function getRawVariable(name:String):Object {
            return getHolderForName(name).getRawValue();
        }
      }
}
