package com.electrotank.electroserver4.protocol.text {
    import com.electrotank.electroserver4.protocol.MessageWriter;
     import flash.utils.ByteArray;
    
    public class StringMessageWriter implements MessageWriter {

        private var data:String;
        private var pads_arr:Array;
        public function StringMessageWriter() {
            pads_arr = ["", " ", "  ", "   ", "    ", "     ", "      ", "       ", "        ", "         ", "          ", "           ", "            ", "             ", "              ", "               ", "                ", "                 ", "                  ", "                   "];
            setMessage("");
        }
        public function setMessage(str:String):void {

            data = str;
        }
        public function getMessage():String {
            return data;
        }
        private function pad(pad_str:String, padSize:Number):String {
            var numToAdd:Number = padSize-pad_str.length;
            pad_str = pads_arr[numToAdd]+pad_str;
            return pad_str;
        }
        public function append(str:String):void {

            data += str;
        }
        
    
        public function writeCharacter(character:String):void {

            append(character);
        }
        
        public function writePrefixedString(string:String, lengthPrefixSize:Number):void {

            if(string == null) {
                string = "";
            }
            
            if( lengthPrefixSize > 0 ) {
                writeInteger(string.length, lengthPrefixSize);
            }
            
            append(string);
        }
        private function trim(str:String):String {
            var trimChar:String = " ";
            while(str.substr(0, 1) == trimChar) {
                str = str.substr(1);
            }
            return str;
        }
        
        public function writeString(string:String):void {

            if (string == null) {
                return;
            }
            
            var outString:String = trim(string);
            
            // write out the prefix
            writeInteger(outString.length);
            
            // write out the string
            append(outString);
        }
        
     public function writeInteger(... arguments):void {
     var integer:int = arguments[0];
            var string:String = integer.toString();
            if (arguments.length == 2) {
                var length:Number = arguments[1];
                if(string.length > length) {
                    //throw new RuntimeException("Integer is longer then the specified length");
                    trace("Integer is longer then the specified length");
                }
                //append(zeros[length - string.length]);
                //append(string);
                append(pad(string, length));
            } else {
                _writePrefix(string.length);
                append(string);
            }
        }
    
     public function writeLong(... arguments):void {
            var longIn:String = arguments[0];
            var string:String = longIn.toString();
            if (arguments.length == 2 ) {
                var length:Number = arguments[1];
                if(string.length > length) {
                    trace("Long is longer then the specified length");
                    //throw new RuntimeException("Long is longer then the specified length");
                }
                //append(zeros[length - string.length]);
                //append(string);
                append(pad(string, length));
            } else {
                _writePrefix(string.length);
                append(string);
            }
        }
    
     public function writeDouble(... arguments):void {
            var doubleIn:Number = arguments[0];
            var string:String = doubleIn.toString();
            if (arguments.length == 2) {
                var length:Number = arguments[1];
                if(string.length > length) {
                    trace("Double is longer then the specified length");
                    //throw new RuntimeException("Double is longer then the specified length");
                }
                //append(zeros[length - string.length]);
                //append(string);
                append(pad(string, length));
            } else {
                _writePrefix(string.length);
                append(string);
            }
        }
    
        public function writeBoolean(bool:Boolean):void {

            if(bool) {
                append("1");
            } else {
                append("0");
            }
        }
        
     public function writeShort(... arguments):void {
            var number:Number = arguments[0];
            var string:String = number.toString();
            if (arguments.length == 2) {
                var length:Number = arguments[1];
                if(string.length > length) {
                    trace("Integer is longer then the specified length");
                    //throw new RuntimeException("Integer is longer then the specified length");
                }
                //append(zeros[length - string.length]);
                //append(string);
                append(pad(string, length));
            } else {
                _writePrefix(string.length);
                append(string);
            }
        }
        
     public function writeByte(byteIn:int):void {

            
     
                var byteString:String = byteIn.toString(16);
                if (byteString.length < 2) {
                    byteString = "0" + byteString;
                }
                writeString(byteString);
            
    
            
            
     
        }
    
        public function writeFloat(floatIn:Number):void {

            var string:String = floatIn.toString();
            _writePrefix(string.length);
            append(string);
        }
    
        // Array writers
        public function writeIntegerArray(array:Array):void {

            var cnt:Number = array.length;
            
            _writeArrayPrefix(cnt);
            
            for (var i:Number = 0; i < cnt; i++) {
                writeInteger(array[i]);
            }
        }
        
        
        
        public function writeBooleanArray(array:Array):void {

            var cnt:Number = array.length;
            
            _writeArrayPrefix(cnt);
            
            for (var i:Number = 0; i < cnt; i++) {
                writeBoolean(array[i]);
            }
        }
        
     /*
        public function writeByteArray(array:Array):void {

            trace("WRITE BYTE ARRAY in STringMessageWriter not implemented yet!!!!");
            //writeString(HexUtils.asHex(array));
        }
     */
        
     
        public function writeByteArray(array:ByteArray):void {

            var len:int = array.length;
            writeInteger(len);
            for (var i:int=0;i<len;++i) {
                writeByte(array[i]);
            }
        }
     
        public function writeCharacterArray(array:Array):void {

            var cnt:Number = array.length;
            
            _writeArrayPrefix(cnt);
            
            for (var i:Number = 0; i < cnt; i++) {
                writeCharacter(array[i]);
            }
        }
    
        public function writeDoubleArray(array:Array):void {

            var cnt:Number = array.length;
            
            _writeArrayPrefix(cnt);
            
            for (var i:Number = 0; i < cnt; i++) {
                writeDouble(array[i]);
            }
        }
    
        public function writeFloatArray(array:Array):void {

            var cnt:Number = array.length;
            
            _writeArrayPrefix(cnt);
            
            for (var i:Number = 0; i < cnt; i++) {
                writeFloat(array[i]);
            }
        }
    
        public function writeLongArray(array:Array):void {

            var cnt:Number = array.length;
            
            _writeArrayPrefix(cnt);
            
            for (var i:Number = 0; i < cnt; i++) {
                writeLong(array[i]);
            }
        }
    
        public function writeShortArray(array:Array):void {

            var cnt:Number = array.length;
            
            _writeArrayPrefix(cnt);
            
            for (var i:Number = 0; i < cnt; i++) {
                writeShort(array[i]);
            }
        }
    
        public function writeStringArray(array:Array):void {

            var cnt:Number = array.length;
            
            _writeArrayPrefix(cnt);
            
            for (var i:Number = 0; i < cnt; i++) {
                writeString(array[i]);
            }
        }
    
        public function getData():String {
            return data;
        }
    
        public function setData(d:String):void {

            data = d;
        }
    
        private function _writePrefix(prefix:Number):void {

            append(prefix.toString(36));
        }
        
        private function _writeArrayPrefix(arrayCount:Number):void {

            _writePrefix(arrayCount.toString().length);
            append(arrayCount.toString());
        }
        
        
    }
}
