/**
 * 
 * SmartFoxClient 
 * SysHandler class: handles "sys" type messages
 * 
 * Actionscript 3.0 / Flex 2 / Flash 9 version
 * 
 * @version 	1.0.1
 * @status 		alpha
 * @author 		Marco Lapi
 * 
 * (c) 2006 gotoAndPlay()
 * www.gotoandplay.it
 * www.smartfoxserver.com
 * 
 */
 
package it.gotoandplay.smartfoxserver.handlers
{
	import it.gotoandplay.smartfoxserver.SmartFoxClient;
	import it.gotoandplay.smartfoxserver.SFSEvent;
	import it.gotoandplay.smartfoxserver.data.Room;
	import it.gotoandplay.smartfoxserver.data.User;
	import it.gotoandplay.smartfoxserver.util.Entities;
	import it.gotoandplay.smartfoxserver.util.ObjectSerializer;
	import flash.utils.getTimer;
	
	public class SysHandler implements IMessageHandler
	{
		private var sfs:SmartFoxClient
		private var handlersTable:Array
		
		function SysHandler(sfs:SmartFoxClient)
		{
			this.sfs = sfs	
			handlersTable = []
			
			handlersTable["apiOK"] 			= this.handleApiOK
			handlersTable["apiKO"] 			= this.handleApiKO
			handlersTable["logOK"] 			= this.handleLoginOk
			handlersTable["logKO"] 			= this.handleLoginKo
			handlersTable["rmList"] 		= this.handleRoomList
			handlersTable["uCount"] 		= this.handleUserCountChange
			handlersTable["joinOK"] 		= this.handleJoinOk
			handlersTable["joinKO"] 		= this.handleJoinKo
			handlersTable["uER"] 			= this.handleUserEnterRoom
			handlersTable["userGone"] 		= this.handleUserLeaverRoom
			handlersTable["pubMsg"] 		= this.handlePublicMessage
			handlersTable["prvMsg"] 		= this.handlePrivateMessage
			handlersTable["dmnMsg"] 		= this.handleAdminMessage
			handlersTable["modMsg"] 		= this.handleModMessage 
			handlersTable["dataObj"] 		= this.handleASObject
			handlersTable["rVarsUpdate"] 	= this.handleRoomVarsUpdate
			handlersTable["roomAdd"]		= this.handleRoomAdded
			handlersTable["roomDel"]		= this.handleRoomDeleted
			handlersTable["rndK"]			= this.handleRandomKey
			handlersTable["roundTripRes"]	= this.handleRoundTripBench
			handlersTable["uVarsUpdate"]	= this.handleUserVarsUpdate
			handlersTable["createRmKO"]		= this.handleCreateRoomError
			handlersTable["bList"]			= this.handleBuddyList
			handlersTable["bUpd"]			= this.handleBuddyListUpdate
			handlersTable["bAdd"]			= this.handleBuddyAdded
			handlersTable["roomB"]			= this.handleBuddyRoom
			handlersTable["leaveRoom"]		= this.handleLeaveRoom
			handlersTable["swSpec"]			= this.handleSpectatorSwitched
		}
		
		/**
		 * Handle messages
		 */
		public function handleMessage(msgObj:Object, type:String):void
		{
			var xmlData:XML = msgObj as XML
			var action:String = xmlData.body.@action
			
			// Get handler table
			var fn:Function = handlersTable[action]
			
			if (fn != null)
			{
				fn.apply(this, [msgObj])
			}
			
			else
			{
				trace("Unknown sys command: " + action)
			}
		}
		
		
		// Handle correct API
		public function handleApiOK(o:Object):void
		{
			sfs.isConnected = true
			var evt:SFSEvent = new SFSEvent(SFSEvent.onConnection, {success:true})
			sfs.dispatchEvent(evt)
		}
		
		
		// Handle obsolete API
		public function handleApiKO(o:Object):void
		{
			var params:Object = {}
			params.success = false
			params.error = "API are obsolete, please upgrade"
			
			var evt:SFSEvent = new SFSEvent(SFSEvent.onConnection, params)
			sfs.dispatchEvent(evt)
		}
		
		
		// Handle successfull login
		public function handleLoginOk(o:Object):void
		{		
			var uid:int = int(o.body.login.@id)
			var mod:int = int(o.body.login.@mod)
			var name:String = o.body.login.@n
			
			sfs.amIModerator = (mod == 1)
			sfs.myUserId = uid
			sfs.myUserName = name
			sfs.playerId = -1
			
			var params:Object = {}
			params.success = true
			params.name = name
			params.error = ""
			
			var evt:SFSEvent = new SFSEvent(SFSEvent.onLogin, params)
			sfs.dispatchEvent(evt)
			
			// Request room list
			sfs.getRoomList()
		}
		
		// Handle successfull login
		public function handleLoginKo(o:Object):void
		{
			var params:Object = {}
			params.success = false
			params.error = o.body.login.@e
			
			var evt:SFSEvent = new SFSEvent(SFSEvent.onLogin, params)
			sfs.dispatchEvent(evt)
		}
		
		// Populate the room list for this zone and fire the event
		public function handleRoomList(o:Object):void
		{
			var roomList:Array = sfs.getAllRooms()
			
			for each (var roomXml:XML in o.body.rmList.rm)
			{
				//trace("Room id: " + roomXml.@id + ", " + roomXml.n)
				var roomId:int = int(roomXml.@id)
				var room:Room = new Room(	roomId,
											roomXml.n,
											int(roomXml.@maxu),
											int(roomXml.@maxs),
											(roomXml.@temp == "1"),
											(roomXml.@game == "1"),
											(roomXml.@priv == "1"),
											(roomXml.@lmb == "1"),
											int(roomXml.@ucnt),
											int(roomXml.@scnt)
										)
										
				// Handle Room Variables
				if (roomXml.vars.toString().length > 0)
				{
					populateVariables(room.getVariables(), roomXml)			
				}	
				
				// Add room
				roomList[roomId] = room	
			}
			
			var params:Object = {}
			params.roomList = roomList
			
			var evt:SFSEvent = new SFSEvent(SFSEvent.onRoomListUpdate, params)
			sfs.dispatchEvent(evt)
		}
	
		// Handle the user count change in a room
		public function handleUserCountChange(o:Object):void
		{
			var uCount:int = int(o.body.@u)
			var sCount:int = int(o.body.@s)
			var roomId:int = int(o.body.@r)
			
			var room:Room = sfs.getAllRooms()[roomId]
			
			if (room != null)
			{
				room.setUserCount(uCount)
				room.setSpectatorCount(sCount)
				
				var params:Object = {}
				params.room = room
				
				var evt:SFSEvent = new SFSEvent(SFSEvent.onUserCountChange, params)
				sfs.dispatchEvent(evt)
			}
		}
		
		
		// Successfull room Join
		public function handleJoinOk(o:Object):void
		{
			
			var roomId:int 			= int(o.body.@r)
			var roomVarsXml:XMLList	= o.body
			var userListXml:XMLList = o.body.uLs.u
			var playerId:int		= int(o.body.pid.@id)
			
			// Set current active room
		 	sfs.activeRoomId = roomId
	
			// get current Room and populates usrList
			var currRoom:Room = sfs.getRoom(roomId)
			
			// Set the player ID
			// -1 = no game room
			sfs.playerId = playerId
			
			// Also set the myPlayerId in the room
			// for multi-room applications
			currRoom.setMyPlayerIndex(playerId)
			
			// Handle Room Variables
			if (roomVarsXml.vars.toString().length > 0)
			{
				currRoom.clearVariables()
				populateVariables(currRoom.getVariables(), roomVarsXml)
			}


			// Populate Room userList
			for each (var usr:XML in userListXml)
			{
				// grab the user properties
				var name:String 	= usr.n
				var id:int   		= int(usr.@i)
				var isMod:Boolean 	= usr.@m == "1" ? true : false
				var isSpec:Boolean 	= usr.@s == "1" ? true : false
				var pId:int			= usr.p == undefined ? -1 : int(usr.p)
				
				// Create and populate User
				var user:User = new User(id, name)
				user.setModerator(isMod)
				user.setIsSpectator(isSpec)
				user.setPlayerId(pId)
				
				// Handle user variables
				if (usr.vars.toString().length > 0)
				{
					populateVariables(user.getVariables(), usr)	
				}
				
				// Add user
				currRoom.addUser(user, id)
			}
			
			// operation completed, release lock
			sfs.changingRoom = false
	
			// Fire event!
			var params:Object = {}
			params.room = currRoom
			
			var evt:SFSEvent = new SFSEvent(SFSEvent.onJoinRoom, params)
			sfs.dispatchEvent(evt)
		}
		
		// Failed room Join
		public function handleJoinKo(o:Object):void
		{
			sfs.changingRoom = false
			
			var params:Object = {}
			params.error = o.body.error.@msg
			
			var evt:SFSEvent = new SFSEvent(SFSEvent.onJoinRoomError, params)
			sfs.dispatchEvent(evt)
		}
		
		// New user enters the room
		public function handleUserEnterRoom(o:Object):void
		{
			var roomId:int 			= int(o.body.@r)
			
			// Get params
			var usrId:int 			= int(o.body.u.@i)
			var usrName:String 		= o.body.u.n
			var isMod:Boolean 		= (o.body.u.@m == "1")
			var isSpec:Boolean 		= (o.body.u.@s == "1")
			var pid:int 			= o.body.u.@p != null ? int(o.body.u.@p) : -1
			
			var varList:XMLList		= o.body.u.vars["var"]
			
			var currRoom:Room = sfs.getRoom(roomId)
			
			// Create new user object
			var newUser:User = new User(usrId, usrName)
			newUser.setModerator(isMod)
			newUser.setIsSpectator(isSpec)
			newUser.setPlayerId(pid)
			
			// Add user to room
			currRoom.addUser(newUser, usrId)
			
			// Populate user vars
			if (o.body.u.vars.toString().length > 0)
			{
				populateVariables(newUser.getVariables(), o.body.u)
			}
			
			// Fire event!
			var params:Object = {}
			params.roomId = roomId
			params.user = newUser
			
			var evt:SFSEvent = new SFSEvent(SFSEvent.onUserEnterRoom, params)
			sfs.dispatchEvent(evt)
		}
		
		// User leaves a room
		public function handleUserLeaverRoom(o:Object):void
		{
			var userId:int = int(o.body.user.@id)
			var roomId:int = int(o.body.@r)
			
			// Get room
			var theRoom:Room = sfs.getRoom(roomId)
			
			// Get user name
			var uName:String = theRoom.getUser(userId).getName()
			
			// Remove user
			theRoom.removeUser(userId)
			
			// Fire event!
			var params:Object = {}
			params.roomId = roomId
			params.userId = userId
			params.userName = uName 
			
			var evt:SFSEvent = new SFSEvent(SFSEvent.onUserLeaveRoom, params)
			sfs.dispatchEvent(evt)
			 
		}
		
		public function handlePublicMessage(o:Object):void
		{
			var roomId:int = int(o.body.@r)
			var userId:int = int(o.body.user.@id)
			var message:String = o.body.txt
			
			var sender:User = sfs.getRoom(roomId).getUser(userId)
			
			// Fire event!
			var params:Object = {}
			params.message = Entities.decodeEntities(message)
			params.sender = sender
			params.roomId = roomId 
			
			var evt:SFSEvent = new SFSEvent(SFSEvent.onPublicMessage, params)
			sfs.dispatchEvent(evt)
			
		}
		
		public function handlePrivateMessage(o:Object):void
		{
			var roomId:int = int(o.body.@r)
			var userId:int = int(o.body.user.@id)
			var message:String = o.body.txt
			
			var sender:User = sfs.getRoom(roomId).getUser(userId)
			
			// Fire event!
			var params:Object = {}
			params.message = Entities.decodeEntities(message)
			params.sender = sender
			params.roomId = roomId 
			params.userId = userId
			
			/*
			* AS 2.0 version lacked this:
			* Additionally we pass the roomId and userId, for cross room messaging
			*/
			
			var evt:SFSEvent = new SFSEvent(SFSEvent.onPrivateMessage, params)
			sfs.dispatchEvent(evt)
		}
		
		public function handleAdminMessage(o:Object):void
		{
			var roomId:int = int(o.body.@r)
			var userId:int = int(o.body.user.@id)
			var message:String = o.body.txt
			
			// Fire event!
			var params:Object = {}
			params.message = Entities.decodeEntities(message)
			
			var evt:SFSEvent = new SFSEvent(SFSEvent.onAdminMessage, params)
			sfs.dispatchEvent(evt)
			
		}
		
		public function handleModMessage(o:Object):void
		{
			var roomId:int = int(o.body.@r)
			var userId:int = int(o.body.user.@id)
			var message:String = o.body.txt
			
			var sender:User = sfs.getRoom(roomId).getUser(userId)
			
			// Fire event!
			var params:Object = {}
			params.message = Entities.decodeEntities(message)
			params.sender = sender
			
			var evt:SFSEvent = new SFSEvent(SFSEvent.onModeratorMessage, params)
			sfs.dispatchEvent(evt)
		}
		
		public function handleASObject(o:Object):void
		{
			var roomId:int = int(o.body.@r)
			var userId:int = int(o.body.user.@id)
			var xmlStr:String = o.body.dataObj
			
			var sender:User = sfs.getRoom(roomId).getUser(userId)
			var asObj:Object = ObjectSerializer.getInstance().deserialize(new XML(xmlStr))
			
			// Fire event!
			var params:Object = {}
			params.obj = asObj
			params.sender = sender
			
			var evt:SFSEvent = new SFSEvent(SFSEvent.onObjectReceived, params)
			sfs.dispatchEvent(evt)
		}
		
		public function handleRoomVarsUpdate(o:Object):void
		{
			var roomId:int = int(o.body.@r)
			var userId:int = int(o.body.user.@id)
			
			var currRoom:Room = sfs.getRoom(roomId)
			var changedVars:Array = []
			
			// Handle Room Variables
			if (o.body.vars.toString().length > 0)
			{
				populateVariables(currRoom.getVariables(), o.body, changedVars)
			}
			
			// Fire event!
			var params:Object = {}
			params.room = currRoom
			params.changedVars = changedVars
			
			var evt:SFSEvent = new SFSEvent(SFSEvent.onRoomVariablesUpdate, params)
			sfs.dispatchEvent(evt)
		}
		
		public function handleUserVarsUpdate(o:Object):void
		{
			var roomId:int = int(o.body.@r)
			var userId:int = int(o.body.user.@id)
			
			var currUser:User = sfs.getRoom(roomId).getUser(userId)
			var changedVars:Array = []
			
			if (o.body.vars.toString().length > 0)
			{
				populateVariables(currUser.getVariables(), o.body, changedVars)
			}
			
			// Fire event!
			var params:Object = {}
			params.user = currUser
			params.changedVars = changedVars
			
			var evt:SFSEvent = new SFSEvent(SFSEvent.onUserVariablesUpdate, params)
			sfs.dispatchEvent(evt)
		}
		
		private function handleRoomAdded(o:Object):void
		{
			var rId:int = int(o.body.rm.@id)
			var rName:String = o.body.rm.name
			var rMax:int = int(o.body.rm.@max)
			var rSpec:int = int(o.body.rm.@spec)
			var isTemp:Boolean = o.body.rm.@temp == "1" ? true : false
			var isGame:Boolean = o.body.rm.@game == "1" ? true : false
			var isPriv:Boolean = o.body.rm.@priv == "1" ? true : false
			var isLimbo:Boolean = o.body.rm.@limbo == "1" ? true : false
			
			// Create room obj
			var newRoom:Room = new Room(rId, rName, rMax, rSpec, isTemp, isGame, isPriv, isLimbo)
			
			var rList:Array = sfs.getAllRooms()
			rList[rId] = newRoom
			
			// Handle Room Variables
			if (o.body.rm.vars.toString().length > 0)
				populateVariables(newRoom.getVariables(), o.body.rm)
			
			// Fire event!
			var params:Object = {}
			params.room = newRoom
			
			var evt:SFSEvent = new SFSEvent(SFSEvent.onRoomAdded, params)
			sfs.dispatchEvent(evt)
			
		} 
		
		private function handleRoomDeleted(o:Object):void
		{
			var roomId:int = int(o.body.rm.@id)
			
			var roomList:Array = sfs.getAllRooms()
			
			// Pass the last reference to the upper level
			// If there's no other references to this room in the upper level
			// This is the last reference we're keeping
			
			// Fire event!
			var params:Object = {}
			params.room = roomList[roomId]
			
			// Remove reference from main room list
			delete roomList[roomId]

			var evt:SFSEvent = new SFSEvent(SFSEvent.onRoomDeleted, params)
			sfs.dispatchEvent(evt)
		}
		
		
		private function handleRandomKey(o:Object):void
		{
			var key:String = o.body.k.toString()
			
			// Fire event!
			var params:Object = {}
			params.key = key
			
			var evt:SFSEvent = new SFSEvent(SFSEvent.onRandomKey, params)
			sfs.dispatchEvent(evt)
		}
		
		private function handleRoundTripBench(o:Object):void
		{
			var now:int = getTimer()
			var res:int = now - sfs.getBenchStartTime()
			
			// Fire event!
			var params:Object = {}
			params.elapsed = res
			
			var evt:SFSEvent = new SFSEvent(SFSEvent.onRoundTripResponse, params)
			sfs.dispatchEvent(evt)		
		}
		
		private function handleCreateRoomError(o:Object):void
		{
			var errMsg:String = o.body.room.@e
			
			// Fire event!
			var params:Object = {}
			params.error = errMsg
			
			var evt:SFSEvent = new SFSEvent(SFSEvent.onCreateRoomError, params)
			sfs.dispatchEvent(evt)
		}
		
		private function handleBuddyList(o:Object):void
		{
			var bList:XMLList = o.body.bList
			var buddy:Object 
			var params:Object = {}
			var evt:SFSEvent = null
			
			if (bList != null && bList.b.length != null)
			{
				if (bList.toString().length > 0)
				{
					for each (var b:XML in bList.b)
					{
						buddy = {}
						buddy.isOnline = b.@s == "1" ? true : false
						buddy.name = b.n.toString()
						buddy.id = b.@i
						buddy.variables = {}
						
						// Runs through buddy variables
						var bVars:XMLList = b.vs
						
						if (bVars.toString().length > 0)
						{
							for each (var bVar:XML in bVars.v)
							{
								buddy.variables[bVar.@n.toString()] = bVar.v.toString()
							}
						}
						
						sfs.buddyList.push(buddy)
					}
				}
				
				// Fire event!
				params.list = sfs.buddyList
				evt = new SFSEvent(SFSEvent.onBuddyList, params)
				sfs.dispatchEvent(evt)
			}
			
			// Buddy List load error!
			else
			{
				// Fire event!
				params.error = o.body.err.toString()
				evt = new SFSEvent(SFSEvent.onBuddyListError, params)
				sfs.dispatchEvent(evt)
			}
		}
		
		
		private function handleBuddyListUpdate(o:Object):void
		{
			var params:Object = {}
			var evt:SFSEvent = null

			if (o.body.b != null)
			{
				var buddy:Object = {}
				buddy.isOnline = o.body.b.@s == "1" ? true : false
				buddy.name = o.body.b.n.toString()
				buddy.id = o.body.b.@i
				buddy.variables = {}

				// Runs through buddy variables
				var bVars:XMLList = o.body.b.vs
				
				if (bVars.toString().length > 0)
				{
					for each (var bVar:XML in bVars.v)
					{
						buddy.variables[bVar.@n.toString()] = bVar.v.toString()
					}
				}
				
				var tempB:Object = null
				var found:Boolean = false
				
				for (var it:String in sfs.buddyList)
				{
					tempB = sfs.buddyList[it]
					
					if (tempB.name == buddy.name)
					{
						sfs.buddyList[it] = buddy
						found = true
						break
					}
				}

				// Fire event!
				params.buddy = buddy
				evt = new SFSEvent(SFSEvent.onBuddyListUpdate, params)
				sfs.dispatchEvent(evt)
			}
			
			// Buddy List load error!
			else
			{
				// Fire event!
				params.error = o.body.err.toString()
				evt = new SFSEvent(SFSEvent.onBuddyListError, params)
				sfs.dispatchEvent(evt)
			}
		}
		
		private function handleBuddyAdded(o:Object):void
		{
			var buddy:Object = {}
			buddy.isOnline = o.body.b.@s == "1" ? true : false
			buddy.name = o.body.b.n.toString()
			buddy.id = o.body.b.@i
			buddy.variables = {}

			// Runs through buddy variables
			var bVars:XMLList = o.body.b.vs
			
			if (bVars.toString().length > 0)
			{
				for each (var bVar:XML in bVars.v)
				{
					buddy.variables[bVar.@n.toString()] = bVar.v.toString()
				}
			}
			
			sfs.buddyList.push(buddy)

			// Fire event!
			var params:Object = {}
			params.list = sfs.buddyList
			
			var evt:SFSEvent = new SFSEvent(SFSEvent.onBuddyList, params)
			sfs.dispatchEvent(evt)
		}
		
		private function handleBuddyRoom(o:Object):void
		{
			var roomIds:String = o.body.br.@r
			var ids:Array = roomIds.split(",")
			
			for (var i:int = 0; i < ids.length; i++)
				ids[i] = int(ids[i])
				
			// Fire event!
			var params:Object = {}
			params.idList = ids
			
			var evt:SFSEvent = new SFSEvent(SFSEvent.onBuddyRoom, params)
			sfs.dispatchEvent(evt)
		}
		
		private function handleLeaveRoom(o:Object):void
		{
			var roomLeft:int = int(o.body.rm.@id)
			
			// Fire event!
			var params:Object = {}
			params.roomId = roomLeft
			
			var evt:SFSEvent = new SFSEvent(SFSEvent.onRoomLeft, params)
			sfs.dispatchEvent(evt)
		}
		
		private function handleSpectatorSwitched(o:Object):void
		{
			var roomId:int = int(o.body.rm.@id)
			sfs.playerId = int(o.body.pid.@id)
			
			// Fire event!
			var params:Object = {}
			params.success = sfs.playerId > 0
			params.newId = sfs.playerId
			params.room = sfs.getRoom(roomId)
			
			var evt:SFSEvent = new SFSEvent(SFSEvent.onSpectatorSwitched, params)
			sfs.dispatchEvent(evt)
		}
		
		//=======================================================================
		// Other class methods
		//=======================================================================
		/**
		 * Takes an SFS variables XML node and store it in an array
		 * Usage: for parsing room and user variables
		 * 
		 * @xmlData	 	xmlData		the XML variables node
		*/	
		private function populateVariables(variables:Array, xmlData:Object, changedVars:Array = null):void
		{		
			for each (var v:XML in xmlData.vars["var"])
			{
				var vName:String = v.@n
				var vType:String = v.@t
				var vValue:String = v
				
				//trace(vName + " : " + vValue)
				
				// Add the vName to the list of changed vars
				// The changed List is an array that can contains all the
				// var names changed with numeric indexes but also contains
				// the var names as keys for faster search
				if (changedVars != null)
				{
					changedVars.push(vName)
					changedVars[vName] = true
				}
				
				if (vType == "b")
					variables[vName] = Boolean(vValue)
							
				else if (vType == "n")
					variables[vName] = Number(vValue)
					
				else if (vType == "s")
					variables[vName] = vValue
					
				else if (vType == "x")
					delete variables[vName]
				
			}	
		}
		
			
		public function dispatchDisconnection():void
		{
			var evt:SFSEvent = new SFSEvent(SFSEvent.onConnectionLost, null)
			sfs.dispatchEvent(evt)		
		}

		
		/*
		private function populateVariables(xmlData:Object):Array
		{		
			var variables:Array = []

			for each (var v:XML in xmlData.vars["var"])
			{
				var vName:String = v.@n
				var vType:String = v.@t
				var vValue:String = v
				
				//trace(vName + " : " + vValue)
				
				if (vType == "b")
					variables[vName] = Boolean(vValue)
							
				else if (vType == "n")
					variables[vName] = Number(vValue)
					
				else if (vType == "s")
					variables[vName] = vValue
					
				else if (vType == "x")
					delete variables[vName]
				
			}
			
			return variables
		}
		*/
	}
}