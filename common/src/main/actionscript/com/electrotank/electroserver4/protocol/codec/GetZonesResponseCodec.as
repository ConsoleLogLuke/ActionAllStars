package com.electrotank.electroserver4.protocol.codec {
    import com.electrotank.electroserver4.MessageConstants;
    import com.electrotank.electroserver4.protocol.codec.*;
    import com.electrotank.electroserver4.protocol.*;
    import com.electrotank.electroserver4.message.Message;
    import com.electrotank.electroserver4.message.event.*;
    import com.electrotank.electroserver4.message.response.*;
    import com.electrotank.electroserver4.message.request.*;
    import com.electrotank.electroserver4.zone.Zone;
    
    public class GetZonesResponseCodec extends MessageCodecImpl {

        override public function decode(reader:MessageReader):Message {
            var message:GetZonesResponse = new GetZonesResponse();
                var requestId:String = reader.nextInteger(MessageConstants.MESSAGE_ID_SIZE).toString();
            var cnt:Number = reader.nextInteger(MessageConstants.ZONE_COUNT_LENGTH);
            for (var i:Number = 0; i < cnt; i++) {
                 var entry:Zone = new Zone();
                entry.setZoneId(reader.nextInteger(MessageConstants.ZONE_ID_LENGTH));
                entry.setZoneName(reader.nextPrefixedString(MessageConstants.ZONE_NAME_PREFIX_LENGTH));
                message.addZone(entry);
            }
            return message;
        }
    }
}
