package com.electrotank.electroserver4.protocol {
    import com.electrotank.electroserver4.protocol.*;
     import flash.utils.ByteArray;
    
    public interface MessageWriter {

        /*function writeCharacter(character:String):void;

        function writePrefixedString(string:String, lengthPrefixSize:Number):void;

        function writeString(string:String, length:Number):void;

        function writeInteger(integer:Number, length:Number):void;

        function writeLong(longIn:Number, length:Number):void;

        function writeBoolean(bool:Boolean):void;

        function writeShort(number:Number):void;*/

        function getData():String;
        function writePrefixedString(string:String, NumberPrefixSize:Number):void;

        function writeCharacter(character:String):void;

       // function writeInteger(integer:Number, length:Number):void;

        //function writeLong(longIn:Number, length:Number):void;

        //function writeDouble(doubleIn:Number, length:Number):void;

        function writeBoolean(boolean:Boolean):void;

        //function writeShort(short:Number, length:Number):void;

        
     function writeInteger(... arguments):void;
        function writeString(string:String):void;

        
     function writeLong(... arguments):void;
        function writeFloat(floatIn:Number):void;

        
     function writeDouble(... arguments):void;
        
     function writeShort(... arguments):void;
        
     function writeByte(byte:int):void;
        
        function writeIntegerArray(intArr:Array):void;

        function writeStringArray(strArr:Array):void;

        function writeLongArray(long:Array):void;

        function writeFloatArray(float:Array):void;

        function writeDoubleArray(double:Array):void;

        function writeShortArray(short:Array):void;

        
     function writeByteArray(byte:ByteArray):void;

        function writeCharacterArray(char:Array):void;

        function writeBooleanArray(boolean:Array):void;

        
        
    }
}
