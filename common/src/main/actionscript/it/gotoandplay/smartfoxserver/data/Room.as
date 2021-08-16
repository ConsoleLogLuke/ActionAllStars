package it.gotoandplay.smartfoxserver.data
{
	import it.gotoandplay.smartfoxserver.data.*
	
	public class Room
	{
		private var id:int
		private var name:String
		private var maxUsers:int
		private var maxSpectators:int
		private var temp:Boolean
		private var game:Boolean
		private var priv:Boolean
		private var limbo:Boolean
		private var userCount:int
		private var specCount:int
		
		private var myPlayerIndex:int
		
		private var userList:Array
		private var variables:Array
		
		/**
		 * Default constructor
		 * 
		 * @param id				room id
		 * @param name				room bame
		 * @param maxUsers			max users in room
		 * @param maxSpectators		max spectators in room (for game rooms only)
		 * @param isTemp			is room temporary?
		 * @param isGame			is room a game?
		 * @param isPrivate			is the room private?
		 */
		public function Room(	id:int, 
								name:String, 
								maxUsers:int, 
								maxSpectators:int, 
								isTemp:Boolean, 
								isGame:Boolean, 
								isPrivate:Boolean,
								isLimbo:Boolean,
								userCount:int = 0,
								specCount:int = 0
							)
		{
			this.id = id
			this.name = name
			this.maxSpectators = maxSpectators
			this.maxUsers = maxUsers
			this.temp = isTemp
			this.game = isGame
			this.priv = isPrivate
			this.limbo = isLimbo
			
			this.userCount = userCount
			this.specCount = specCount
			this.userList = []
			this.variables = []		
		}
		
		public function addUser(u:User, id:int):void
		{
			userList[id] = u
			userCount++
		}
		
		public function removeUser(id:int):void
		{
			delete userList[id]
			userCount--
		}
		
		public function getUserList():Array
		{
			return this.userList
		}
		
		/**
		 * Return a user
		 * You can pass either a name (string) or user id (int)
		 * 
		 * @return the User
		 */ 
		public function getUser(userId:*):User
		{
			var user:User = null
			
			if (typeof userId == "number")
			{
				user =  userList[userId]
			}
			
			else if (typeof userId == "string")
			{
				for (var i:String in userList)
				{
					var u:User = this.userList[i]
		
					if (u.getName() == userId)
					{
						user = u
						break
					}
				}
			}
			
			return user
		}
		
		
		public function getVariable(varName:String):Object
		{
			return variables[varName]
		}
		
		public function clearVariables():void
		{
			this.variables = []
		}
		
		public function getVariables():Array
		{
			return variables
		}
		
		public function getName():String
		{
			return this.name
		}
		
		public function getId():int
		{
			return this.id
		}
		
		public function isTemp():Boolean
		{
			return this.temp
		}
		
		public function isGame():Boolean
		{
			return this.game
		}
		
		public function isPrivate():Boolean
		{
			return this.priv
		}
		
		public function getUserCount():int
		{
			return this.userCount
		}
		
		public function getSpectatorCount():int
		{
			return this.specCount
		}
		
		public function getMaxUsers():int
		{
			return this.maxUsers
		}
		
		public function getMaxSpectators():int
		{
			return this.maxSpectators
		}
		
		
		/*
		* Set the myPlayerId
		* Each room where the current client is connected contains a myPlayerId
		* if the room is a gameRoom
		*
		* myPlayerId == -1 ... user is a spectator
		* myPlayerId  > 0  ...	user is a player
		*/
		public function setMyPlayerIndex(id:int):void
		{
			this.myPlayerIndex = id
		}
		
		// Returns my player id for this room
		// Usefull when dealing with multi-room applications
		public function getMyPlayerIndex():int
		{
			return this.myPlayerIndex
		}
		
		public function setIsLimbo(b:Boolean)
		{
			this.limbo = b
		}
		
		public function isLimbo():Boolean
		{
			return this.limbo
		}
		
		public function setUserCount(n:int):void
		{
			this.userCount = n
		}
		
		public function setSpectatorCount(n:int):void
		{
			this.specCount = n
		}
		
		public function setVariables(vars:Array):void
		{
			this.variables = vars
		}
	}
}