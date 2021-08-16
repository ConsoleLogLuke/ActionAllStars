package com.electrotank.electroserver4.message {
    import com.electrotank.electroserver4.message.*;
    /**
     * This class stores static variables that act as a message definition. All messages (requests, responses, events) have a getMessageType() method. The value of it is one of the static variables in this class.
     * @example
     * This example shows how to use this class when adding event listeners.
     * <listing>
    import com.electrotank.electroserver4.ElectroServer;
    import com.electrotank.electroserver4.message.request.*;
    import com.electrotank.electroserver4.message.response.LoginResponse;
    //
    var es:ElectroServer;//assume a connection was made elsewhere
    es.addEventListener(MessageType.LoginResponse, "onLoginResponse", this);
    function onLoginResponse(e:LoginResponse):void {

        //do something
    }
     * </listing>
     * This example is contrived but does show one use.
     * <listing>
    import com.electrotank.electroserver4.message.Message;
    import com.electrotank.electroserver4.message.MessageType;
    import com.electrotank.electroserver4.message.request.*;
    //
    var messages:Array = new Array();
    for (var i:int=0;i<messages.length;++i) {
        var mess:Message = messages[i];
        if (mess.getMessageType() == MessageType.LoginRequest) {
            var loginRequest = LoginRequest(mess);
            //do something
        } else if (mess.getMessageType() == MessageType.PublicMessageRequest) {
            var publicMessageRequest = PublicMessageRequest(mess);
            //do something else
        }
    }
     * </listing>
     */
    
    public class MessageType {

        static private var messageTypes:Array = new Array();
        //=============REQUESTS==========================
        /**
         * This variable refers to the LoginRequest request.
         */
        static public var LoginRequest:MessageType = new MessageType("L", "LoginRequest", true, false, false);
        /**
         * This variable refers to the AdditionalLoginRequest request.
         */
        static public var AdditionalLoginRequest:MessageType = new MessageType("$", "LoginRequest", true, false, false);
        /**
         * This variable refers to the LogoutRequest request.
         */
        static public var LogoutRequest:MessageType = new MessageType("l", "LogoutRequest", true, false, false);
        /**
         * This variable refers to the GetUsersInRoomRequest request.
         */
        static public var GetUsersInRoomRequest:MessageType = new MessageType("k", "GetUsersInRoomRequest", true, false, false);
        /**
         * This variable refers to the PluginRequest request.
         */
        static public var PluginRequest:MessageType = new MessageType("C", "PluginRequest", true, false, false);
        /**
         * This variable refers to the ValidateAdditionalLoginRequest request.
         */
        static public var ValidateAdditionalLoginRequest:MessageType = new MessageType("%", "ValidateAdditionalLoginRequest", true, false, false);
        /**
         * This variable refers to the FindZoneAndRoomByNameRequest request.
         */
        static public var FindZoneAndRoomByNameRequest:MessageType = new MessageType("D", "FindZoneAndRoomByNameRequest", true, false, false);
        /**
         * This variable refers to the UpdateRoomDetailsRequest request.
         */
        static public var UpdateRoomDetailsRequest:MessageType = new MessageType("h", "UpdateRoomDetailsRequest", true, false, false);
        /**
         * This variable refers to the EvictUserFromRoomRequest request.
         */
        static public var EvictUserFromRoomRequest:MessageType = new MessageType("S", "EvictUserFromRoomRequest", true, false, false);
        /**
         * This variable refers to the AddRoomOperatorRequest request.
         */
        static public var AddRoomOperatorRequest:MessageType = new MessageType("A", "AddRoomOperatorRequest", true, false, false);
        /**
         * This variable refers to the RemoveRoomOperatorRequest request.
         */
        static public var RemoveRoomOperatorRequest:MessageType = new MessageType("B", "RemoveRoomOperatorRequest", true, false, false);
        /**
         * This variable refers to the AddBuddyRequest request.
         */
        static public var AddBuddyRequest:MessageType = new MessageType("K", "AddBuddyRequest", true, false, false);
        /**
         * This variable refers to the RemoveBuddyRequest request.
         */
        static public var RemoveBuddyRequest:MessageType = new MessageType("M", "RemoveBuddyRequest", true, false, false);
        /**
         * This variable refers to the GetUserCountRequest request.
         */
        static public var GetUserCountRequest:MessageType = new MessageType("0", "GetUserCountRequest", true, false, false);
        /**
         * This variable refers to the DeleteUserVariableRequest request.
         */
        static public var DeleteUserVariableRequest:MessageType = new MessageType("H", "DeleteUserVariableRequest", true, false, false);
        /**
         * This variable refers to the UpdateRoomVariableRequest request.
         */
        static public var UpdateRoomVariableRequest:MessageType = new MessageType("o", "UpdateRoomVariableRequest", true, false, false);
        /**
         * This variable refers to the UpdateUserVariableRequest request.
         */
        static public var UpdateUserVariableRequest:MessageType = new MessageType("I", "UpdateUserVariableRequest", true, false, false);
        /**
         * This variable refers to the DeleteRoomVariableRequest request.
         */
        static public var DeleteRoomVariableRequest:MessageType = new MessageType("N", "DeleteRoomVariableRequest", true, false, false);
        /**
         * This variable refers to the CreateRoomVariableRequest request.
         */
        static public var CreateRoomVariableRequest:MessageType = new MessageType("n", "CreateRoomVariableRequest", true, false, false);
        /**
         * This variable refers to the LeaveRoomRequest request.
         */
        static public var LeaveRoomRequest:MessageType = new MessageType("v", "LeaveRoomRequest", true, false, false);
        /**
         * This variable refers to the CreateRoomRequest request.
         */
        static public var CreateRoomRequest:MessageType = new MessageType("Q", "CreateRoomRequest", true, false, false);
        /**
         * This variable refers to the PublicMessageRequest request.
         */
        static public var PublicMessageRequest:MessageType = new MessageType("P", "PublicMessageRequest", true, false, false);
        /**
         * This variable refers to the PrivateMessageRequest request.
         */
        static public var PrivateMessageRequest:MessageType = new MessageType("p", "PrivateMessageRequest", true, false, false);
        /**
         * This variable refers to the GetRoomsInZoneRequest request.
         */
        static public var GetRoomsInZoneRequest:MessageType = new MessageType("t", "GetRoomsInZoneRequest", true, false, false);
        /**
         * This variable refers to the JoinRoomRequest request.
         */
        static public var JoinRoomRequest:MessageType = new MessageType("J", "JoinRoomRequest", true, false, false);
        /**
         * This variable refers to the GetZonesRequest request.
         */
        static public var GetZonesRequest:MessageType = new MessageType("s", "GetZonesRequest", true, false, false);
        /**
         * This variable refers to the CreateOrJoinGameRequest request.
         */
        static public var CreateOrJoinGameRequest:MessageType = new MessageType("(", "CreateOrJoinGameRequest", true, false, false);
        /**
         * This variable refers to the FindGamesRequest request.
         */
        static public var FindGamesRequest:MessageType = new MessageType("*", "FindGamesRequest", true, false, false);
        /**
         * This variable refers to the GetUserVariablesRequest request.
         */
        static public var GetUserVariablesRequest:MessageType = new MessageType("+", "GetUserVariablesRequest", true, false, false);
        /**
         * This variable refers to the GateWayKickUserRequest request.
         */
        static public var GateWayKickUserRequest:MessageType = new MessageType("^", "GateWayKickUserRequest", true, false, false);
        //=============RESPONSES==========================
        /**
         * This variable refers to the LoginResponse response.
         */
        static public var LoginResponse:MessageType = new MessageType("m", "LoginResponse", false, true, false);
        /**
         * This variable refers to the GetUsersInRoomResponse response.
         */
        static public var GetUsersInRoomResponse:MessageType = new MessageType("F", "GetUsersInRoomResponse", false, true, false);
        /**
         * This variable refers to the GetUserCountResponse response.
         */
        static public var GetUserCountResponse:MessageType = new MessageType("1", "GetUserCountResponse", false, true, false);
        /**
         * This variable refers to the  GetZonesResponseresponse.
         */
        static public var GetZonesResponse:MessageType = new MessageType("b", "GetZonesResponse", false, true, false);
        /**
         * This variable refers to the GetRoomsInZoneResponse response.
         */
        static public var GetRoomsInZoneResponse:MessageType = new MessageType("d", "GetRoomsInZoneResponse", false, true, false);
        /**
         * This variable refers to the GenericErrorResponse response.
         */
        static public var GenericErrorResponse:MessageType = new MessageType("e", "GenericErrorResponse", false, true, false);
        /**
         * This variable refers to the FindZoneAndRoomByNameResponse response.
         */
        static public var FindZoneAndRoomByNameResponse:MessageType = new MessageType("g", "FindZoneAndRoomByNameResponse", false, true, false);
        /**
         * This variable refers to the ValidateAdditionalLoginResponse response.
         */
        static public var ValidateAdditionalLoginResponse:MessageType = new MessageType("&", "ValidateAdditionalLoginResponse", false, true, false);
        /**
         * This variable refers to the CreateOrJoinGameResponse response.
         */
        static public var CreateOrJoinGameResponse:MessageType = new MessageType("_", "CreateOrJoinGameResponse", false, true, false);
        /**
         * This variable refers to the FindGamesResponse response.
         */
        static public var FindGamesResponse:MessageType = new MessageType(")", "FindGamesResponse", false, true, false);
        /**
         * This variable refers to the GetUserVariablesResponse response.
         */
        static public var GetUserVariablesResponse:MessageType = new MessageType("=", "GetUserVariablesResponse", false, true, false);
        //=============EVENTS==========================
        /**
         * This variable refers to the ConnectionEvent event.
         */
        static public var ConnectionEvent:MessageType = new MessageType("c", "ConnectionEvent", false, false, true);
        /**
         * This variable refers to the ConnectionEvent event.
         */
        static public var ClientIdleEvent:MessageType = new MessageType("i", "ClientIdleEvent", false, false, true);
        /**
         * This variable refers to the JoinRoomEvent event.
         */
        static public var JoinRoomEvent:MessageType = new MessageType("R", "JoinRoomEvent", false, false, true);
        /**
         * This variable refers to the JoinZoneEvent event.
         */
        static public var JoinZoneEvent:MessageType = new MessageType("Z", "JoinZoneEvent", false, false, true);
        /**
         * This variable refers to the PublicMessageEvent event.
         */
        static public var PublicMessageEvent:MessageType = new MessageType("a", "PublicMessagEvent", false, false, true);
        /**
         * This variable refers to the PrivateMessageEvent event.
         */
        static public var PrivateMessageEvent:MessageType = new MessageType("r", "PrivateMessagEvent", false, false, true);
        /**
         * This variable refers to the ZoneUpdateEvent event.
         */
        static public var ZoneUpdateEvent:MessageType = new MessageType("V", "ZoneUpdateEvent", false, false, true);
        /**
         * This variable refers to the LeaveRoomEvent event.
         */
        static public var LeaveRoomEvent:MessageType = new MessageType("W", "LeaveRoomEvent", false, false, true);
        /**
         * This variable refers to the LeaveZoneEvent event.
         */
        static public var LeaveZoneEvent:MessageType = new MessageType("X", "LeaveZoneEvent", false, false, true);
        /**
         * This variable refers to the UserListUpdateEvent event.
         */
        static public var UserListUpdateEvent:MessageType = new MessageType("U", "UserListUpdateEvent", false, false, true);
        /**
         * This variable refers to the RoomVariableUpdateEvent event.
         */
        static public var RoomVariableUpdateEvent:MessageType = new MessageType("q", "RoomVariableUpdateEvent", false, false, true);
        /**
         * This variable refers to the UserVariableUpdateEvent event.
         */
        static public var UserVariableUpdateEvent:MessageType = new MessageType("Y", "UserVariableUpdateEvent", false, false, true);
        /**
         * This variable refers to the BuddyStatusUpdatedEvent event.
         */
        static public var BuddyStatusUpdatedEvent:MessageType = new MessageType("O", "BuddyStatusUpdatedEvent", false, false, true);
        /**
         * This variable refers to the UserEvictedFromRoomEvent event.
         */
        static public var UserEvictedFromRoomEvent:MessageType = new MessageType("T", "UserEvictedFromRoomEvent", false, false, true);
        /**
         * This variable refers to the UpdateRoomDetailsEvent event.
         */
        static public var UpdateRoomDetailsEvent:MessageType = new MessageType("E", "UpdateRoomDetailsEvent", false, false, true);
        /**
         * This variable refers to the PluginMessageEvent event.
         */
        static public var PluginMessageEvent:MessageType = new MessageType("f", "PluginMessageEvent", false, false, true);
        /**
         * This variable refers to the CompositePluginMessageEvent event.
         */
        static public var CompositePluginMessageEvent:MessageType = new MessageType("G", "CompositePluginMessageEvent", false, false, true);
        //==========CLIENT CREATED EVENTS================
        /**
         * This variable refers to the ConnectionClosedEvent event.
         */
        static public var ConnectionClosedEvent:MessageType = new MessageType("|ConnectionClosedEvent", "ConnectionClosedEvent", false, false, true);
        /**
         * This variable refers to the RtmpConnectionEvent event.
         */
        static public var RtmpConnectionEvent:MessageType = new MessageType("|RtmpConnectionEvent", "RtmpConnectionEvent", false, false, true);
        /**
         * This variable refers to the RtmpConnectionClosedEvent event.
         */
        static public var RtmpConnectionClosedEvent:MessageType = new MessageType("|RtmpConnectionClosedEvent", "RtmpConnectionClosedEvent", false, false, true);
        /**
         * This variable refers to the RtmpOnStatusEvent event.
         */
        static public var RtmpOnStatusEvent:MessageType = new MessageType("|RtmpOnStatusEvent", "RtmpOnStatusEvent", false, false, true);
        //
        private var messageTypeId:String;
        private var messageTypeName:String;
        private var isRequest:Boolean;
        private var isResponse:Boolean;
        private var isEvent:Boolean;
        private static function register(mt:MessageType):void {

            var num:Number = mt.getMessageTypeId().charCodeAt(0);
            messageTypes[num] = mt;
            var id:String = mt.getMessageTypeId();
        }
        /**
         * Every message has a unique id. This id is used on the server and the client. This method allows you to find the message type base don the id.
         * @param    The message type id.
         * @return The MessageType class associated in the id.
         */
        public static function findTypeById(id:String):MessageType {
            var num:Number = id.charCodeAt(0);
            var mt:MessageType = messageTypes[num];
            if (mt == null) {
                trace("Error: MessageType class. Message type not found with id: "+id);
            }
            return mt;
        }
        /**
         * Creates a new instance of the MessageType class. Pass in the message type id, which should be unique, the name, and boolean values to set if it is a request, event, or response.
         * @param    The unique message type id.
         * @param    The name of the message.
         * @param    isRequest - true/false
         * @param    isResponse - true/false
         * @param    isEvent - true/false
         */
        public function MessageType(id:String, name:String, req:Boolean, res:Boolean, ev:Boolean) {
            setIsRequest(req);
            setIsResponse(res);
            setIsEvent(res);
            setMessageTypeId(id);
            setMessageTypeName(name);
            register(this);
        }
        /**
         * Sets the isRequst property.
         * @param    True or false.
         */
        public function setIsRequest(val:Boolean):void {

            isRequest = val;
        }
        /**
         * Gets the isRequest property.
         * @return True or false.
         */
        public function getIsRequest():Boolean {
            return isRequest;
        }
        /**
         * Sets the isResponse property.
         * @param    True or false.
         */
        public function setIsResponse(val:Boolean):void {

            isResponse = val;
        }
        /**
         * Gets the isResponse property.
         * @return True or false.
         */
        public function getIsResponse():Boolean {
            return isResponse;
        }
        /**
         * Sets the isEvent property.
         * @param    True or false.
         */
        public function setIsEvent(val:Boolean):void {

            isEvent = val;
        }
        /**
         * Gets the isEvent property.
         * @return True or false.
         */
        public function getIsEvent():Boolean {
            return isEvent;
        }
        /**
         * Sets the message type name. This is used for friendly logging.
         * @param    Name of the message type.
         */
        public function setMessageTypeName(name:String):void {

            messageTypeName = name;
        }
        /**
         * Gets the message type name.
         * @return The message type name.
         */
        public function getMessageTypeName():String {
            return messageTypeName;
        }
        /**
         * The message type id.
         * @return The message type id.
         */
        public function getMessageTypeId():String {
            return messageTypeId;
        }
        /**
         * Sets the message type id. This must be a unique value.
         * @param    The message type id.
         */
        public function setMessageTypeId(id:String):void {

            messageTypeId = id;
        }
    }
}
