package com.sdg.net.socket
{
	import com.electrotank.electroserver4.ElectroServer;
	import com.electrotank.electroserver4.connection.*;
	import com.electrotank.electroserver4.entities.*;
	import com.electrotank.electroserver4.errors.*;
	import com.electrotank.electroserver4.esobject.*;
	import com.electrotank.electroserver4.message.Message;
	import com.electrotank.electroserver4.message.MessageType;
	import com.electrotank.electroserver4.message.event.*;
	import com.electrotank.electroserver4.message.request.*;
	import com.electrotank.electroserver4.message.response.*;
	import com.electrotank.electroserver4.user.*;
	import com.sdg.events.DoodadActionEvent;
	import com.sdg.events.SocketEvent;
	import com.sdg.events.SocketPetEvent;
	import com.sdg.events.SocketRoomEvent;
	import com.sdg.model.Server;
	import com.sdg.net.Environment;
	import com.sdg.utils.*;
	
	import flash.events.*;
	
	public class SocketClient extends EventDispatcher
	{
		private static var _instance:SocketClient;
		private static var _pluginActionHandlers:Array = [];
		
		private var _es:ElectroServer = null;
		private var _conn:Connection = null;
		private var _httpConn:HttpConnection = null;
		private var _isAuthenticated:Boolean = false;
		private var _es4RoomIdMap:Object = {};
		
		public function SocketClient()
		{
			//_es.setDebug(true); // turn on internal es trace
		}
		
		////////////////////
		// PUBLIC FUNCTIONS
		////////////////////
		
		public static function getInstance():SocketClient
		{
			if (_instance == null) {
				_instance = new SocketClient();
			}
			return _instance;
		}
		
		/**
		 * 
		 * @param	object to convert to EsObject
		 * @return an EsObject
		 * 
		 * Only works with basic primitives, ie doesn't support floats etc...
		 */
		public static function objToEso(params:Object,es:EsObject=null):EsObject
		{
			var esob:EsObject = (es is EsObject) ? es : new EsObject();
			
			for (var str:String in params) {
				var type:String = typeof(params[str]);
				if (type == 'number') {
					esob.setInteger(str, params[str]);
				}else if (type == 'string') {
					esob.setString(str, params[str]);
				}else if (type == 'boolean') {
					esob.setBoolean(str, params[str]);
				}else if (type == 'object'){
					esob.setStringArray(str, params[str]);
				}
			}
			return esob;
		}
		
		public static function esoToObj(eso:EsObject):Object
		{
			var values:Array = eso.getEntries();
			var object:Object = new Object();
			for (var i:int = 0; i < values.length; i++) {    
				
				var name:String = values[i].getName();
				var type:String = values[i].getDataType().getName();
				var val:* = values[i].getRawValue();
	
				if (type == 'int') {
					val = Number(val);
				}else if (type == 'string') {
					val = String(val);
				}else if (type == 'boolean') {
					val = Boolean(val);
				}
				object[name] = val;
			}
			return object;
		}
		
		public static function getPluginRequest(pluginName:String, action:String, params:Object = null):PluginRequest
		{
			// Create the PluginRequest.
			var pr:PluginRequest = new PluginRequest();
            pr.setPluginName(pluginName);

			// Create a params object if it wasn't specified.
			if (params == null) params = {};
			
			// Add the action to params.
			params.action = action;
			
			// Add the serverId to params.
			params.serverId = Server.getCurrentId();
			
			// Convert params to an Eso object and apply it to the request.
			pr.setEsObject( SocketClient.objToEso(params) );
			
            return pr;
		}
		
		public static function sendMessage(pluginName:String, action:String, payloadName:String = null, params:Object = null):void
		{
			// make sure we are connected - we don't fire a 'connectionClosed' event here
			// because ES4 should fire it within a few seconds
						
			if (!getInstance().isConnected)
				return;
			
			trace(" --- connected plugin " + pluginName + " --- action ---- " + action);
			
			if(action == "" || action == null)
			{
				trace("ACTION IS NULL");
				return;
			}
			// get the xml version of params
			var xmlPayload:String = "";
			if (payloadName != null && params != null)
			{
				xmlPayload = NetUtil.createPayloadXml(payloadName, params);
			}
			
			// create our payload object
			var payload:Object = {};
			payload[action] = xmlPayload;
			
			// send the message to our SocketServer plugin
			getInstance().sendPluginMessage(pluginName, action, payload);
		}
		
		public static function sendRoomMessage(pluginName:String, roomId:String, action:String, payloadName:String = null, params:Object = null):void
		{
			// get the xml version of params
			var xmlPayload:String = "";
			
			if(payloadName != null && params != null)
			{
				xmlPayload = ObjectUtil.toXMLString(params, payloadName);
			}
			
			// create our payload object
			var payload:Object = {};
			payload.roomId = roomId;
			payload[action] = xmlPayload;
			
			// send the message to our SocketServer plugin
			getInstance().sendPluginMessage(pluginName, action, payload);
		}
		
		public static function addPluginActionHandler(actionName:String, handler:Function):void
		{
			// Get an array of handlers already registered for this action.
			// If none exist, create an array.
			var arrayOfActionHandlers:Array = _pluginActionHandlers[actionName] as Array;
			if (!arrayOfActionHandlers)
			{
				arrayOfActionHandlers = [];
				_pluginActionHandlers[actionName] = arrayOfActionHandlers;
			}
			
			// Register this handler to this action.
			arrayOfActionHandlers.push(handler);
		}
		
		public static function removePluginActionHandler(actionName:String, handler:Function):void
		{
			// Get an array of handlers registered for this action.
			var arrayOfActionHandlers:Array = _pluginActionHandlers[actionName] as Array;
			if (!arrayOfActionHandlers) return;
			
			// Find this handler in the array of registered handlers and get the index.
			// Remove it if found.
			var index:int = arrayOfActionHandlers.indexOf(handler);
			if (index > -1) arrayOfActionHandlers.splice(index, 1);
		}
		
		public function loginWithHash(username:String, hash:String, avatarId:uint, serverId:uint):void
		{
			var loginRequest:LoginRequest = new LoginRequest();
            
            var esObj:EsObject = new EsObject();
            esObj.setInteger("serverId", serverId);
            esObj.setInteger("avatarId", avatarId);
            
            loginRequest.setEsObject(esObj);
            loginRequest.setPassword(hash);
            loginRequest.setUserName(username);
            
            trace("from SOCKET CLIENT login with hash username = " + username + " hash = " + hash + " avatarId = " + avatarId + " serverId = " + serverId);

            send(loginRequest);
		}
		
		public function login(username:String, password:String, avatarId:uint, serverId:uint):void 
		{
            var hash:String = NetUtil.generateHash([username, password], Environment.SALT); 
			loginWithHash(username, hash, avatarId, serverId);
		}
    
		public function connect(ip:String, port:uint, failoverIp:String, failoverPort:int, useFailover:Boolean):void 
		{
			if (!isConnected)
			{
				setupElectroServer();
				if (useFailover == true)	
				{
					trace( " - httpConnect " + failoverIp + ":" + failoverPort  );
					_httpConn = _es.createHttpConnection( failoverIp, failoverPort );
				}
				else
				{
					trace( " - std Connect " + ip + ":" + port );
					_conn = _es.createConnection(ip, port);
				}
			}
			else
			{
				dispatchEvent(new SocketEvent(SocketEvent.CONNECTION,{success:true}));
			}
		}
		
		public function disconnect():void
		{
			_es.close();
		}
		
		// a single username or an array of users
		public function sendPrivateMessage(msg:String, mixed:*):void
		{
			var list:Array = (typeof(mixed) == "string") ? [mixed] : mixed;
			var pmr:PrivateMessageRequest = new PrivateMessageRequest();
			pmr.setMessage(msg);
			pmr.setUserNames(list);
			send(pmr);
		}
		
		public function send(msg:Message,queue:Boolean=true):void
		{
			try
			{
				_es.send(msg);
			}
			catch (e:Error) 
			{
				trace("SocketClient: send()", e.errorID + " - " + e.name + ": " + e.message);
			}
		}

		public function sendPluginMessage(pluginName:String, action:String, params:Object = null):void
		{
			// Get the PluginRequest.
			var pr:PluginRequest = SocketClient.getPluginRequest(pluginName, action, params);
			
			if (params && params.roomId != null && pluginName != "room_config_server_level" && pluginName != "room_manager")
			{
				var es4Ids:Object = getEs4RoomIds(params.roomId);
				
				if (es4Ids)
				{
					pr.setRoomId(es4Ids.roomId);
					pr.setZoneId(es4Ids.zoneId);
				}
				else
				{
					trace("\n\n SocketClient: Mapped ES4 ids for 'roomId' [" + params.roomId + "] do not exist.\n\n");
				}
			}
			
			send(pr);
		}
		
		public function joinRoom(roomId:String):void 
		{
			trace("joining room roomId = " + roomId);
			sendPluginMessage("room_manager", "joinRoom", { roomId:roomId });
		}
		
		public function exitRoom(roomId:String):void 
		{
			var es4Ids:Object = removeEs4RoomIds(roomId);
			
			if (es4Ids)
			{
				var lrr:LeaveRoomRequest = new LeaveRoomRequest();
				lrr.setRoomId(es4Ids.roomId);
				lrr.setZoneId(es4Ids.zoneId);
				send(lrr);
			}
		}
		
		////////////////////
		// PROTECTED FUNCTIONS
		////////////////////
		
		protected function setupElectroServer():void
		{
			if (_es != null)
			{
				_es.removeEventListener(MessageType.ConnectionEvent, "onConnect",this);
				_es.removeEventListener(MessageType.LoginResponse, "onLogin", this);
				_es.removeEventListener(MessageType.JoinRoomEvent, "onJoinRoom", this);
				_es.removeEventListener(MessageType.LeaveRoomEvent, "onExitRoom", this);
				_es.removeEventListener(MessageType.PublicMessageEvent, "onPublicMessage", this);
				_es.removeEventListener(MessageType.PrivateMessageEvent, "onPrivateMessage", this);
				_es.removeEventListener(MessageType.ConnectionClosedEvent, "onConnectionClose", this);
				_es.removeEventListener(MessageType.PluginMessageEvent, "onPluginMessageEvent", this);
				_es.close();
			}
			
			_es = new ElectroServer();

			_es.setProtocol(Protocol.BINARY);	// failover needs binary for HTTP
			
			_es.addEventListener(MessageType.ConnectionEvent, "onConnect",this);
			_es.addEventListener(MessageType.LoginResponse, "onLogin", this);
			_es.addEventListener(MessageType.JoinRoomEvent, "onJoinRoom", this);
			_es.addEventListener(MessageType.LeaveRoomEvent, "onExitRoom", this);
			_es.addEventListener(MessageType.PublicMessageEvent, "onPublicMessage", this);
			_es.addEventListener(MessageType.PrivateMessageEvent, "onPrivateMessage", this);
			_es.addEventListener(MessageType.ConnectionClosedEvent, "onConnectionClose", this);
			_es.addEventListener(MessageType.PluginMessageEvent, "onPluginMessageEvent", this);
		}
		
		////////////////////
		// PRIVATE FUNCTIONS
		////////////////////
		
		private static function handlePluginAction(actionName:String, params:Object):void
		{
			var event:Event;
			
			// Handle doodad actions sepearately.
			// If it's a doodad action, get a more specific action name.
			if (actionName == SocketRoomEvent.DOODAD_ACTION)
			{
				actionName = new XML(params[actionName]).action;
				event = getPluginActionEvent(SocketRoomEvent.DOODAD_ACTION, params);
			}
			
			// Get an array of handlers registered for this action.
			var arrayOfActionHandlers:Array = _pluginActionHandlers[actionName] as Array;
			if (!arrayOfActionHandlers) return;
			
			// Create event that will be dispatched to all registered handlers for this action.
			if (!event) event = getPluginActionEvent(actionName, params);
			
			// Call all handlers registered for this action.
			var i:int = 0;
			var len:int = arrayOfActionHandlers.length;
			for (i; i < len; i++)
			{
				var handler:Function = arrayOfActionHandlers[i] as Function;
				if (handler != null) handler(event);
			}
		}
		
		private static function getPluginActionEvent(actionName:String, params:Object):Event
		{
			// Create an event based on action name.
			var payloadXml:XML = new XML(params[actionName]);
			switch (actionName)
			{
				case SocketPetEvent.PET_PLAYED:
				case SocketPetEvent.PET_CONSUMED:
					var consumeEvent:SocketPetEvent = new SocketPetEvent(actionName, payloadXml.Id, params);
					consumeEvent.petName = payloadXml.n;
					consumeEvent.setEncodedEnergy(payloadXml.enrg);
					consumeEvent.setEncodedHappiness(payloadXml.hap);
					return consumeEvent;
				case SocketPetEvent.PET_FOLLOW_MODE:
					var followEvent:SocketPetEvent = new SocketPetEvent(actionName, payloadXml.petId, params);
					followEvent.followMode = payloadXml.followMode;
					return followEvent;
				case SocketRoomEvent.DOODAD_ACTION:
					var actionXml:XML = new XML(params[actionName]);
					var senderAvatarId:int = (actionXml.saId != null) ? actionXml.saId : 0;
					return new DoodadActionEvent(actionName, actionXml.id, params, senderAvatarId);
				default:
					return new SocketEvent(SocketEvent.PLUGIN_EVENT, params);
			}
		}
		
		private function mapEs4RoomIds(params:Object):void
		{
			if (params.es4RoomId != null && params.sdgRoomId != null && !_es4RoomIdMap[params.sdgRoomId]) 
			{
				_es4RoomIdMap[params.sdgRoomId] = { roomId:params.es4RoomId, zoneId:params.es4ZoneId };
			}
		}
		
		private function getEs4RoomIds(sdgRoomId:String):Object
		{
			return _es4RoomIdMap[sdgRoomId];
		}
		
		private function removeEs4RoomIds(sdgRoomId:String):Object
		{
			var es4Ids:Object = _es4RoomIdMap[sdgRoomId];
			delete _es4RoomIdMap[sdgRoomId];
			return es4Ids;
		}
		
		////////////////////
		// GET/SET FUNCTIONS
		////////////////////
		
		public function get isAuthenticated():Boolean
		{
			return _isAuthenticated;
		}
		
		public function get isConnected():Boolean
		{
			if( _httpConn != null )
			{
				return _httpConn.getIsConnected()
			}
			
			if( _conn != null )
			{
				return _conn.getIsConnected()
			}
			
			return ( false );
		}
		
		public function get isLoggedIn():Boolean
		{
			if( _es != null )
			{
				return _es.getIsLoggedIn();
			}
			
			return ( false );
		}
		
	    public function get serverIp():String 
		{
			if( _httpConn != null )
			{
				return _httpConn.getIp()
			}
			
			if( _conn != null )
			{
				return _conn.getIp();
			}
			
            return ( "" );
        }
        
        public function get serverPort():uint 
		{
			if( _httpConn != null )
			{
				return _httpConn.getPort()
			}
			
			if( _conn != null )
			{
				return _conn.getPort()
			}
			
			return ( 0 );
        }
		
		////////////////////
		// EVENT HANDLERS
		////////////////////

		public function onConnect(e:ConnectionEvent):void 
		{
			dispatchEvent(new SocketEvent(SocketEvent.CONNECTION,{success:e.success}));
		}
		
		public function onConnectionClose(e:ConnectionClosedEvent):void 
		{
			_es4RoomIdMap = {};
			dispatchEvent(new SocketEvent(SocketEvent.CONNECTION_CLOSED,{}));
		}
		
		public function onLogin(e:LoginResponse):void 
		{
			// begin es test
			if( e.getAccepted())
			{
				trace( "onLogin httpconnect success" );
			}
			else
			{
				trace( "onLogin httpconnect error" + e.getEsError().getDescription());
			}
			// end es test
			
			_isAuthenticated = e.success;
			dispatchEvent(new SocketEvent(SocketEvent.LOGIN, { success:e.success } ));
			//flush();
		}
		
		public function onPrivateMessage(e:PrivateMessageEvent):void
		{
			dispatchEvent(new SocketEvent(SocketEvent.PRIVATE_MESSAGE,{ from:e.getUserName(), message:e.getMessage() }));
		}
		
        public function onPublicMessageEvent(e:PublicMessageEvent):void 
		{
			var esob:EsObject = e.getEsObject();
			dispatchEvent(new SocketEvent(SocketEvent.PUBLIC_MESSAGE, { username:e.getUserName(), message:e.getMessage(), roomId:e.getRoomId(), type:esob.getString("messageType") }));
        }
		
		public function onJoinRoom(e:JoinRoomEvent):void
		{
			dispatchEvent(new SocketEvent(SocketEvent.ROOM_JOIN, { room:e.room, roomId:e.getRoomId(), roomName:e.getRoomName(), zoneId:e.getZoneId(), users:e.getUsers() }));
		}
		
		public function onExitRoom(e:LeaveRoomEvent):void 
		{
			dispatchEvent(new SocketEvent(SocketEvent.ROOM_EXIT, {  room:e.room, roomId:e.getRoomId(), roomName:e.room.getRoomName(), zoneId:e.getZoneId() }));
		}
		
		public function onPluginMessageEvent(e:PluginMessageEvent):void 
		{
			var esoParams:Object = esoToObj(e.getEsObject());
			esoParams.pluginName = e.getPluginName();
			
			//if (esoParams.action == "heartbeat") return;
			
			// if room enumeration event, map the sdg room ids to es4 room ids for future requests.
			mapEs4RoomIds(esoParams);
			
			// Handle all plugin action handlers.
			handlePluginAction(esoParams.action, esoParams);

			if (Constants.ENABLE_SOCKET_TRACE_MESSAGES == true)
			{
				// trace plugin params.	
				trace("---------------------\n\nhello from plugin event name = " + esoParams.pluginName + "\n\n");
				for (var str:String in esoParams) 
					trace("key = " + str + " val = " + esoParams[str]);
				trace("---------------------------------------\n\n\n");
			}
			
			dispatchEvent(new SocketEvent(SocketEvent.PLUGIN_EVENT, esoParams));
		}
		
	}
}