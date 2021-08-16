package com.electrotank.electroserver4.protocol.codec {
    import com.electrotank.electroserver4.MessageConstants;
    import com.electrotank.electroserver4.protocol.codec.*;
    import com.electrotank.electroserver4.protocol.*;
    import com.electrotank.electroserver4.message.Message;
    import com.electrotank.electroserver4.message.request.*;
    
    public class GetRoomsInZoneRequestCodec extends MessageCodecImpl {

        override public function encode(writer:MessageWriter, mess:Message):void {

            var request:GetRoomsInZoneRequest = GetRoomsInZoneRequest(mess);
            //writer.writeInteger(request.getZoneId(), MessageConstants.ZONE_ID_LENGTH);
            
            // Should we use the zone id or name?
            if(request.getZoneId() != -1) {
                writer.writeBoolean(true);
                writer.writeInteger(request.getZoneId(), MessageConstants.ZONE_ID_LENGTH);
            } else {
                writer.writeBoolean(false);
                writer.writePrefixedString(request.getZoneName(), MessageConstants.ZONE_NAME_PREFIX_LENGTH);
            }
            
        }
    }
}
