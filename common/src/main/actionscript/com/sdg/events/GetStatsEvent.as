package com.sdg.events
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	public class GetStatsEvent extends CairngormEvent
	{
		public static const GET_STATS:String = "getStats";
		public static const STATS_RECEIVED:String = "statsReceived";
		public static const GET_STATS_ERROR:String = "getStatsError";
		
		private var _gameId:int;
		private var _statsXml:XMLList;
		private var _timeCheck:Boolean;
		private var _gameOn:Boolean;
		
		public function GetStatsEvent(type:String, gameId:int, statsXml:XMLList = null, timeCheck:Boolean = false, gameOn:Boolean = false)
		{
			super(type);
			_gameId = gameId;
			_statsXml = statsXml;
			_timeCheck = timeCheck;
			_gameOn = gameOn;
		}
		
		public function get statsXml():XMLList
		{
			return _statsXml;
		}
		
		public function get gameId():int
		{
			return _gameId;
		}
		
		public function get timeCheck():Boolean
		{
			return _timeCheck;
		}
		
		public function get gameOn():Boolean
		{
			return _gameOn;
		}
	}
}