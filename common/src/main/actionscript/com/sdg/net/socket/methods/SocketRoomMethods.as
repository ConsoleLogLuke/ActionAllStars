package com.sdg.net.socket.methods
{
	import com.electrotank.electroserver4.esobject.*;
	import com.electrotank.electroserver4.room.*;
	import com.sdg.events.SocketEvent;
	import com.sdg.events.SocketRoomEvent;
	import com.sdg.net.socket.SocketClient;
	
	import flash.events.EventDispatcher;
	
	public class SocketRoomMethods extends EventDispatcher
	{
		private static const ACTION_TYPE_INFO:Object = 
		{
			1: { typeName:"avatar", actionField:"avatarAction" },
			2: { typeName:"inventoryItem", actionField:"doodadAction" }
		}
	
		private var _configRoomId:String;
		private var _roomId:String;
		private var _socketClient:SocketClient;
		private var _isInit:Boolean;
		
		public function SocketRoomMethods() 
		{
			super();
			
			_isInit = false;
			_socketClient = SocketClient.getInstance();
			
			// Initialize.
			init();
		}
		
		////////////////////
		// PUBLIC METHODS
		////////////////////
		
		public function join(roomId:String):void
		{
			_roomId = roomId;
			
			// join the room
			_socketClient.joinRoom(roomId);
		}
		
		public function exit():void
		{
			// exit the room
			_socketClient.exitRoom(_roomId);
			
			_roomId = null;
		}
		
		public function getAvatarCountInRoom(roomId:String):void
		{
			_socketClient.sendPluginMessage("room_manager", "numAvatars", { roomId:roomId });
		}
		
		public function getConfig(roomId:String):void
		{
			_configRoomId = roomId;
			_socketClient.sendPluginMessage("room_config_server_level", "roomConfig", { roomId:roomId });
			
			trace("SocketRoomMethods: getConfig", roomId);
		}
		
		public function getEnumeration():void
		{
			sendEnumMessage("roomEnum");
		}
		
		public function getRwsEvents():void
		{
			sendEnumMessage("rwsEvents");
		}
		
		public function getPickemEvents():void
		{
			sendEnumMessage("pickemEvents");
		}
		
		public function getServerTime():void
		{
			sendEnumMessage("serverTime");
		}
		
		public function sendEnumMessage(action:String, params:Object = null):void
		{
			// ignore if we haven't joined the room yet.
			if (_roomId == null)
			{
				trace("SocketRoomMethods: Unable to send message, roomId is null.");
				return;
			}
			
			if (params == null) params = {};
			params.roomId = _roomId;
			
			_socketClient.sendPluginMessage("room_enumeration", action, params);
		}
		
		public function sendEnumUpdated():void
		{
			sendEnumMessage("roomUpdated");
		}
		
		public function sendItemAction(typeId:uint, id:uint, action:String, params:Object = null, consequence:Object = null):void
		{
			// Get the action info for the specified typeId.
			var info:Object = ACTION_TYPE_INFO[typeId];
			// Abort if no info exists.
			if (!info) return;
			
			// Add action params.
			if (params == null) params = {};
			params.typeId = typeId;
			params.id = id;
			params.action = action;
			
			// Create payload object.
			var payload:Object = { consequence:[] };
			
			// Encode action XML.
			payload[info.actionField] = objToXml("action", params);
			
			// Encode consequence XML.
			if (consequence) 
			{
				consequence[info.typeName + "Id"] = id;
				payload.consequence.push(objToXml(info.typeName, consequence));
			}
			
			sendEnumMessage(info.actionField, payload);
		}
		
		public static function objToXml(topNode:String, params:Object ):String
		{
			var result:String = "<" + topNode + ">";

			for (var str:String in params)
			{
				result += "<" + str + ">" + params[str] + "</" + str + ">";
			}
			result += "</" + topNode + ">";
			
			return result;
		}
		
		////////////////////
		// PRIVATE METHODS
		////////////////////
		
		private function init():void
		{
			// Make sure we only init once.
			if (_isInit == true) return;
			_isInit = true;
			
			// Add plugin event handler.
			_socketClient.addEventListener(SocketEvent.PLUGIN_EVENT, pluginEventHandler);
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		public function get roomId():String
		{
			return _roomId;
		}
		
		public function set roomId(value:String):void
		{
			_roomId = value;
		}
		
		////////////////////
		// EVENT HANDLERS
		////////////////////
		
		private function pluginEventHandler(e:SocketEvent):void
		{
			var params:Object = e.params;
			var action:String = params.action;
			
			// allow these avatar actions through in case they are not in the same room
			var isJab:Boolean = false;
			var isUpdateInvitePanels:Boolean = false;
			if (action == "avatarAction")
			{
				var avatarAction:String = String(params.avatarAction);
				isJab = avatarAction.indexOf("jabId") != -1;
				isUpdateInvitePanels = avatarAction.indexOf("updateInvitePanels") != -1;
			}
			
			// Filter events.
			if (params.sdgRoomId == _roomId || 
				action == "numAvatars" ||
				isJab || isUpdateInvitePanels ||
				action == 'achievementComplete' || action == 'achievementAccepted' ||
				action == 'joinRoomSuccess' ||
				(action == "roomConfig" && params.sdgRoomId == _configRoomId))
			{
				dispatchEvent(new SocketRoomEvent(action, params));
			}
		}
		
	}
}