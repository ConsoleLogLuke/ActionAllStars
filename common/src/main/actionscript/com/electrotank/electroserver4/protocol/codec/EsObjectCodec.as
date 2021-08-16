package com.electrotank.electroserver4.protocol.codec {
    import com.electrotank.electroserver4.esobject.*;
    import com.electrotank.electroserver4.MessageConstants;
    import com.electrotank.electroserver4.protocol.codec.*;
    import com.electrotank.electroserver4.protocol.*;
    import com.electrotank.electroserver4.message.Message;
    import com.electrotank.electroserver4.message.request.*;
    
    
    public class EsObjectCodec extends MessageCodecImpl {

    
        static public function getDefaultMessageSize():Number {
            return 1024;
        }
    
        static public function encode(writer:MessageWriter, object:EsObject):void {

            // write out the size of the EsObject
            var len:Number = object.getSize();
            writer.writeInteger(object.getSize());
            var entries:Array = object.getEntries();
            for (var i:Number =0;i<len;++i) {
                var entry:EsObjectDataHolder = entries[i];
                encodeObjectEntry(writer, entry);
            }
        }
        static public function encodeMap(writer:MessageWriter, entries:Array):void {

        
            // write out the size of the map
            writer.writeInteger(entries.length);
            
            // Iterate over all the entries in the map
            for (var i:Number=0;i<entries.length;++i) {
                var entry:EsObjectMap = entries[i];
                // Write the key
                writer.writeString(entry.getName());
                
                // Write the esObject
                encode(writer, entry.getValue());
            }
        }
        static private function encodeObjectEntry(writer:MessageWriter, entry:EsObjectDataHolder):void {

            var dataType:DataType = entry.getDataType();
    
            writer.writeCharacter(dataType.getIndicator());
            writer.writeString(entry.getName());
            
            switch (dataType) {
            case DataType.Integer:
                writer.writeInteger(entry.getIntValue());
                break;
            case DataType.EsString:
                writer.writeString(entry.getStringValue());
                break;
            case DataType.Double:
                writer.writeDouble(entry.getDoubleValue());
                break;
            case DataType.Float:
                writer.writeFloat(entry.getFloatValue());
                break;
            case DataType.EsBoolean:
                writer.writeBoolean(entry.getBooleanValue());
                break;
            case DataType.Byte:
                writer.writeByte(entry.getByteValue());
                break;
            case DataType.Character:
                writer.writeCharacter(entry.getCharValue());
                break;
            case DataType.Long:
                writer.writeLong(entry.getLongValue());
                break;
            case DataType.Short:
                writer.writeShort(entry.getShortValue());
                break;
            case DataType.EsNumber:
                writer.writeDouble(entry.getNumberValue());
                break;
            case DataType.EsObject:
                encode(writer, entry.getEsObjectValue());
                break;
            case DataType.EsObjectArray:
               var objectArray:Array = entry.getEsObjectArrayValue();
                writer.writeInteger(objectArray.length);
                for (var i:Number = 0;i<objectArray.length;++i) {
                    encode(writer, objectArray[i]);
                }
                break;
            case DataType.IntegerArray:
                writer.writeIntegerArray(entry.getIntArrayValue());
                break;
            case DataType.StringArray:
                writer.writeStringArray(entry.getStringArrayValue());
                break;
            case DataType.DoubleArray:
                writer.writeDoubleArray(entry.getDoubleArrayValue());
                break;
            case DataType.FloatArray:
                writer.writeFloatArray(entry.getFloatArrayValue());
                break;
            case DataType.BooleanArray:
                writer.writeBooleanArray(entry.getBooleanArrayValue());
                break;
     
            case DataType.EsByteArray:
                writer.writeByteArray(entry.getByteArrayValue());
                break;
     
            case DataType.CharacterArray:
                writer.writeCharacterArray(entry.getCharArrayValue());
                break;
            case DataType.LongArray:
                writer.writeLongArray(entry.getLongArrayValue());
                break;
            case DataType.ShortArray:
                writer.writeShortArray(entry.getShortArrayValue());
                break;
            case DataType.NumberArray:
                var numberArray:Array = entry.getNumberArrayValue();
                writer.writeInteger(numberArray.length);
                for (var j:Number=0;j<numberArray.length;++j) {
                    writer.writeDouble(numberArray[j]);
                }
                break;
            default:
                //throw new RuntimeException("Unable to encode data type " + dataType);
                trace("Unable to encode data type " + dataType);
            }
        }
    
        static public function decode(reader:MessageReader):EsObject {
            var count:Number = reader.nextInteger();
            var object:EsObject = new EsObject();
    
            for (var i:Number = 0; i < count; i++) {
                var indicator:String = reader.nextCharacter();
                
                var dataType:DataType = DataType.findTypeByIndicator(indicator); 
                var name:String = reader.nextString();
                
                switch (dataType) {
                case DataType.Integer:
                    object.setInteger(name, reader.nextInteger());
                    break;
                case DataType.EsString:
                    object.setString(name, reader.nextString());
                    break;
                case DataType.Double:
                    object.setDouble(name, reader.nextDouble());
                    break;
                case DataType.Float:
                    object.setFloat(name, reader.nextFloat());
                    break;
                case DataType.EsBoolean:
                    object.setBoolean(name, reader.nextBoolean());
                    break;
                case DataType.Byte:
                    object.setByte(name, reader.nextByte());
                    break;
                case DataType.Character:
                    object.setChar(name, reader.nextCharacter());
                    break;
                case DataType.Long:
                    object.setLong(name, reader.nextLong());
                    break;
                case DataType.Short:
                    object.setShort(name, reader.nextShort());
                    break;
                case DataType.EsNumber:
                    object.setNumber(name, new Number(reader.nextDouble()));
                    break;
                case DataType.EsObject:
                    object.setEsObject(name, decode(reader));
                    break;
                case DataType.EsObjectArray:
                    var objCount:Number = reader.nextInteger();
                    var objectArray:Array = new Array();
                    for (var j:Number = 0; j < objCount; j++) {
                        objectArray[j] = decode(reader);
                    }
                    object.setEsObjectArray(name, objectArray);
                    break;
                case DataType.IntegerArray:
                    object.setIntegerArray(name, reader.nextIntegerArray());
                    break;
                case DataType.StringArray:
                    object.setStringArray(name, reader.nextStringArray());
                    break;
                case DataType.DoubleArray:
                    object.setDoubleArray(name, reader.nextDoubleArray());
                    break;
                case DataType.FloatArray:
                    object.setFloatArray(name, reader.nextFloatArray());
                    break;
                case DataType.BooleanArray:
                    object.setBooleanArray(name, reader.nextBooleanArray());
                    break;
     
                case DataType.EsByteArray:
                    object.setByteArray(name, reader.nextByteArray());
                    break;
     
                case DataType.CharacterArray:
                    object.setCharArray(name, reader.nextCharacterArray());
                    break;
                case DataType.LongArray:
                    object.setLongArray(name, reader.nextLongArray());
                    break;
                case DataType.ShortArray:
                    object.setShortArray(name, reader.nextShortArray());
                    break;
                case DataType.NumberArray:
                    var doubles:Array = reader.nextDoubleArray();
                    var numberArray:Array = new Array();
                    for (var k:Number = 0; k < doubles.length; k++) {
                        numberArray[k] = Number(doubles[k]);
                    }
                    object.setNumberArray(name, numberArray);
                    break;
                default:
                   // throw new RuntimeException("Unable to encode data type " + dataType);
                   trace("Unable to decode data type " + dataType);
                }
            }
    
            return object;
        }
    
    }
}
