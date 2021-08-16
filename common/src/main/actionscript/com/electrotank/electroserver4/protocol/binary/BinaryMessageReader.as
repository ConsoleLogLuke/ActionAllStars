     
         
            package com.electrotank.electroserver4.protocol.binary {
                import flash.utils.ByteArray;
                import com.electrotank.electroserver4.protocol.MessageReader;
            
                public class BinaryMessageReader implements MessageReader {
                    
                    private var buffer:ByteArray;
                    private var charset:String;
            
                    public function BinaryMessageReader() {
                        charset = "utf-8";
                    }
                    
                    public function setBuffer(buffer:ByteArray):void {
                        this.buffer = buffer;
                    }
            
                    public function nextBoolean():Boolean {
                        return buffer.readBoolean();
                    }
            
                    public function nextInteger(... arguments):int {
                        return _nextInteger();
                    }
                    private function _nextInteger():int {
                        return buffer.readInt();
                    }
                    
                    public function nextLong(... arguments):String {
                        var value:String = "";
                        for (var i:int = 0; i < 8;++i) {
                            var char:String = buffer.readByte().toString(16);
                            if (char.length == 1) {
                                char = "0" + char;
                            }
                            value += char;
                        }
                        return value;
                        
                        //return _nextLong();
                    }
                    private function _nextLong():String {
                        
                        return buffer.readUTF();
                    }
                            
                    public function nextDouble(... arguments):Number {
                        //var length:int = arguments[0];
                        return _nextDouble();
                    }
                    private function _nextDouble():Number {
                        return buffer.readDouble();
                    }
                    
                    public function nextShort(... arguments):Number {
                        return Number(_nextShort());
                    }
                    private function _nextShort():int {
                        return buffer.readShort();
                    }
                            
                    public function nextCharacter():String {
                        buffer.readByte();
                        return buffer.readUTFBytes(1);
                        //return buffer.readMultiByte(1, charset);
                    }
            
                    public function nextByte():int {
                        return buffer.readByte();
                    }
            
                    public function nextFloat():Number {
                        return buffer.readFloat();
                    }
            
                    public function nextPrefixedString(lengthPrefixSize:Number):String {
                        return nextString();
                    }
                    
                    public function nextString(... arguments):String {
                        return buffer.readUTF();
                       // var len:int = _nextInteger();
                        //return buffer.readMultiByte(len, charset);
                    }
                            
                    public function nextIntegerArray(... arguments):Array {
                        var cnt:int = _nextInteger();
                        var array:Array = new Array(cnt);
                        
                        for (var i:int = 0; i < cnt; i++) {
                            array[i] = _nextInteger();
                        }
                        
                        return array;
                    }
            
                    public function nextBooleanArray():Array {
                        var cnt:int = _nextInteger();
                        var array:Array = new Array(cnt);
                        
                        for (var i:Number = 0; i < cnt; i++) {
                            array[i] = nextBoolean();
                        }
                        
                        return array;
                    }
            
                    public function nextByteArray():ByteArray {
                        var cnt:int = _nextInteger();
                        var array:ByteArray = new ByteArray();
                        
                        for (var i:Number = 0; i < cnt; i++) {
                            array[i] = nextByte();
                        }
                        
                        return array;
                    }
            
                    public function nextCharacterArray():Array {
                        var cnt:int = _nextInteger();
                        var array:Array = new Array(cnt);
                        
                        for (var i:Number = 0; i < cnt; i++) {
                            array[i] = nextCharacter();
                        }
                        
                        return array;
                    }
            
                    public function nextDoubleArray():Array {
                        var cnt:int = _nextInteger();
                        var array:Array = new Array(cnt);
                        
                        for (var i:Number = 0; i < cnt; i++) {
                            array[i] = _nextDouble();
                        }
                        
                        return array;
                    }
            
                    public function nextFloatArray():Array {
                        var cnt:int = _nextInteger();
                        var array:Array = new Array(cnt);
                        
                        for (var i:Number = 0; i < cnt; i++) {
                            array[i] = nextFloat();
                        }
                        
                        return array;
                    }
            
                    public function nextLongArray():Array {
                        var cnt:int = _nextInteger();
                        var array:Array = new Array(cnt);
                        
                        for (var i:Number = 0; i < cnt; i++) {
                            array[i] = _nextLong();
                        }
                        
                        return array;
                    }
            
                    public function nextShortArray():Array {
                        var cnt:int = _nextInteger();
                        var array:Array = new Array(cnt);
                        
                        for (var i:Number = 0; i < cnt; i++) {
                            array[i] = _nextShort();
                        }
                        
                        return array;
                    }
            
                    public function nextStringArray():Array {
                        var cnt:int = _nextInteger();
                        var array:Array = new Array(cnt);
                        
                        for (var i:Number = 0; i < cnt; i++) {
                            array[i] = nextString();
                        }
                        
                        return array;
                    }        
                }
                
            }
         
    
     
