package com.electrotank.electroserver4.errors {
    import com.electrotank.electroserver4.errors.*;
    /**
     * This class is used to store all known error types as static variables.
     */
    
    public class Errors {

        static private var errorsById:Array;
        /**
         * This occurs when you try to login with a name that is taken.
         */
        static public var UserNameExists:EsError = Errors.register(new EsError(0, "UserNameExists"));
        /**
         * This occurs when you try to log in and you are already logged in.
         */
        static public var UserAlreadyLoggedIn:EsError = Errors.register(new EsError(1, "UserAlreadyLoggedIn"));
        /**
         * This occurs if for some reason the API sends the wrong message number tagged on the message.
         */
        static public var InvalidMessageNumber:EsError = Errors.register(new EsError(2, "InvalidMessageNumber"));
        /**
         * This occurs when a message sent from the client to the server failed validation.
         */
        static public var InboundMessageFailedValidation:EsError = Errors.register(new EsError(3, "InboundMessageFailedValidation"));
        /**
         * This occurs when the number of clients connected to ElectroServer has reached what is defined in the license file or in the web-based admin. This error occurs for the next person trying to connect and login.
         */
        static public var MaximumClientConnectionsReached:EsError = Errors.register(new EsError(4, "MaximumClientConnectionsReached"));
        /**
         * This occurs if the client is trying to access a zone in some way (such as GetRoomsInZoneRequest) and that zone doesn't exist.
         */
        static public var ZoneNotFound:EsError = Errors.register(new EsError(5, "ZoneNotFound"));
        /**
         * This occurs when the client is trying to access a room in some way (such as JoinRoomRequest) and that room doesn't exist.
         */
        static public var RoomNotFound:EsError = Errors.register(new EsError(6, "RoomNotFound"));
        /**
         * This occurs when a room is at capacity and another user tries to join.
         */
        static public var RoomAtCapacity:EsError = Errors.register(new EsError(7, "RoomAtCapacity"));
        /**
         * This occurs when a user tries to join the room with the wrong password.
         */
        static public var RoomPasswordMismatch:EsError = Errors.register(new EsError(8, "RoomPasswordMismatch"));
        /**
         * This occurs when a user attempts to connect to a gateway that is paused. A gateway can be paused or resumed via the web admin.
         */
        static public var GatewayPaused:EsError = Errors.register(new EsError(9, "GatewayPaused"));
        /**
         * This occurs when a user tries to do something they don't have permission to do. Permission sets can be established via the web admin, and assigned to users as they login.
         */
        static public var AccessDenied:EsError = Errors.register(new EsError(10, "AccessDenied"));
        /**
         * This occurs when a user tries to update the value of a locked room variable.
         */
        static public var RoomVariableLocked:EsError = Errors.register(new EsError(11, "RoomVariableLocked"));
        /**
         * This occurs when a user tries to create a room variable that already exists.
         */
        static public var RoomVariableAlreadyExists:EsError = Errors.register(new EsError(12, "RoomVariableAlreadyExists"));
        /**
         * This shouldn't ever happen but is here just in case.
         */
        static public var DuplicateRoomName:EsError = Errors.register(new EsError(13, "DuplicateRoomName"));
        /**
         * This shouldn't ever happen but is here just in case.
         */
        static public var DuplicateZoneName:EsError = Errors.register(new EsError(14, "DuplicateZoneName"));
        /**
         * This occurs when a user tries to create a user variable that already exists.
         */
        static public var UserVariableAlreadyExists:EsError = Errors.register(new EsError(15, "UserVariableAlreadyExists"));
        /**
         * This occurs when a user tries to update a user variable that does not exist.
         */
        static public var UserVariableDoesNotExist:EsError = Errors.register(new EsError(16, "UserVariableDoesNotExist"));
        /**
         * This shouldn't ever happen but is here just in case.
         */
        static public var ZoneAllocationFailure:EsError = Errors.register(new EsError(17, "ZoneAllocationFailure"));
        /**
         * This shouldn't ever happen but is here just in case.
         */
        static public var RoomAllocationFailure:EsError = Errors.register(new EsError(18, "RoomAllocationFailure"));
        /**
         * This occurs when a user is banned from the server.
         */
        static public var UserBanned:EsError = Errors.register(new EsError(19, "UserBanned"));
        /**
         * This occurs when a user tries to join a room that they are already in.
         */
        static public var UserAlreadyInRoom:EsError = Errors.register(new EsError(20, "UserAlreadyInRoom"));
        /**
         * This occurs when something fails a language filter check.
         */
        static public var VulgarityCheckFailed:EsError = Errors.register(new EsError(21, "VulgarityCheckFailed"));
        /**
         * This occurs when a user does something that causes a server error. Usually related to custom plugin code.
         */
        static public var ActionCausedError:EsError = Errors.register(new EsError(22, "ActionCausedError"));
        /**
         * This occurs when a user tries to do something but has not yet logged into the server.
         */
        static public var ActionRequiresLogin:EsError = Errors.register(new EsError(23, "ActionRequiresLogin"));
        /**
         * This occurs when a generic server error is enountered with no specific meaning.
         */
        static public var GenericError:EsError = Errors.register(new EsError(24, "GenericError"));
        /**
         * This occurs when a user tries to interact with a plugin that doesn't exist.
         */
        static public var PluginNotFound:EsError = Errors.register(new EsError(25, "PluginNotFound"));
        /**
         * This occurs when a user tries to login and there is a custom Login Event Handler established on the server, and it errors.
         */
        static public var LoginEventHandlerFailure:EsError = Errors.register(new EsError(26, "LoginEventHandlerFailure"));
        /**
         * This occurs when a user name used during login is invalid.
         */
        static public var InvalidUserName:EsError = Errors.register(new EsError(27, "InvalidUserName"));
        /**
         * This occurs when a user tries to create a new plugin associated with a room and tried to use an extension that doesn't exist.
         */
        static public var ExtensionNotFound:EsError = Errors.register(new EsError(28, "ExtensionNotFound"));
        /**
         * This occurs when a associated with a room that the user has created fails to initialize.
         */
        static public var PluginInitializationFailed:EsError = Errors.register(new EsError(29, "PluginInitializationFailed"));
        /**
         * This occurs when an event is not found.
         */
        static public var EventNotFound:EsError = Errors.register(new EsError(30, "EventNotFound"));
        /**
         * This occurs when a user performs actions that are interpreted as flooding.
         */
        static public var FloodingFilterCheckFailed:EsError = Errors.register(new EsError(31, "FloodingFilterCheckFailed"));
        /**
         * This occurs when a user tries to do something (such as send messages) in a room that they are not in.
         */
        static public var UserNotJoinedToRoom:EsError = Errors.register(new EsError(32, "UserNotJoinedToRoom"));
        /**
         * This occurs when a managed object (part of the extension model) is not found.
         */
        static public var ManagedObjectNotFound:EsError = Errors.register(new EsError(33, "ManagedObjectNotFound"));
        /**
         * This occurs when a connected user has been inactive for a time longer that the idle disconnect time defined in the web admin. The user is then disconnected.
         */
        static public var IdleTimeReached:EsError = Errors.register(new EsError(34, "IdleTimeReached"));
        /**
         * This occurs when a non-specific server error happens.
         */
        static public var ServerError:EsError = Errors.register(new EsError(35, "ServerError"));
        /**
         * This occurs when a user tries to do something that is not supported under the license conditions of the server.
         */
        static public var OperationNotSupported:EsError = Errors.register(new EsError(36, "OperationNotSupported"));
        /**
         * This occurs during the creation of a room if the language filter settings are invalid.
         */
        static public var InvalidLanguageFilterSettings:EsError = Errors.register(new EsError(37, "InvalidLanguageFilterSettings"));
        /**
         * This occurs during the creation of a room if the flooding filter settings are invalid.
         */
        static public var InvalidFloodingFilterSettings:EsError = Errors.register(new EsError(38, "InvalidFloodingFilterSettings"));
        /**
         * This occurs when an extension that affect this user is forced to reload.
         */
        static public var ExtensionForcedReload:EsError = Errors.register(new EsError(39, "ExtensionForcedReload"));
        /**
         * This occurs when the server requests that the client log out.
         */
        static public var UserLogOutRequested:EsError = Errors.register(new EsError(40, "UserLogOutRequested"));
        /**
         * This occurs when a all connections except the optional RTMP connection remains.
         */
        static public var OnlyRtmpConnectionRemains:EsError = Errors.register(new EsError(41, "OnlyRtmpConnectionRemains"));
        /**
         * This occurs when a user tries to join a game that doesn't exist.
         */
        static public var GameDoesntExist:EsError = Errors.register(new EsError(42, "GameDoesntExist"));
        /**
         * This occurs when a user tries to join a game room and fails. This could be due to the wrong password, the game being full, or the game plugin just rejecting the user for any reason it wants.
         */
        static public var FailedToJoinGameRoom:EsError = Errors.register(new EsError(43, "FailedToJoinGameRoom"));
        /**
         * This occurs when you try to join a game that is locked.
         */
        static public var GameIsLocked:EsError = Errors.register(new EsError(44, "GameIsLocked"));
        /**
         * Invalid parameters.
         */
        static public var InvalidParameters:EsError = Errors.register(new EsError(45, "InvalidParameters"));
        /**
         * This occurs when a public message is rejected by a server event handler.
         */
        static public var PublicMessageRejected:EsError = Errors.register(new EsError(46, "PublicMessageRejected"));
        //CLIENT SPECIFIC ERRORS
        /**
         * This occurs when a user fails to connect to ElectroServer.
         */
        static public var FailedToConnect:EsError = Errors.register(new EsError(1000, "FailedToConnect"));
        /**
         * Gets an error by the numeric id.
         * @param    The error id.
         * @return The error found with the id.
         */
        static public function getErrorById(id:Number):EsError {
            var err:EsError = errorsById[id];
            if (err == null) {
                trace("Error: tried to 'getErrorById' but error was not found with id: "+id.toString());
            }
            return err;
        }
        /**
         * Registers a new error type.
         * @param    The error.
         * @return The error.
         */
        static public function register(err:EsError):EsError {
            if (errorsById == null) {
                errorsById = new Array();
            }
            errorsById[err.getId()] = err;
            return err;
        }
    }
}
