/**
 * 
 * SmartFoxClient class
 * Actionscript 3.0 / Flex 2 / Flash 9 version
 * 
 * @version 	1.3.3
 * @status 		beta
 * @author 		Marco Lapi
 * 
 * (c) 2006 gotoAndPlay()
 * www.gotoandplay.it
 * www.smartfoxserver.com
 * 
 */
 
package it.gotoandplay.smartfoxserver
{
	import flash.net.Socket;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.ErrorEvent;
	import flash.events.ProgressEvent;
	import flash.utils.ByteArray;
	import it.gotoandplay.smartfoxserver.handlers.IMessageHandler;
	import it.gotoandplay.smartfoxserver.handlers.SysHandler;
	import it.gotoandplay.smartfoxserver.handlers.ExtHandler;
	import flash.events.IOErrorEvent;
	import it.gotoandplay.smartfoxserver.data.Room;
	import it.gotoandplay.smartfoxserver.data.User;
	import it.gotoandplay.smartfoxserver.util.ObjectSerializer;
	import it.gotoandplay.smartfoxserver.util.Entities;

	import flash.utils.getTimer;
	import flash.net.getClassByAlias;
	
	/** 
	 * JSON Library
	 * Requires corelib.swc
	 * http://labs.macromedia.com/wiki/index.php/ActionScript_3:resources:apis:libraries#corelib
	 */ 
	import com.adobe.serialization.json.JSON
	
	
	public class SmartFoxClient extends EventDispatcher
	{
		private static const EOM:int = 0x00
		private static const MSG_XML:String  = "<"
		private static const MSG_STR:String  = "%"
		private static const MSG_JSON:String = "{"
		
		public static const MODMSG_TO_USER:String = "u"
		public static const MODMSG_TO_ROOM:String = "r"
		public static const MODMSG_TO_ZONE:String = "z"
		
		public static const XTMSG_TYPE_XML:String = "xml"
		public static const XTMSG_TYPE_STR:String = "str"
		public static const XTMSG_TYPE_JSON:String = "json"
		
		// Private members
		private var roomList:Array
		private var connected:Boolean
		private var benchStartTime:int
		
		private var sysHandler:SysHandler
		private	var extHandler:ExtHandler
		
		private var majVersion:Number
		private var minVersion:Number
		private var subVersion:Number
		
		private var messageHandlers:Array
		private var socketConnection:Socket
		private var byteBuffer:ByteArray
		
		// Public members 
		public var buddyList:Array
		public var buddyVars:Array
		public var debug:Boolean
		public var myUserId:int
		public var myUserName:String		
		public var playerId:int
		public var amIModerator:Boolean
		public var activeRoomId:int
		public var changingRoom:Boolean
		
		/**
		 * Constructor
		 * @debug 	turns on or off the debug messages
		 */
		public function SmartFoxClient(debug:Boolean = false)
		{
			// Initialize properties 
			this.majVersion = 1
			this.minVersion = 3
			this.subVersion = 4
			
			this.activeRoomId = -1
			this.debug = debug
			
			//initialize()
			
			this.messageHandlers = []
			setupMessageHandlers()
			
			// Initialize socket object
			socketConnection = new Socket()
			
			socketConnection.addEventListener(Event.CONNECT, handleSocketConnection)
			socketConnection.addEventListener(Event.CLOSE, handleSocketDisconnection)
			socketConnection.addEventListener(ErrorEvent.ERROR, handleSocketError)
			socketConnection.addEventListener(IOErrorEvent.IO_ERROR, handleIOError)
        	socketConnection.addEventListener(ProgressEvent.SOCKET_DATA, handleSocketData)
			
			byteBuffer = new ByteArray()		
		}
		
		private function initialize():void
		{
			this.changingRoom = false
			this.amIModerator = false
			this.playerId = -1
			
			this.connected = false
			this.roomList = []
			this.buddyList = []
			this.buddyVars = []
		}
		
		private function setupMessageHandlers():void
		{
			sysHandler = new SysHandler(this)
			extHandler = new ExtHandler(this)
			
			addMessageHandler("sys", sysHandler)
			addMessageHandler("xt", extHandler)
		}
		
		private function addMessageHandler(key:String, handler:IMessageHandler):void
		{
			if (this.messageHandlers[key] == null)
			{
				this.messageHandlers[key] = handler
			}
			else
				trace("Warning, message handler called: " + key + " already exist!")
		}
		
		private function send(header:Object, action:String, fromRoom:Number, message:String):void
		{
			// Setup Msg Header
			var xmlMsg:String = makeXmlHeader(header)
			
			// Setup Body
			xmlMsg += "<body action='" + action + "' r='" + fromRoom + "'>" + message + "</body>" + closeHeader()
		
			if (this.debug)
				trace("[Sending]: " + xmlMsg + "\n")
			
			writeToSocket(xmlMsg)
		}
		
		public function sendString(strMessage:String):void
		{
			if (this.debug)
				trace("[Sending - STR]: " + strMessage + "\n")
				
			writeToSocket(strMessage)
		}
		
		public function sendJson(jsMessage:String):void
		{
			if (this.debug)
				trace("[Sending - JSON]: " + jsMessage + "\n")
				
			writeToSocket(jsMessage)
		}
		
		private function writeToSocket(msg:String):void
		{
			var byteBuff:ByteArray = new ByteArray()
			byteBuff.writeMultiByte(msg, "utf-8")
			byteBuff.writeByte(0)
			
			socketConnection.writeBytes(byteBuff)
			socketConnection.flush()
		}
		
		private function makeXmlHeader(headerObj:Object):String
		{
			var xmlData:String = "<msg"
		
			for (var item:String in headerObj)
			{
				xmlData += " " + item + "='" + headerObj[item] + "'"
			}
		
			xmlData += ">"
		
			return xmlData
		}
		
		
		private function closeHeader():String
		{
			return "</msg>"
		}
		
		public function getBenchStartTime():int
		{
			return this.benchStartTime
		}
		
		
		/**
		 * Check for buddy duplicates in the current buddy list
		 */
		private function checkBuddyDuplicates(buddyName:String):Boolean
		{
			var res:Boolean = false
		
			for each(var buddy:Object in buddyList)
			{
				if (buddy.name == buddyName)
				{
					res = true
					break
				}
			}
			
			return res
		}
		
		/**
		 * Got XML response
		 */
		private function xmlReceived(msg:String):void
		{
			var xmlData:XML = new XML(msg)
			var handlerId:String = xmlData.@t
			var action:String = xmlData.body.@action
			var roomId:int = xmlData.body.@r
			
			var handler:IMessageHandler = messageHandlers[handlerId]
			if (handler != null)
				handler.handleMessage(xmlData, XTMSG_TYPE_XML)
		}
		
		/**
		 * Got JSON response
		 */
		private function jsonReceived(msg:String):void
		{
			var jso:Object = JSON.decode(msg)

			var handlerId:String = jso["t"]
			var handler:IMessageHandler = messageHandlers[handlerId]
			
			if (handler != null)
				handler.handleMessage(jso["b"], XTMSG_TYPE_JSON)
		}
		
		/**
		 * Got String response
		 */
		private function strReceived(msg:String):void
		{
			var params:Array = msg.substr(1, msg.length - 2).split(MSG_STR)

			var handlerId:String = params[0]
			var handler:IMessageHandler = messageHandlers[handlerId]
			
			if (handler != null)
				handler.handleMessage(params.splice(1, params.length - 1), XTMSG_TYPE_STR)
		}
		
		
		
		/************************************************************************
		 * 
		 * Public class methods
		 * 
		 ************************************************************************/
		
		public function addBuddy(buddyName:String):void
		{
			if (buddyName != myUserName && !checkBuddyDuplicates(buddyName))
			{
				var xmlMsg:String = "<n>" + buddyName + "</n>"
				send({t:"sys"}, "addB", -1, xmlMsg)
			}
		}
		
		
		public function autoJoin():void
		{
			var header:Object 	= {t:"sys"}
			this.send(header, "autoJoin", (this.activeRoomId ? this.activeRoomId : -1) , "")
		}
		
		
		public function clearBuddyList():void
		{
			buddyList = []
			send({t:"sys"}, "clearB", -1, "")
			
			// Fire event!
			var params:Object = {}
			params.list = buddyList
			
			var evt:SFSEvent = new SFSEvent(SFSEvent.onBuddyList, params)
			dispatchEvent(evt)
		}
		 
		/**
		 * Create Room
		 */
		public function createRoom(roomObj:Object, roomId:int = -1):void
		{
			if (roomId == -1)
				roomId = activeRoomId
				
			var header:Object = {t:"sys"}
			var isGame:String = (roomObj.isGame) ? "1" : "0"
			var exitCurrentRoom:String = "1"
			var maxUsers:String = roomObj.maxUsers == null ? "0" : String(roomObj.maxUsers)
			var maxSpectators:String = roomObj.maxSpectators == null ? "0" : String(roomObj.maxSpectators)
			
			if (roomObj.isGame && roomObj.exitCurrent != null)
				exitCurrentRoom = roomObj.exitCurrent ? "1" : "0"
				
			var xmlMsg:String  = "<room tmp='1' gam='" + isGame + "' spec='" + maxSpectators + "' exit='" + exitCurrentRoom + "'>"
		
			xmlMsg += "<name><![CDATA[" + (roomObj.name == null ? "" : roomObj.name) + "]]></name>"
			xmlMsg += "<pwd><![CDATA[" + (roomObj.password == null ? "" : roomObj.password) + "]]></pwd>"
			xmlMsg += "<max>" + maxUsers + "</max>"
			
			if (roomObj.uCount != null)
				xmlMsg += "<uCnt>" + (roomObj.uCount ? "1" : "0") + "</uCnt>"
			
			// Set extension for room
			if (roomObj.extension != null)
			{
				xmlMsg += "<xt n='" + roomObj.extension.name
				xmlMsg += "' s='" + roomObj.extension.script + "' />"
			}
			
			// Set Room Variables on creation
			if (roomObj.vars == null)
				xmlMsg += "<vars></vars>"
			else
			{
				xmlMsg += "<vars>"
				
				for (var i:String in roomObj.vars)
				{
					xmlMsg += getXmlRoomVariable(roomObj.vars[i])
				}
				
				xmlMsg += "</vars>"
			}
			
			xmlMsg += "</room>"
				
			send(header, "createRoom", roomId, xmlMsg)
		}
		
		public function connect(ipAdr:String, port:int):void
		{
			if (!connected)
			{
				initialize()
				socketConnection.connect(ipAdr, port)
			}
			else
				trace("*** ALREADY CONNECTED ***")
		}
		
		public function disconnect():void
		{
			socketConnection.close()
			connected = false
			sysHandler.dispatchDisconnection()
		}
		
		public function getAllRooms():Array
		{
			return roomList
		}
		
		public function getBuddyRoom(buddy:Object):void
		{
			// If buddy is active...
			if (buddy.id != -1)
				send({t:"sys", bid:buddy.id}, "roomB", -1, "<b id='" + buddy.id + "' />")
		}
		
		public function getRoom(rid:int):Room
		{
			return roomList[rid]	
		}
		
		public function getRoomByName(roomName:String):Room
		{
			var room:Room = null
			
			for each (var r:Room in roomList)
			{
				if (r.getName() == roomName)
				{
					room = r
					break
				}
			}
			
			return room
		}
		
		public function getRoomList():void
		{
			var header:Object 	= {t:"sys"}
			send(header, "getRmList", activeRoomId, "")	
		}
		
		public function getActiveRoom():Room
		{
			return roomList[activeRoomId]
		}
		
		public function getRandomKey():void
		{
			send({t:"sys"}, "rndK", -1, "")
		}
		
		public function getVersion():String
		{
			return this.majVersion + "." + this.minVersion + "." + this.subVersion
		}
		
		public function get isConnected():Boolean
		{
			return this.connected
		}
		
		public function set isConnected(b:Boolean):void
		{
			this.connected = b
		}
		
		public function joinRoom(newRoom:*, pword:String  = "", isSpectator:Boolean = false, dontLeave:Boolean = false, oldRoom:int = -1):void
		{
			var newRoomId:int = -1
			var isSpec:int = isSpectator ? 1 : 0
			
			if (!this.changingRoom)
			{
				if (typeof newRoom == "number")
					newRoomId = int(newRoom)

				else if (typeof newRoom == "string")
				{
					// Search the room
					for each (var r:Room in roomList)
					{
						if (r.getName() == newRoom)
						{
							newRoomId = r.getId()
							break
						}
					}
				}
				
				if (newRoomId != -1)
				{
					var header:Object = {t:"sys"} 
	
					var leaveCurrRoom:String = dontLeave ? "0": "1"
					
					// Set the room to leave
					var roomToLeave:int = oldRoom > -1 ? oldRoom : activeRoomId

					// CHECK: activeRoomId == -1 no room has already been entered
					if (activeRoomId == -1)
					{
						leaveCurrRoom = "0"
						roomToLeave = -1
					}
					
					var message:String = "<room id='" + newRoomId + "' pwd='" + pword + "' spec='" + isSpec + "' leave='" + leaveCurrRoom + "' old='" + roomToLeave + "' />"
					
					send(header, "joinRoom", activeRoomId, message)
					changingRoom = true
				}
				
				// TODO: Handle error in a better/cleaner way!
				else
				{
					trace("SmartFoxError: requested room to join does not exist!")
				}
			}
		}
		
		public function leaveRoom(roomId:int):void
		{
			var header:Object = {t:"sys"}
			var xmlMsg:String = "<rm id='" + roomId + "' />"
			
			send(header, "leaveRoom", roomId, xmlMsg)
		}
		
		public function loadBuddyList():void
		{
			send({t:"sys"}, "loadB", -1, "")
		}

		
		public function login(zone:String, nick:String, pass:String):void
		{
			var header:Object = {t:"sys"}
			var message:String = "<login z='" + zone + "'><nick><![CDATA[" + nick + "]]></nick><pword><![CDATA[" + pass + "]]></pword></login>"
	
			send(header, "login", 0, message)
		}
		
		
		public function removeBuddy(buddyName:String):void
		{
			var found:Boolean = false
			var buddy:Object
			
			for (var it:String in buddyList)
			{
				buddy = buddyList[it]
				
				if (buddy.name == buddyName)
				{
					delete buddyList[it]
					found = true
					break
				}
			}
			
			if (found)
			{
				var header:Object = {t:"sys"}
				var xmlMsg:String = "<n>" + buddyName + "</n>"
					
				send(header, "remB", -1, xmlMsg)
					
				// Fire event!
				var params:Object = {}
				params.list = buddyList
				
				var evt:SFSEvent = new SFSEvent(SFSEvent.onBuddyList, params)
				dispatchEvent(evt)
			}
		}
		
		public function roundTripBench():void
		{
			this.benchStartTime = getTimer()
			send({t:"sys"}, "roundTrip", activeRoomId, "")
		}
		
		
		public function sendPublicMessage(message:String, roomId:int = -1):void
		{
			if (roomId == -1)
				roomId = activeRoomId
				
			var header:Object = {t:"sys"}
			var xmlMsg:String = "<txt><![CDATA[" + Entities.encodeEntities(message) + "]]></txt>"
			
			send(header, "pubMsg", roomId, xmlMsg)
		}
		
		public function sendPrivateMessage(message:String, recipientId:int, roomId:int = -1):void
		{
			if (roomId == -1)
				roomId = activeRoomId
				
			var header:Object = {t:"sys"}
			var xmlMsg:String = "<txt rcp='" + recipientId + "'><![CDATA[" + Entities.encodeEntities(message) + "]]></txt>"
			send(header, "prvMsg", roomId, xmlMsg)	
		}
		
		
		public function sendModeratorMessage(message:String, type:int, id:int = -1):void
		{	
			var header:Object = {t:"sys"}
			var xmlMsg:String = "<txt t='" + type + "' id='" + id + "'><![CDATA[" + Entities.encodeEntities(message) + "]]></txt>"
	
			send(header, "modMsg", activeRoomId, xmlMsg)	
		}
		
		
		
		public function sendObject(obj:Object, roomId:int = -1):void
		{
			if (roomId == -1)
				roomId = activeRoomId
				
			var xmlData:String = "<![CDATA[" + ObjectSerializer.getInstance().serialize(obj) + "]]>"
			var header:Object = {t:"sys"}
			
			send(header, "asObj", roomId, xmlData)
		}
		
		
		public function sendXtMessage(xtName:String, cmd:String, paramObj:*, type:String = "xml", roomId:int = -1):void
		{
			if (roomId == -1)
				roomId = activeRoomId
			
			// Send XML
			if (type == XTMSG_TYPE_XML)
			{
				var header:Object = {t:"xt"}
				
				// Encapsulate message
				var xtReq:Object = {name: xtName, cmd: cmd, param: paramObj}
				var xmlmsg:String= "<![CDATA[" + ObjectSerializer.getInstance().serialize(xtReq) + "]]>"
				
				send(header, "xtReq", roomId, xmlmsg)
			}
			
			// Send raw/String
			else if (type == XTMSG_TYPE_STR)
			{
				var hdr:String = "%xt%" + xtName + "%" + cmd + "%" + roomId + "%"

				for (var i:Number = 0; i < paramObj.length; i++)
					hdr += paramObj[i].toString() + "%"
	
				sendString(hdr)
			}
			
			// Send JSON
			else if (type == XTMSG_TYPE_JSON)
			{
				var body:Object = {}
				body.x = xtName
				body.c = cmd
				body.r = roomId
				body.p = paramObj
				
				var obj:Object = {}
				obj.t = "xt"
				obj.b = body
				
				var msg:String = JSON.encode(obj)
				sendJson(msg)
			}
		}
		
		
		public function sendObjectToGroup(obj:Object, userList:Array, roomId:int):void
		{
			if (roomId == -1)
				roomId = activeRoomId
			
			var strList:String = ""
			
			for (var i:String in userList)
			{
				if (!isNaN(userList[i]))
					strList += userList[i] + ","
			}
			
			// remove last comma
			strList = strList.substr(0, strList.length - 1)
			
			obj._$$_ = strList
			
			var header:Object = {t:"sys"}
			var xmlMsg:String = "<![CDATA[" + ObjectSerializer.getInstance().serialize(obj) + "]]>"
			
			send(header, "asObjG", roomId, xmlMsg)
		}
		
		public function setBuddyVariables(varList:Array):void
		{			
			var header:Object = {t:"sys"}
			
			// Encapsulate Variables
			var xmlMsg:String = "<vars>"
			
			// Reference to the user setting the variables
			for (var vName:String in varList)
			{
				var vValue:String = varList[vName]
				
				// if variable is new or updated send it and update locally
				if (buddyVars[vName] != vValue)
				{
					buddyVars[vName] = vValue
					xmlMsg += "<var n='" + vName + "'><![CDATA[" + vValue + "]]></var>"
				}
			}
			
			xmlMsg += "</vars>"
		
			this.send(header, "setBvars", -1, xmlMsg)
		}
		
		
		public function setRoomVariables(varList:Array, roomId:int = -1, setOwnership:Boolean = true):void
		{
			if (roomId == -1)
				roomId = activeRoomId
				
			var header:Object = {t:"sys"}
			var xmlMsg:String
			
			if (setOwnership)
				xmlMsg = "<vars>"
			else
				xmlMsg = "<vars so='0'>"
				
			for each (var rv:Object in varList)
				xmlMsg += getXmlRoomVariable(rv)	
				
			xmlMsg += "</vars>"
			
			send(header, "setRvars", roomId, xmlMsg)
		}
		
		
		public function setUserVariables(varObj:Object, roomId:int = -1):void
		{
			if (roomId == -1)
				roomId = activeRoomId
				
			var header:Object = {t:"sys"}
			
			var currRoom:Room = getActiveRoom()
			var user:User = currRoom.getUser(myUserId)
			
			var xmlMsg:String = getXmlUserVariable(varObj)
			
			send(header, "setUvars", roomId, xmlMsg)
		}
		
		public function switchSpectator(roomId:int = -1):void
		{
			if (roomId == -1)
				roomId = activeRoomId

			send({t:"sys"}, "swSpec", roomId, "")
		}
		
		
		private function getXmlRoomVariable(rVar:Object):String
		{
			// Get properties for this var
			var vName:String		= rVar.name.toString()
			var vValue:*	 		= rVar.val.toString()
			var vPrivate:String		= (rVar.priv) ? "1":"0"
			var vPersistent:String	= (rVar.persistent) ? "1":"0"
			
			var t:String = null
			
			// Check type
			if (typeof vValue == "boolean")
			{
				t = "b"
				vValue = (vValue) ? "1" : "0"			// transform in number before packing in xml
			}
			else if (typeof vValue == "number")
				t = "n"
			else if (typeof vValue == "string")
				t = "s"
			else if (typeof vValue == "null")
				t = "x"
			
			if (t != null)
				return "<var n='" + vName + "' t='" + t + "' pr='" + vPrivate + "' pe='" + vPersistent + "'><![CDATA[" + vValue + "]]></var>"
			else
				return ""
		}
		
		private function getXmlUserVariable(uVars:Object):String
		{
			var xmlStr:String = "<vars>"
			var val:*
			var t:String
			var type:String
			
			for (var key:String in uVars)
			{
				val = uVars[key]
				type = typeof(val)
				
				// Check type
				if (type == "boolean")
				{
					t = "b"
					val = (val) ? "1" : "0"	
				}
				else if (type == "number")
					t = "n"
				else if (type == "string")
					t = "s"
				else if (type == "null")
					t = "x"
				
				if (t != null)
					xmlStr += "<var n='" + key + "' t='" + t + "'><![CDATA[" + val + "]]></var>"
			}
			
			xmlStr += "</vars>"
			
			return xmlStr
		}
		
		/************************************************************************
		 * 
		 * Internal Socket Event Handlers
		 * 
		 ************************************************************************/	 
		 private function handleSocketConnection(e:Event):void
		 {
		 	var header:Object = {t:"sys"}
			var xmlMsg:String = "<ver v='" + this.majVersion.toString() + this.minVersion.toString() + this.subVersion.toString() + "' />"	
			
			send(header, "verChk", 0, xmlMsg)
		 }
		 
		 private function handleSocketDisconnection(evt:Event):void
		 {
		 	// Clear data
		 	initialize()
		 	
		 	// Fire event
	 		var sfse:SFSEvent = new SFSEvent(SFSEvent.onConnectionLost, {})	
	 		dispatchEvent(sfse)
		 }
		 
		 private function handleIOError(evt:Event):void
		 {
		 	var sfse:SFSEvent
		 	
		 	if (!connected)
		 	{
		 		var params:Object = {}
		 		params.success = false
		 		params.error = "I/O Error"
		 		
		 		sfse = new SFSEvent(SFSEvent.onConnection, params)	
		 		dispatchEvent(sfse)
		 	}
		 	else
		 	{
		 		trace("I/O Error during connected session")
		 	}
		 }
		 
		 private function handleSocketError(evt:Event):void
		 {
		 	trace("SOCKET ERROR!!!")
		 }
		 
		 private function handleSocketData(evt:Event):void
		 {			
		 	var bytes:int = socketConnection.bytesAvailable

			while (--bytes >= 0)
			{
				var b:int = socketConnection.readByte()
				
				if (b != 0x00)
				{
					byteBuffer.writeByte(b)
				}
				else
				{			
					handleMessage(byteBuffer.toString())
					byteBuffer = new ByteArray()
				}
			}
		 }
		
		/**
		 * Analyze incoming message
		 */
		private function handleMessage(msg:String):void
		{
			if (this.debug)
				trace("[ RECEIVED ]: " + msg + ", (len: " + msg.length + ")")
			
			var type:String = msg.charAt(0)

			if (type == MSG_XML)
			{
				xmlReceived(msg)
			}	
			else if (type == MSG_STR)
			{
				strReceived(msg)
			}	
			else if (type == MSG_JSON)
			{
				jsonReceived(msg)
			}
		}
	}
}