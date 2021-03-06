package com.electrotank.electroserver4.protocol {
    import com.electrotank.electroserver4.message.request.CreateOrJoinGameRequest;
    import com.electrotank.electroserver4.message.request.FindGamesRequest;
    import com.electrotank.electroserver4.message.request.GateWayKickUserRequest;
    import com.electrotank.electroserver4.protocol.*;
    import com.electrotank.electroserver4.protocol.codec.*;
    import com.electrotank.electroserver4.message.MessageType;
    
    public class As2ProtocolHandler {

        private var mapper:Object;
        public function As2ProtocolHandler() {
            mapper = new Object();
            register(MessageType.LoginRequest, MessageCodec(new LoginRequestCodec()));
            register(MessageType.AdditionalLoginRequest, MessageCodec(new LoginRequestCodec()));
            register(MessageType.LogoutRequest, MessageCodec(new LogoutRequestCodec()));
            register(MessageType.GetUsersInRoomRequest, MessageCodec(new GetUsersInRoomRequestCodec()));
            register(MessageType.UpdateRoomDetailsRequest, MessageCodec(new UpdateRoomDetailsRequestCodec()));
            register(MessageType.PluginRequest, MessageCodec(new PluginRequestCodec()));
            register(MessageType.ValidateAdditionalLoginRequest, MessageCodec(new ValidateAdditionalLoginRequestCodec()));
            register(MessageType.FindZoneAndRoomByNameRequest, MessageCodec(new FindZoneAndRoomByNameRequestCodec()));
            register(MessageType.EvictUserFromRoomRequest, MessageCodec(new EvictUserFromRoomRequestCodec()));
            register(MessageType.AddRoomOperatorRequest, MessageCodec(new AddRoomOperatorRequestCodec()));
            register(MessageType.RemoveRoomOperatorRequest, MessageCodec(new RemoveRoomOperatorRequestCodec()));
            register(MessageType.AddBuddyRequest, MessageCodec(new AddBuddyRequestCodec()));
            register(MessageType.RemoveBuddyRequest, MessageCodec(new RemoveBuddyRequestCodec()));
            register(MessageType.GetUserCountRequest, MessageCodec(new GetUserCountRequestCodec()));
            register(MessageType.DeleteUserVariableRequest, MessageCodec(new DeleteUserVariableRequestCodec()));
            register(MessageType.UpdateRoomVariableRequest, MessageCodec(new UpdateRoomVariableRequestCodec()));
            register(MessageType.UpdateUserVariableRequest, MessageCodec(new UpdateUserVariableRequestCodec()));
            register(MessageType.DeleteRoomVariableRequest, MessageCodec(new DeleteRoomVariableRequestCodec()));
            register(MessageType.CreateRoomVariableRequest, MessageCodec(new CreateRoomVariableRequestCodec()));
            register(MessageType.LeaveRoomRequest, MessageCodec(new LeaveRoomRequestCodec()));
            register(MessageType.GetZonesRequest, MessageCodec(new GetZonesRequestCodec()));
            register(MessageType.CreateRoomRequest, MessageCodec(new CreateRoomRequestCodec()));
            register(MessageType.GetRoomsInZoneRequest, MessageCodec(new GetRoomsInZoneRequestCodec()));
            register(MessageType.GetUsersInRoomResponse, MessageCodec(new GetUsersInRoomResponseCodec()));
            register(MessageType.GetZonesResponse, MessageCodec(new GetZonesResponseCodec()));
            register(MessageType.GetRoomsInZoneResponse, MessageCodec(new GetRoomsInZoneResponseCodec()));
            register(MessageType.GetUserCountResponse, MessageCodec(new GetUserCountResponseCodec()));
            register(MessageType.GenericErrorResponse, MessageCodec(new GenericErrorResponseCodec()));
            register(MessageType.ValidateAdditionalLoginResponse, MessageCodec(new ValidateAdditionalLoginResponseCodec()));
            register(MessageType.JoinRoomRequest, MessageCodec(new JoinRoomRequestCodec()));
            register(MessageType.GateWayKickUserRequest, MessageCodec(new GateWayKickUserRequestCodec()));
            register(MessageType.ConnectionEvent, MessageCodec(new ConnectionEventCodec()));
            register(MessageType.LoginResponse, MessageCodec(new LoginResponseCodec()));
            register(MessageType.FindZoneAndRoomByNameResponse, MessageCodec(new FindZoneAndRoomByNameResponseCodec()));
            register(MessageType.JoinRoomEvent, MessageCodec(new JoinRoomEventCodec()));
            register(MessageType.JoinZoneEvent, MessageCodec(new JoinZoneEventCodec()));
            register(MessageType.PublicMessageRequest, MessageCodec(new PublicMessageRequestCodec()));
            register(MessageType.PrivateMessageRequest, MessageCodec(new PrivateMessageRequestCodec()));
            register(MessageType.PublicMessageEvent, MessageCodec(new PublicMessageEventCodec()));
            register(MessageType.PrivateMessageEvent, MessageCodec(new PrivateMessageEventCodec()));
            register(MessageType.ZoneUpdateEvent, MessageCodec(new ZoneUpdateEventCodec()));
            register(MessageType.LeaveRoomEvent, MessageCodec(new LeaveRoomEventCodec()));
            register(MessageType.LeaveZoneEvent, MessageCodec(new LeaveZoneEventCodec()));
            register(MessageType.UserListUpdateEvent, MessageCodec(new UserListUpdateEventCodec()));
            register(MessageType.RoomVariableUpdateEvent, MessageCodec(new RoomVariableUpdateEventCodec()));
            register(MessageType.UserVariableUpdateEvent, MessageCodec(new UserVariableUpdateEventCodec()));
            register(MessageType.BuddyStatusUpdatedEvent, MessageCodec(new BuddyStatusUpdatedEventCodec()));
            register(MessageType.UserEvictedFromRoomEvent, MessageCodec(new UserEvictedFromRoomEventCodec()));
            register(MessageType.PluginMessageEvent, MessageCodec(new PluginMessageEventCodec()));
            register(MessageType.CompositePluginMessageEvent, MessageCodec(new CompositePluginMessageEventCodec()));
            register(MessageType.UpdateRoomDetailsEvent, MessageCodec(new UpdateRoomDetailsEventCodec()));
            register(MessageType.CreateOrJoinGameRequest, MessageCodec(new CreateOrJoinGameRequestCodec()));
            register(MessageType.FindGamesRequest, MessageCodec(new FindGamesRequestCodec()));
            register(MessageType.CreateOrJoinGameResponse, MessageCodec(new CreateOrJoinGameResponseCodec()));
            register(MessageType.FindGamesResponse, MessageCodec(new FindGamesResponseCodec()));
            register(MessageType.GetUserVariablesRequest, MessageCodec(new GetUserVariablesRequestCodec()));
            register(MessageType.GetUserVariablesResponse, MessageCodec(new GetUserVariablesResponseCodec()));
            register(MessageType.ClientIdleEvent, MessageCodec(new ClientIdleEventCodec()));
        }
        public function getMessageCodec(messageType:MessageType):MessageCodec {
            var mc:MessageCodec = mapper[messageType.getMessageTypeName()];
            if (mc == null) {
                trace("Error: Tried to find a MessageCodec for "+messageType.getMessageTypeName()+" and none was was registered.");
            }
            return mc;
        }
        private function register(messageType:MessageType, messageCodec:MessageCodec):void {

            mapper[messageType.getMessageTypeName()] = messageCodec;
        }
    }
}
