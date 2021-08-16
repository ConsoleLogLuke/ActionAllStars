package com.electrotank.electroserver4.protocol.codec {
    import com.electrotank.electroserver4.MessageConstants;
    import com.electrotank.electroserver4.protocol.codec.*;
    import com.electrotank.electroserver4.protocol.*;
    import com.electrotank.electroserver4.message.Message;
    import com.electrotank.electroserver4.message.request.*;
    import com.electrotank.electroserver4.esobject.*;
    
    public class PluginRequestCodec extends MessageCodecImpl {

        override public function encode(writer:MessageWriter, mess:Message):void {

            var request:PluginRequest = PluginRequest(mess);
            writer.writePrefixedString(request.getPluginName(), MessageConstants.PLUGIN_NAME_PREFIX_LENGTH);
            writer.writeBoolean(request.wasSentToRoom());
            if(request.wasSentToRoom()) {
                writer.writeInteger(request.getZoneId(), MessageConstants.ZONE_ID_LENGTH);
                writer.writeInteger(request.getRoomId(), MessageConstants.ROOM_ID_LENGTH);
            }
            
            // Handle the name value pairs
            //var pairs:Array = request.getPairs();
            //NameValuePairCodec.encode(writer, pairs);
            var parameters:EsObject = request.getEsObject();
            if (parameters == null) {
                writer.writeBoolean(false);
            } else {
                writer.writeBoolean(true);
                EsObjectCodec.encode(writer, parameters);
            }
            
        }
    }
}
