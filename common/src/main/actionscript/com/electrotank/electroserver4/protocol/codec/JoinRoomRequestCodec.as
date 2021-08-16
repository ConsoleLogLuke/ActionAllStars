package com.electrotank.electroserver4.protocol.codec {
    import com.electrotank.electroserver4.MessageConstants;
    import com.electrotank.electroserver4.protocol.codec.*;
    import com.electrotank.electroserver4.protocol.*;
    import com.electrotank.electroserver4.message.Message;
    import com.electrotank.electroserver4.message.request.*;
    
    public class JoinRoomRequestCodec extends MessageCodecImpl {

        override public function encode(writer:MessageWriter, mess:Message):void {

            var request:JoinRoomRequest = JoinRoomRequest(mess);
            
            // Initialize the needed data
            var zoneId:Number = request.getZoneId();
            var roomId:Number = request.getRoomId();
            var password:String = request.getPassword();
            var isReceivingRoomListUpdates:Boolean = request.getIsReceivingRoomListUpdates();
            var isReceivingRoomDetailUpdates:Boolean = request.getIsReceivingRoomDetailUpdates();
            var isReceivingUserListUpdates:Boolean = request.getIsReceivingUserListUpdates();
            var isReceivingRoomVariableUpdates:Boolean = request.getIsReceivingRoomVariableUpdates();
            var isReceivingUserVariableUpdates:Boolean = request.getIsReceivingUserVariableUpdates();
            var isReceivingVideoEvents:Boolean = request.getIsReceivingVideoEvents();
    
            // Handle the zone
            writer.writeInteger(zoneId, MessageConstants.ZONE_ID_LENGTH);
    
            // Handle the room
            writer.writeInteger(roomId, MessageConstants.ROOM_ID_LENGTH);
    
            if (password != null && password != "") {
                writer.writeBoolean(true);
                writer.writePrefixedString(password, MessageConstants.ROOM_PASSWORD_PREFIX_LENGTH);
            } else {
                writer.writeBoolean(false);
            }
    
            writer.writeBoolean(isReceivingRoomListUpdates);
            writer.writeBoolean(isReceivingRoomDetailUpdates);
            writer.writeBoolean(isReceivingUserListUpdates);
            writer.writeBoolean(isReceivingRoomVariableUpdates);
            writer.writeBoolean(isReceivingUserVariableUpdates);
            writer.writeBoolean(isReceivingVideoEvents);
            
        }
    }
}
