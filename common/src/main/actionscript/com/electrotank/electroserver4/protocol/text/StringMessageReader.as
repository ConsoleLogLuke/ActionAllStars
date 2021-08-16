package com.electrotank.electroserver4.protocol.text {
    import com.electrotank.electroserver4.protocol.MessageReader;
     import flash.utils.ByteArray;
    
    public class StringMessageReader implements MessageReader {

        private var data:String;
        private var currentPosition:Number;
        
        public function setMessage(mes:String):void {

            data = mes;
        }
        public function getMessage():String {
            return data;
        }
        
        public function StringMessageReader() {
            setCurrentPosition(0);
        }
        public function nextPrefixedString(lengthPrefixSize:Number):String {
     var num:int = nextInteger(lengthPrefixSize);
            var string:String = _nextString(num);
            return string;
        }
        
     public function nextString(... arguments):String {
            if (arguments.length == 0) {
                var np:Number = _nextPrefix();
                return nextPrefixedString(np);
            } else {
                var length:Number = arguments[0];
                var string:String = _nextString(length);
                //currentPosition += length;
                return string;
            }
        }
        private function trim(str:String):String {
            var trimChar:String = " ";
            while(str.substr(0, 1) == trimChar) {
                str = str.substr(1);
            }
            return str;
        }
    
        
     public function nextInteger(... arguments):int {
            if (arguments.length == 1) {
                var preNum:String = _nextString(arguments[0]);
     var num:int = parseInt(preNum);
                return num;
                //return parseInt(trim(_nextString(arguments[0])));
            } else {
                return nextInteger(_nextPrefix());
            }
        }
        
        
        
     public function nextLong(... arguments):String {
            if (arguments.length == 1) {
                return _nextString(arguments[0]);
                //return parseInt(trim(_nextString(arguments[0])), 36);
                //return Long.parseLong(_nextString(length).trim(), Character.MAX_RADIX);
            } else {
                return nextLong(_nextPrefix());
            }
        }
        
        
        
     public function nextDouble(... arguments):Number {
            if (arguments.length == 1) {
                return parseFloat(trim(_nextString(arguments[0])));
                //return Double.parseDouble(_nextString(length).trim());
            } else {
                return nextDouble(_nextPrefix());
            }
        }
        
        
        
        
     public function nextShort(... arguments):Number {
            if (arguments.length == 1) {
                var arg:Number = arguments[0];
                var ns:String = _nextString(arg);
                var tns:String = trim(ns);
                return parseInt(tns);
                //return Short.parseShort(_nextString(length).trim());
            } else {
                var np:Number = _nextPrefix();
                var n:Number = nextShort(np);
                return n;
            }
        }
    
        
        
        
        public function nextCharacter():String {
            var string:String = _nextString(1);
            return string.charAt(0);
        }
        
        
        
        
        public function nextBoolean():Boolean {
    
            var results:Boolean = false;
     var d:int = nextInteger(1);
            if(d == 1) {
                results = true;
            }
    
            return results;
        }
    
     public function nextByte():int {
     var byteArrayString:int = int("0x" + nextString());
            return byteArrayString;
            //var bytes:Array = HexUtils.fromHexStringToByteArray(byteArrayString);
            //if (bytes.length != 1) {
                // TODO throw an exception
            //}
            
            //return bytes[0];
        }
    
        public function nextFloat():Number {
            return parseFloat(trim(_nextString(_nextPrefix())));
        }
    
        // Array readers
     public function nextIntegerArray(... arguments):Array {
            var array:Array;
            var i:Number;
            
            if (arguments.length == 2) {
                var count:Number = arguments[0];
                var length:Number = arguments[1];
                array = new Array();
        
                for(i = 0; i < count; i++) {
                   array[i] = nextInteger(length);
                }
        
                return array;
            } else {
                var cnt:Number = _nextArrayPrefix();
                array = new Array();
                
                for (i = 0; i < cnt; i++) {
                    array[i] = nextInteger();
                }
                
                return array;
            }
        }
    
        
        public function nextBooleanArray():Array {
            var cnt:Number = _nextArrayPrefix();
            var array:Array = new Array();
            
            for (var i:Number = 0; i < cnt; i++) {
                array[i] = nextBoolean();
            }
            
            return array;
        }
        
     /*
            var byteArrayString:String = nextString();
            var arr:Array = new Array();
            for (var i:Number=0;i<byteArrayString.length;++i) {
                arr.push(byteArrayString[i]);
            }
            return arr;
            //return HexUtils.fromHexStringToByteArray(byteArrayString);
        }
     */
        
     
        public function nextByteArray():ByteArray {
            var len:int = nextInteger();
            var arr:ByteArray = new ByteArray();
            for (var i:Number=0;i<len;++i) {
                arr[i] = nextByte();
            }
            return arr;
        }
     
        public function nextCharacterArray():Array {
            var cnt:Number = _nextArrayPrefix();
            var array:Array = new Array();
            
            for (var i:Number = 0; i < cnt; i++) {
                array[i] = nextCharacter();
            }
            return array;
        }
    
        public function nextDoubleArray():Array {
            var cnt:Number = _nextArrayPrefix();
            var array:Array = new Array();
            trace("count: "+cnt)
            for (var i:Number = 0; i < cnt; i++) {
                array[i] = nextDouble();
            }
            trace(array)
            return array;
        }
    
        public function nextFloatArray():Array {
            var cnt:Number = _nextArrayPrefix();
            var array:Array = new Array();
            
            for (var i:Number = 0; i < cnt; i++) {
                array[i] = nextFloat();
            }
            
            return array;
        }
    
        public function nextLongArray():Array {
            var cnt:Number = _nextArrayPrefix();
            var array:Array = new Array();
            
            for (var i:Number = 0; i < cnt; i++) {
                array[i] = nextLong();
            }
            
            return array;
        }
    
        public function nextShortArray():Array {
            var cnt:Number = _nextArrayPrefix();
            var array:Array = new Array();
            
            for (var i:Number = 0; i < cnt; i++) {
                array[i] = nextShort();
            }
            
            return array;
        }
    
        public function nextStringArray():Array {
            var cnt:Number = _nextArrayPrefix();
            var array:Array = new Array();
            
            for (var i:Number = 0; i < cnt; i++) {
                array[i] = nextString();
            }
            
            return array;
        }
    
        public function getData():String {
            return data;
        }
    
        public function setData(d:String):void {

            data = d
        }
    
        public function getCurrentPosition():Number {
            return currentPosition;
        }
    
        public function setCurrentPosition(ind:Number):void {

            currentPosition = ind;
        }
    
        private function  _nextString(length:Number):String {
            if(data.length < currentPosition + length) {
                trace("Requested string is longer than available data");
               // throw new RuntimeException("Requested string is longer than available data");
            }
            var output:String = data.substring(currentPosition, currentPosition + length);
            currentPosition += length;
            return output;
        }
    
        private function _nextPrefix():Number {
            var preamble:String = nextCharacter();
            return parseInt(preamble, 36);
        }
     private function _nextArrayPrefix():int {
            return nextInteger(_nextPrefix());
        }
    }
}
