package com.electrotank.electroserver4.protocol.codec {
    import com.electrotank.electroserver4.MessageConstants;
    import com.electrotank.electroserver4.protocol.codec.*;
    import com.electrotank.electroserver4.protocol.*;
    import com.electrotank.electroserver4.user.*;
    import com.electrotank.electroserver4.entities.*;
    import com.electrotank.electroserver4.esobject.EsObject;
    
    public class UserListCodec {

        
        public static function decode(reader:MessageReader):Array {
            var entries:Array = new Array();
            var count:Number = reader.nextInteger(MessageConstants.USER_COUNT_LENGTH);
            for (var i:Number = 0; i < count; i++) {
                var entry:User = new User();
                //var userId:String = reader.nextString(MessageConstants.USER_ID_LENGTH);
                var userId:String = reader.nextLong(MessageConstants.USER_ID_LENGTH);
                entry.setUserId(userId);
                entry.setUserName(reader.nextPrefixedString(MessageConstants.USER_NAME_PREFIX_LENGTH));
                var variableCnt:Number = reader.nextInteger(MessageConstants.VARIABLE_COUNT_LENGTH);
                for (var j:Number = 0; j < variableCnt; j++) {
                    var name:String = reader.nextPrefixedString(MessageConstants.VARIABLE_NAME_PREFIX_LENGTH);
                    var value:EsObject = EsObjectCodec.decode(reader);
                    entry.addUserVariable(new UserVariable(name, value));
                        
                }
    
                entry.setIsSendingVideo(reader.nextBoolean());
                if (entry.getIsSendingVideo()) {
                    entry.setVideoStreamName(reader.nextPrefixedString(MessageConstants.VIDEO_STREAM_NAME_PREFIX_LENGTH));
                }
               
                
                entries.push(entry);
            }
    
            return entries;
        }
    }
}
