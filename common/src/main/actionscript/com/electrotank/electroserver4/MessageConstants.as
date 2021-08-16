package com.electrotank.electroserver4 {
    import com.electrotank.electroserver4.*;
    
    public class MessageConstants {

        
        static public var MESSAGE_HEADER_SIZE:Number = 1;//first char of message
        static public var MESSAGE_ID_SIZE:Number = 4;//number of chars in the message id
        
        
        
        static public var GATEWAY_ID_LENGTH:Number = 13;
        static public var GATEWAY_STATE_LENGTH:Number = 2;
        static public var USER_ID_LENGTH:Number = 13;
        static public var USER_NAME_PREFIX_LENGTH:Number = 2;
        static public var USER_COUNT_LENGTH:Number = 4;
        static public var FULL_USER_COUNT_LENGTH:Number = 6;
        static public var USER_VARIABLE_COUNT_LENGTH:Number = 2;
        static public var USER_VARIABLE_NAME_PREFIX_LENGTH:Number = 2;
        static public var USER_VARIABLE_VALUE_PREFIX_LENGTH:Number = 4;
        static public var PASSWORD_PREFIX_LENGTH:Number = 2;
    
        static public var VIDEO_STREAM_NAME_PREFIX_LENGTH:Number = 2;
        
        static public var VARIABLE_COUNT_LENGTH:Number = 2;
        static public var VARIABLE_NAME_PREFIX_LENGTH:Number = 2;
        static public var VARIABLE_VALUE_PREFIX_LENGTH:Number = 5;
    
        static public var ZONE_COUNT_LENGTH:Number = 5;
        static public var ZONE_ID_LENGTH:Number = 5;
        static public var ZONE_NAME_PREFIX_LENGTH:Number = 3;
        static public var UPDATE_ACTION_LENGTH:Number = 1;
        static public var ROOM_ID_LENGTH:Number = 5;
        static public var ROOM_NAME_PREFIX_LENGTH:Number = 3;
        static public var ROOM_COUNT_LENGTH:Number = 5;
        static public var ROOM_CAPACITY_LENGTH:Number = 3;
        static public var ROOM_PASSWORD_PREFIX_LENGTH:Number = 2;
        static public var ROOM_DESCRIPTION_PREFIX_LENGTH:Number = 3;
        static public var ROOM_EVICTION_REASON_PREFIX_LENGTH:Number = 3;
        static public var ROOM_BAN_DURATION_LENGTH:Number = 6;
    
        static public var ROOM_VARIABLE_COUNT_LENGTH:Number = 2;
        static public var ROOM_VARIABLE_NAME_PREFIX_LENGTH:Number = 2;
    
        static public var FILTER_NAME_PREFIX_LENGTH:Number = 2;
        static public var FILTER_FAILURES_BEFORE_KICK_LENGTH:Number = 2;
        static public var FILTER_KICKS_BEFORE_BAN_LENGTH:Number = 2;
    
        static public var FLOODING_FILTER_MAX_DUP_MESSAGES_LENGTH:Number = 2;
        static public var FLOODING_FILTER_WINDOW_DURATION_LENGTH:Number = 3;
        static public var FLOODING_FILTER_MAX_MESSAGE_IN_WINDOW_LENGTH:Number = 2;
        
        static public var PUBLIC_MESSAGE_PREFIX_LENGTH:Number = 4;
        static public var PRIVATE_MESSAGE_PREFIX_LENGTH:Number = 4;
    
        static public var MESSAGE_NUMBER_LENGTH:Number = 4;
        static public var REQUEST_ID_LENGTH:Number = 4;
    
        static public var ERROR_ID_LENGTH:Number = 3;
    
        static public var DEFAULT_LONG_LENGTH:Number = 64;
        static public var DEFAULT_DOUBLE_LENGTH:Number = 64;
        static public var PASSPHRASE_PREFIX_LENGTH:Number = 4;
    
        static public var ZONE_AND_ROOM_ID_LIST_LENGTH:Number = 2;
        static public var SHARED_SECRET_LENGTH:Number = 2;
        
        static public var PLUGIN_COUNT_LENGTH:Number = 2;
        static public var EXTENSION_NAME_PREFIX_LENGTH:Number = 2;
        static public var PLUGIN_NAME_PREFIX_LENGTH:Number = 2;
        static public var PLUGIN_HANDLE_PREFIX_LENGTH:Number = 2;
        static public var PLUGIN_PARM_COUNT_LENGTH:Number = 2;
        static public var PLUGIN_PARM_NAME_PREFIX_LENGTH:Number = 2;
        static public var PLUGIN_PARM_VALUE_PREFIX_LENGTH:Number = 4;
        
        static public var PROTOCOL_COUNT_LENGTH:Number = 3;
        static public var PROTOCOL_HOST_PREFIX_LENGTH:Number = 2;
        static public var PROTOCOL_PORT_LENGTH:Number = 5;
        static public var PROTOCOL_LENGTH:Number = 2;
        
        static public var CUSTOM_POLICY_FILE_CONTENTS_PREFIX_LENGTH:Number = 4;
        
        static public var COMPOSITE_ESOBJECT_ARRAY_PREFIX_LENGTH:Number = 2;
        
        static public var HASH_ID_LENGTH:Number = 11;
    
    }
}
