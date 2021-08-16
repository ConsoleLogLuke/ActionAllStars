package com.electrotank.electroserver4.protocol.codec {
    import com.electrotank.electroserver4.MessageConstants;
    import com.electrotank.electroserver4.protocol.codec.*;
    import com.electrotank.electroserver4.protocol.*;
    import com.electrotank.electroserver4.message.Message;
    import com.electrotank.electroserver4.message.event.*;
    import com.electrotank.electroserver4.message.response.*;
    import com.electrotank.electroserver4.message.request.*;
    import com.electrotank.electroserver4.esobject.EsObject;
    
    public class BuddyStatusUpdatedEventCodec extends MessageCodecImpl {

        override public function decode(reader:MessageReader):Message {
            var event:BuddyStatusUpdatedEvent = new BuddyStatusUpdatedEvent();
    
            // Get the type
            //BuddyStatusUpdateEvent.BuddyStatusUpdateUpdateAction
           var actionId:Number = reader.nextShort(MessageConstants.UPDATE_ACTION_LENGTH);
            
            // Set the id and name
            event.setActionId(actionId);
            event.setUserId(reader.nextLong(MessageConstants.USER_ID_LENGTH));
            event.setUserName(reader.nextPrefixedString(MessageConstants.USER_NAME_PREFIX_LENGTH));
            // If there is an esObject associated with the event, we need to get it
            event.setHasEsObject(reader.nextBoolean());
            if(event.getHasEsObject()) {
                var esObject:EsObject = EsObjectCodec.decode(reader);
                event.setEsObject(esObject);
            }
            
            // Return it
            return event;
        }
    }
}
