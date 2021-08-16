package com.electrotank.electroserver4.protocol.codec {
    import com.electrotank.electroserver4.MessageConstants;
    import com.electrotank.electroserver4.protocol.codec.*;
    import com.electrotank.electroserver4.protocol.*;
    import com.electrotank.electroserver4.message.Message;
    import com.electrotank.electroserver4.message.event.*;
    import com.electrotank.electroserver4.message.response.*;
    import com.electrotank.electroserver4.message.request.*;
    import com.electrotank.electroserver4.room.*;
    import com.electrotank.electroserver4.entities.*;
    import com.electrotank.electroserver4.esobject.EsObject;
    
    public class UserListUpdateEventCodec extends MessageCodecImpl {

        override public function decode(reader:MessageReader):Message {
            var event:UserListUpdateEvent = new UserListUpdateEvent();
            
            var zoneId:Number = reader.nextInteger(MessageConstants.ZONE_ID_LENGTH);
            event.setZoneId(zoneId);
    
            var roomId:Number = reader.nextInteger(MessageConstants.ROOM_ID_LENGTH);
            event.setRoomId(roomId);
    
            // Get the action
            var actionId:Number = reader.nextShort(MessageConstants.UPDATE_ACTION_LENGTH);
            
            event.setActionId(actionId);
    
            // Get the user id
            var userId:String = reader.nextLong(MessageConstants.USER_ID_LENGTH);
            event.setUserId(userId);
    
            // Get the username if needed
            if(actionId == UserListUpdateEvent.AddUser) {
                var userName:String = reader.nextPrefixedString(MessageConstants.USER_NAME_PREFIX_LENGTH);
                event.setUserName(userName);
                
                var count:Number = reader.nextInteger(MessageConstants.VARIABLE_COUNT_LENGTH);
                var pairs:Array = new Array();
                for (var i:Number = 0; i < count; i++) {
                    var name:String = reader.nextPrefixedString(MessageConstants.VARIABLE_NAME_PREFIX_LENGTH);
                    var value:EsObject = EsObjectCodec.decode(reader);
                    pairs.push(new UserVariable(name, value));
                }
                
                event.setUserVariables(pairs);
                
                event.setIsSendingVideo(reader.nextBoolean());
                if (event.getIsSendingVideo()) {
                    event.setVideoStreamName(reader.nextPrefixedString(MessageConstants.VIDEO_STREAM_NAME_PREFIX_LENGTH));
                }
            } else if (actionId == UserListUpdateEvent.SendingVideoStream) {
                event.setIsSendingVideo(true);
                event.setVideoStreamName(reader.nextPrefixedString(MessageConstants.VIDEO_STREAM_NAME_PREFIX_LENGTH));
            } else if (actionId == UserListUpdateEvent.StoppingVideoStream) {
                event.setIsSendingVideo(false);
                event.setVideoStreamName("");
            }
    
            return event;
        }
    }
}
