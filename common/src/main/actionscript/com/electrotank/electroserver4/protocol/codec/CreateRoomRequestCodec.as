package com.electrotank.electroserver4.protocol.codec {
    import com.electrotank.electroserver4.MessageConstants;
    import com.electrotank.electroserver4.protocol.codec.*;
    import com.electrotank.electroserver4.protocol.*;
    import com.electrotank.electroserver4.message.Message;
    import com.electrotank.electroserver4.message.request.*;
    import com.electrotank.electroserver4.entities.*;
    import com.electrotank.electroserver4.plugin.*;
    import com.electrotank.electroserver4.esobject.*;
    
    public class CreateRoomRequestCodec extends MessageCodecImpl {

        override public function encode(writer:MessageWriter, mess:Message):void {

            var request:CreateRoomRequest = CreateRoomRequest(mess);
            
            // Handle the zone
            if (request.getZoneId() == -1) {
                writer.writeBoolean(false);
                writer.writePrefixedString(request.getZoneName(), MessageConstants.ZONE_NAME_PREFIX_LENGTH);
            } else {
                writer.writeBoolean(true);
                writer.writeInteger(request.getZoneId(), MessageConstants.ZONE_ID_LENGTH);
            }
    
            // Handle the room
            writer.writePrefixedString(request.getRoomName(), MessageConstants.ROOM_NAME_PREFIX_LENGTH);
    
            // write the description
            if (request.getRoomDescription() != null && request.getRoomDescription().length != 0) {
                writer.writeBoolean(true);
                writer.writePrefixedString(request.getRoomDescription(), MessageConstants.ROOM_DESCRIPTION_PREFIX_LENGTH);
            } else {
                writer.writeBoolean(false);
            }
    
            if (request.getPassword() != null && request.getPassword().length != 0) {
                writer.writeBoolean(true);
                writer.writePrefixedString(request.getPassword(), MessageConstants.ROOM_PASSWORD_PREFIX_LENGTH);
            } else {
                writer.writeBoolean(false);
            }
            writer.writeInteger(request.getCapacity(), MessageConstants.ROOM_CAPACITY_LENGTH);
    
            writer.writeBoolean(request.getIsPersistent());
            writer.writeBoolean(request.getIsHidden());
    
            writer.writeBoolean(request.getIsReceivingRoomListUpdates());
            writer.writeBoolean(request.getIsReceivingRoomDetailUpdates());
            writer.writeBoolean(request.getIsReceivingUserListUpdates());
            writer.writeBoolean(request.getIsReceivingRoomVariableUpdates());
            writer.writeBoolean(request.getIsReceivingUserVariableUpdates());
            writer.writeBoolean(request.getIsReceivingVideoEvents());
    
            writer.writeBoolean(request.getIsNonOperatorUpdateAllowed());
            writer.writeBoolean(request.getIsNonOperatorVariableUpdateAllowed());
            writer.writeBoolean(request.getIsCreateOrJoinRoom());
            
            RoomVariableCodec.encode(writer, request.getRoomVariables());
    
            
            encodePlugins(writer, request.getPlugins());
            
            writer.writeBoolean(request.getIsUsingLanguageFilter());
            if (request.getIsUsingLanguageFilter()) {
                writer.writeBoolean(request.getIsLanguageFilterSpecified());
                if (request.getIsLanguageFilterSpecified()) {
                    writer.writePrefixedString(request.getLanguageFilterName(), MessageConstants.FILTER_NAME_PREFIX_LENGTH);
                    writer.writeBoolean(request.getIsDeliverMessageOnFailure());
                    writer.writeInteger(request.getFailuresBeforeKick(), MessageConstants.FILTER_FAILURES_BEFORE_KICK_LENGTH);
                    writer.writeInteger(request.getKicksBeforeBan(), MessageConstants.FILTER_KICKS_BEFORE_BAN_LENGTH);
                    writer.writeInteger(request.getBanDuration(), MessageConstants.ROOM_BAN_DURATION_LENGTH);
                    writer.writeBoolean(request.getIsResetAfterKick());
                }
            }
            writer.writeBoolean(request.getIsUsingFloodingFilter());
            if (request.getIsUsingFloodingFilter()) {
                writer.writeBoolean(request.getIsFloodingFilterSpecified());
                if (request.getIsFloodingFilterSpecified()) {
                    writer.writePrefixedString(request.getFloodingFilterName(), MessageConstants.FILTER_NAME_PREFIX_LENGTH);
                    writer.writeInteger(request.getFloodingFilterFailuresBeforeKick(), MessageConstants.FILTER_FAILURES_BEFORE_KICK_LENGTH);
                    writer.writeInteger(request.getFloodingFilterKicksBeforeBan(), MessageConstants.FILTER_KICKS_BEFORE_BAN_LENGTH);
                    writer.writeInteger(request.getFloodingFilterBanDuration(), MessageConstants.ROOM_BAN_DURATION_LENGTH);
                    writer.writeBoolean(request.getIsFloodingFilterResetAfterKick());
                }
            }
            
        }
        private function encodePlugins(writer:MessageWriter, plugins:Array):void {

            writer.writeInteger(plugins.length, MessageConstants.PLUGIN_COUNT_LENGTH);
            for (var i:Number=0;i<plugins.length;++i) {
                var entry:Plugin = plugins[i];
                writer.writePrefixedString(entry.getExtensionName(), MessageConstants.EXTENSION_NAME_PREFIX_LENGTH);
                writer.writePrefixedString(entry.getPluginHandle(), MessageConstants.PLUGIN_HANDLE_PREFIX_LENGTH);
                writer.writePrefixedString(entry.getPluginName(), MessageConstants.PLUGIN_NAME_PREFIX_LENGTH);
    
                var parms:EsObject = entry.getData();
                EsObjectCodec.encode(writer, parms);
            }
        }
       /* private function encodePlugins(writer:MessageWriter, plugins:Array):void {

            writer.writeInteger(plugins.length, MessageConstants.PLUGIN_COUNT_LENGTH);
            for (var i=0;i<plugins.length;++i) {
                var entry:Plugin = plugins[i];
                writer.writePrefixedString(entry.getExtensionName(), MessageConstants.EXTENSION_NAME_PREFIX_LENGTH);
                writer.writePrefixedString(entry.getPluginHandle(), MessageConstants.PLUGIN_HANDLE_PREFIX_LENGTH);
                writer.writePrefixedString(entry.getPluginName(), MessageConstants.PLUGIN_NAME_PREFIX_LENGTH);
                
                var parms:Array = entry.getParms();
                writer.writeInteger(parms.length, MessageConstants.PLUGIN_PARM_COUNT_LENGTH);
                var parmEntry:NameValuePair;
                for (i=0;i<parms.length;++i) {
                    parmEntry = parms[i];
                    writer.writePrefixedString(parmEntry.getName(), MessageConstants.PLUGIN_PARM_NAME_PREFIX_LENGTH);
                    writer.writePrefixedString(parmEntry.getValue(), MessageConstants.PLUGIN_PARM_VALUE_PREFIX_LENGTH);
                }
            }
        }*/
    }
}
