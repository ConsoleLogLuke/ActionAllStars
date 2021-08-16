package com.electrotank.electroserver4.protocol.codec {
    import com.electrotank.electroserver4.MessageConstants;
    import com.electrotank.electroserver4.protocol.codec.*;
    import com.electrotank.electroserver4.protocol.*;
    import com.electrotank.electroserver4.entities.RoomVariable;
    import com.electrotank.electroserver4.esobject.EsObject;
    
    public class RoomVariableCodec {

        
        
        
       static public function encode(writer:MessageWriter, variables:Array):void {

            writer.writeInteger(variables.length, MessageConstants.ROOM_VARIABLE_COUNT_LENGTH);
            for (var i:Number=0;i<variables.length;++i) {
                var variable:RoomVariable = variables[i];
                writer.writePrefixedString(variable.getName(), MessageConstants.ROOM_VARIABLE_NAME_PREFIX_LENGTH);
                EsObjectCodec.encode(writer, variable.getValue());
                writer.writeBoolean(variable.getLocked());
                writer.writeBoolean(variable.getPersistent());
            }
        }
        
        static public function decode(reader:MessageReader):Array {
            var variables:Array = new Array();
            var variableCnt:Number = reader.nextInteger(MessageConstants.ROOM_VARIABLE_COUNT_LENGTH);
            for (var j:Number = 0; j < variableCnt; j++) {
                var varName:String = reader.nextPrefixedString(MessageConstants.ROOM_VARIABLE_NAME_PREFIX_LENGTH);
                var varValue:EsObject = EsObjectCodec.decode(reader);
                var persistent:Boolean = reader.nextBoolean();
                var locked:Boolean = reader.nextBoolean();
                var variable:RoomVariable = new RoomVariable(varName, varValue, persistent, locked);
                variables.push(variable);
            }
            return variables;
        }
        
    
    }
}
