package com.electrotank.electroserver4.protocol.codec {
    import com.electrotank.electroserver4.MessageConstants;
    import com.electrotank.electroserver4.protocol.codec.*;
    import com.electrotank.electroserver4.protocol.*;
    import com.electrotank.electroserver4.message.Message;
    import com.electrotank.electroserver4.message.event.*;
    import com.electrotank.electroserver4.message.response.*;
    import com.electrotank.electroserver4.message.request.*;
    import com.electrotank.electroserver4.entities.*;
    
    public class JoinRoomEventCodec extends MessageCodecImpl {

        override public function decode(reader:MessageReader):Message {
            var message:JoinRoomEvent = new JoinRoomEvent();
            message.setZoneId(reader.nextInteger(MessageConstants.ZONE_ID_LENGTH));
            message.setRoomId(reader.nextInteger(MessageConstants.ROOM_ID_LENGTH));
            message.setRoomName(reader.nextPrefixedString(MessageConstants.ROOM_NAME_PREFIX_LENGTH));
            message.setRoomDescription(reader.nextPrefixedString(MessageConstants.ROOM_DESCRIPTION_PREFIX_LENGTH));
            
            message.setCapacity(reader.nextInteger(MessageConstants.ROOM_CAPACITY_LENGTH)); 
             message.setIsHidden(reader.nextBoolean());
             message.setHasPassword(reader.nextBoolean());        
             
            message.setUsers(UserListCodec.decode(reader));
    
            var variables:Array = new Array();
    
            variables = RoomVariableCodec.decode(reader);        
    
            
            message.setRoomVariables(variables);
            
            return message;
        }
    }
}
