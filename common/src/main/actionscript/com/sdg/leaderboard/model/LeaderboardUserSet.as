package com.sdg.leaderboard.model
{
	public class LeaderboardUserSet extends Object
	{
		public static const FRIENDS:uint = 1;
		public static const TEAM:uint = 2;
		public static const WORLD:uint = 3;
		
		protected static var _NAME_MAP:Array;
		
		public static function GetName(timeFrameId:uint):String
		{
			if (_NAME_MAP == null) makeNameMap();
			return _NAME_MAP[timeFrameId];
		}
		
		public static function GetId(timeFrameName:String):int
		{
			if (_NAME_MAP == null) makeNameMap();
			return _NAME_MAP.indexOf(timeFrameName);
		}
		
		protected static function makeNameMap():void
		{
			_NAME_MAP = ['', 'Friends', 'Team', 'World'];
		}
		
	}
}