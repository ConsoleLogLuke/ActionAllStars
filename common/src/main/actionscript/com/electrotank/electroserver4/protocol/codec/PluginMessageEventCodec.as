package com.electrotank.electroserver4.protocol.codec {
    import com.electrotank.electroserver4.MessageConstants;
    import com.electrotank.electroserver4.protocol.codec.*;
    import com.electrotank.electroserver4.protocol.*;
    import com.electrotank.electroserver4.message.Message;
    import com.electrotank.electroserver4.message.event.*;
    import com.electrotank.electroserver4.message.response.*;
    import com.electrotank.electroserver4.message.request.*;
    import com.electrotank.electroserver4.room.*;
    import com.electrotank.electroserver4.esobject.*;
    
    public class PluginMessageEventCodec extends MessageCodecImpl {

        override public function decode(reader:MessageReader):Message {
            var event:PluginMessageEvent = new PluginMessageEvent();
            event.setPluginName(reader.nextPrefixedString(MessageConstants.PLUGIN_PARM_NAME_PREFIX_LENGTH));
    
            event.setSentToRoom(reader.nextBoolean());
            if(event.wasSentToRoom()) {
                event.setDestinationZoneId(reader.nextInteger(MessageConstants.ZONE_ID_LENGTH));
                event.setDestinationRoomId(reader.nextInteger(MessageConstants.ROOM_ID_LENGTH));
            }
    
            event.setIsRoomLevelPlugin(reader.nextBoolean());
            if(event.getIsRoomLevelPlugin()) {
                event.setOriginZoneId(reader.nextInteger(MessageConstants.ZONE_ID_LENGTH));
                event.setOriginRoomId(reader.nextInteger(MessageConstants.ROOM_ID_LENGTH));
            }
            
            if (reader.nextBoolean()) {
                var esObject:EsObject = EsObjectCodec.decode(reader);
                event.setEsObject(esObject);
            } else {
                //should never go in here
            }
            
            return event;
    
        }
    }
}
