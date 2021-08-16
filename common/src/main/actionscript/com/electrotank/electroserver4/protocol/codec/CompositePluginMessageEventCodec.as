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
    
    public class CompositePluginMessageEventCodec extends MessageCodecImpl {

        override public function decode(reader:MessageReader):Message {
            var event:CompositePluginMessageEvent = new CompositePluginMessageEvent();
            // Get the plugin name
            event.setPluginName(reader.nextPrefixedString(MessageConstants.PLUGIN_PARM_NAME_PREFIX_LENGTH));
            
            // Get the room/zone
            event.setOriginZoneId(reader.nextInteger(MessageConstants.ZONE_ID_LENGTH));
            event.setOriginRoomId(reader.nextInteger(MessageConstants.ROOM_ID_LENGTH));
    
            // Get the number of esobjects
            var count:Number = reader.nextInteger(MessageConstants.COMPOSITE_ESOBJECT_ARRAY_PREFIX_LENGTH);
            
            // Rebuild the list
            var objects:Array = new Array();
            for(var i:Number = 0; i < count; i++) {
                objects.push(EsObjectCodec.decode(reader));
            }
            event.setParameters(objects);        
            return event;
    
    
        }
    }
}
