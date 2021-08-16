package com.electrotank.electroserver4.protocol.codec {
    import com.electrotank.electroserver4.MessageConstants;
    import com.electrotank.electroserver4.protocol.codec.*;
    import com.electrotank.electroserver4.protocol.*;
    import com.electrotank.electroserver4.message.Message;
    import com.electrotank.electroserver4.message.event.*;
    import com.electrotank.electroserver4.message.response.*;
    import com.electrotank.electroserver4.message.request.*;
    
    public class LeaveZoneEventCodec extends MessageCodecImpl {

        override public function decode(reader:MessageReader):Message {
            var event:LeaveZoneEvent = new LeaveZoneEvent();
            // Read the zone id
            var zoneId:Number = reader.nextInteger(MessageConstants.ZONE_ID_LENGTH);
            event.setZoneId(zoneId);
    
            return event;
        }
    }
}
