package com.electrotank.electroserver4.protocol.codec {
    import com.electrotank.electroserver4.MessageConstants;
    import com.electrotank.electroserver4.protocol.codec.*;
    import com.electrotank.electroserver4.protocol.*;
    import com.electrotank.electroserver4.message.Message;
    import com.electrotank.electroserver4.message.response.*;
    
    public class FindZoneAndRoomByNameResponseCodec extends MessageCodecImpl {

        override public function decode(reader:MessageReader):Message {
            var response:FindZoneAndRoomByNameResponse = new FindZoneAndRoomByNameResponse();
                var requestId:String = reader.nextInteger(MessageConstants.MESSAGE_ID_SIZE).toString();
    
            var count:Number = reader.nextInteger(MessageConstants.ZONE_AND_ROOM_ID_LIST_LENGTH);
               var list:Array = new Array();
            
            for(var i:Number = 0; i < count; i++) {
                var ids:Array = new Array();
                ids[0] = reader.nextInteger(MessageConstants.ZONE_ID_LENGTH);
                ids[1] = reader.nextInteger(MessageConstants.ROOM_ID_LENGTH);
                list.push(ids);
            }
            
            response.setRoomAndZoneList(list);
            return response;
        }
    }
}
