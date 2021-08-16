package com.sdg.events
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	public class AvatarStatEvent extends CairngormEvent
	{
		public static const GET_STAT:String = "getStat";
		public static const SAVE_STAT:String = "saveStat";
		public static const STAT_RECEIVED:String = "statReceived";
		
		private var _avatarId:int;
		private var _statNameId:int;
		private var _statValue:int;
		
		public function AvatarStatEvent(avatarId:int, statNameId:int, type:String = GET_STAT, statValue:int = 0)
		{
			super(type);
			_avatarId = avatarId;
			_statNameId = statNameId;
			_statValue = statValue;
		}
		
		public function get avatarId():int
		{
			return _avatarId;
		}
		
		public function get statNameId():int
		{
			return _statNameId;
		}
		
		public function get statValue():int
		{
			return _statValue;
		}
	}
}