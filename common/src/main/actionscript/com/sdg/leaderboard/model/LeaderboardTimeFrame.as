package com.sdg.leaderboard.model
{
	public class LeaderboardTimeFrame extends Object
	{
		public static const DAY:uint = 1;
		public static const WEEK:uint = 2;
		public static const MONTH:uint = 3;
		public static const ALL_TIME:uint = 4;
		
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
			_NAME_MAP = ['', 'Day', 'Week', 'Month', 'All-Time'];
		}
		
	}
}