     
            package com.electrotank.electroserver4.protocol.binary {
                import flash.utils.ByteArray;
                import com.electrotank.electroserver4.protocol.MessageWriter;
            
                public class BinaryMessageWriter implements MessageWriter{
                    
                    private var buffer:ByteArray;
                    private var charset:String;
            
                    public function BinaryMessageWriter() {
                        buffer = new ByteArray();
                        buffer.writeInt(0);
                        charset = "utf-8";
                    }
                    public function getBuffer():ByteArray {
                        var position:uint = buffer.position;
                        var length:uint = buffer.length;
    
                        buffer.position = 0;
                        buffer.writeInt(length - 4);
                        buffer.position = position;
    
                        return buffer;
                    }
                    public static function dumpByteArray( bytes:ByteArray ):String {
    
                        var s:String = '';
    
                        for ( var i:int = 0; i < bytes.length; ++i ) {
                            s += Number(bytes[i]).toString(16) + " ";
                        }
    
                        return s;
                    }
                    public function getMessage():String {
                        return buffer.toString();
                    }
                    public function getData():String {
                        return dumpByteArray(buffer);
                    }
            
                    public function writeBoolean(bool:Boolean):void {
                        buffer.writeBoolean(bool);
                    }
            
                    public function writeInteger(... arguments):void {
                        var integer:int = arguments[0];
                        buffer.writeInt(integer);
                    }
                    
                    public function writeLong(... arguments):void {
                        throw new Error("Writing logs is not supported");
                        //var longIn:String = arguments[0];
                        //buffer.putLong(longIn);
                    }
            
                    
                    public function writeDouble(... arguments):void {
                       var doubleIn:Number = arguments[0];
                       buffer.writeDouble(doubleIn);
                    }
            
                    public function writeCharacter(s:String):void {
                        buffer.writeByte(0);
                        buffer.writeUTFBytes(s);
                        //buffer.writeMultiByte(char, charset);
                    }
                    
                    
                    public function writeShort(... arguments):void {
                        var number:int = arguments[0];
                        buffer.writeShort(number);
                    }
                    
                    public function writeByte(byteIn:int):void {
                        buffer.writeByte(byteIn);
                    }
            
                    public function writeFloat(floatIn:Number):void {
                        buffer.writeFloat(floatIn);
                    }
                    
                    public function writePrefixedString(string:String, lengthPrefixSize:Number):void {
            
                        writeString(string);
                    }
                    public function writeString(string:String):void {
                        buffer.writeUTF(string);
                        /*
                        var intPosition:int = buffer.position;
                        buffer.position = intPosition+4;
                        buffer.writeMultiByte(string, charset);
                        var endStringPosition:int = buffer.position;
                        var intValue:int = endStringPosition-intPosition-4;
                        buffer.position = intPosition;
                        writeInteger(intValue);
                        buffer.position = endStringPosition;*/
            
                    }
                    
                    public function writeIntegerArray(array:Array):void {
                        var cnt:int = array.length;
                        writeInteger(cnt);
                        
                        for (var i:int = 0; i < cnt; i++) {
                            writeInteger(array[i]);
                        }
                    }
            
                    public function writeBooleanArray(array:Array):void {
                        var cnt:int = array.length;
                        writeInteger(cnt);
                        
                        for (var i:int = 0; i < cnt; i++) {
                            writeBoolean(array[i]);
                        }
                    }
            
                    public function writeByteArray(array:ByteArray):void {
                        var cnt:int = array.length;
                        writeInteger(cnt);
                        
                        for (var i:int = 0; i < cnt; i++) {
                            writeByte(array[i]);
                        }
                    }
            
                    public function writeCharacterArray(array:Array):void {
                        var cnt:int = array.length;
                        writeInteger(cnt);
                        
                        for (var i:int = 0; i < cnt; i++) {
                            writeCharacter(array[i]);
                        }
                    }
            
                    public function writeDoubleArray(array:Array):void {
                        var cnt:int = array.length;
                        writeInteger(cnt);
                        
                        for (var i:int = 0; i < cnt; i++) {
                            writeDouble(array[i]);
                        }
                    }
            
                    public function writeFloatArray(array:Array):void {
                        var cnt:int = array.length;
                        writeInteger(cnt);
                        
                        for (var i:int = 0; i < cnt; i++) {
                            writeFloat(array[i]);
                        }
                    }
            
                    public function writeLongArray(array:Array):void {
                        var cnt:int = array.length;
                        writeInteger(cnt);
                        
                        for (var i:int = 0; i < cnt; i++) {
                            writeLong(array[i]);
                        }
                    }
            
                    public function writeShortArray(array:Array):void {
                        var cnt:int = array.length;
                        writeInteger(cnt);
                        
                        for (var i:int = 0; i < cnt; i++) {
                            writeShort(array[i]);
                        }
                    }
            
                    public function writeStringArray(array:Array):void {
                        var cnt:int = array.length;
                        writeInteger(cnt);
        
                        for (var i:int=0; i < cnt; i++) {
                            writeString(array[i]);
                        }
                    }        
                }
                
            }
     
