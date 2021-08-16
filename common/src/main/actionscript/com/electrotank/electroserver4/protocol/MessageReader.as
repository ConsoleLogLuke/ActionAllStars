package com.electrotank.electroserver4.protocol {
    import com.electrotank.electroserver4.protocol.*;
     import flash.utils.ByteArray;
    
    
    public interface MessageReader {

        
    
        
        function nextPrefixedString(lengthPrefixSize:Number):String;
    
    
        
        function nextCharacter():String;
        function nextBoolean():Boolean;
        
     function nextString(... arguments):String;
        
     function nextShort(... arguments):Number;
        
     function nextInteger(... arguments):int;
        
     function nextLong(... arguments):String;
        
     function nextDouble(... arguments):Number;
        function nextFloat():Number;
        
     function nextByte():int;
        
     function nextIntegerArray(... arguments):Array;
        function nextStringArray():Array;
        function nextCharacterArray():Array;
        function nextBooleanArray():Array;
        function nextShortArray():Array;
        function nextLongArray():Array;
        function nextDoubleArray():Array;
        function nextFloatArray():Array;
     function nextByteArray():ByteArray;
    
        
    }
}
