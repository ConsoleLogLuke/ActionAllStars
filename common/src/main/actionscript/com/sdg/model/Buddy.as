package com.sdg.model
{
	import com.sdg.utils.MathUtil;
	
	[Bindable]
	public class Buddy
	{
		private var _name:String;
		private var _avatarId:int;
		private var _status:int;
		private var _presence:int;
		private var _roomId:String;
		private var _roomName:String;
		private var _level:int;
		private var _teamId:int;
		private var _teamName:String;
		private var _teamColor1:uint;
		private var _teamColor2:uint;
		private var _teamColor3:uint;
		private var _teamColor4:uint;
		private var _gender:int;
		private var _partyBalloon:Object;
		private var _partyMode:int;
		
		public function set name(value:String):void
		{
			_name = value;
		} 
		
		public function get name():String
		{
			return _name;
		}
		
		public function set roomId(value:String):void
		{
			_roomId = value;
		} 
		
		public function get roomId():String
		{
			return _roomId;
		}
		
		public function set roomName(value:String):void
		{
			_roomName = value;
		} 
		
		public function get roomName():String
		{
			return _roomName;
		}
		
		public function set level(value:int):void
		{
			_level = value;
		} 
		
		public function get level():int
		{
			return _level;
		}
		
		public function set avatarId(value:int):void
		{
			_avatarId = value;
		} 
		
		public function get avatarId():int
		{
			return _avatarId;
		}
		
		public function set status(value:int):void
		{
			_status = value;
		} 
		
		public function get status():int
		{
			return _status;
		}
		
		public function set presence(value:int):void
		{
			_presence = value;
		} 
		
		public function get presence():int
		{
			return _presence;
		}
		
		public function set teamId(value:int):void
		{
			_teamId = value;
		} 
		
		public function get teamId():int
		{
			return _teamId;
		}
		
		public function set teamName(value:String):void
		{
			_teamName = value;
		} 
		
		public function get teamName():String
		{
			return _teamName;
		}
		
		public function set teamColor1(value:uint):void
		{
			_teamColor1 = value;
		} 
		
		public function get teamColor1():uint
		{
			return _teamColor1;
		}
		
		public function set teamColor2(value:uint):void
		{
			_teamColor2 = value;
		} 
		
		public function get teamColor2():uint
		{
			return _teamColor2;
		}
		
		public function set teamColor3(value:uint):void
		{
			_teamColor3 = value;
		} 
		
		public function get teamColor3():uint
		{
			return _teamColor3;
		}
		
		public function set teamColor4(value:uint):void
		{
			_teamColor4 = value;
		} 
		
		public function get teamColor4():uint
		{
			return _teamColor4;
		}
		
		public function set gender(value:int):void
		{
			_gender = value;
		}
		
		public function get gender():int
		{
			return _gender;
		}
		
		public function set partyMode(value:int):void
		{
			_partyMode = value;
		}
		
		public function get partyMode():int
		{
			return _partyMode;
		}
		
		public function get partyBalloon():int
		{
			if (_partyBalloon == null)
				_partyBalloon = MathUtil.random(1, 6);
			
			return int(_partyBalloon);
		}
	}
}