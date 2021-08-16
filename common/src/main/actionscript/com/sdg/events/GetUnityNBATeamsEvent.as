package com.sdg.events
{
	import com.adobe.cairngorm.control.CairngormEvent;

	public class GetUnityNBATeamsEvent extends CairngormEvent
	{
		public static const GET_UNITY_NBA_TEAMS:String = "get unity nba teams";
		public static const UNITY_NBA_TEAMS_RETURNED:String = "unity nba teams returned";
		
		private var _returnData:Object;
		
		public function GetUnityNBATeamsEvent(type:String = GET_UNITY_NBA_TEAMS, returnData:Object = null)
		{
			super(type);
			_returnData = returnData;
		}
		
		public function get returnData():Object
		{
			return _returnData;
		}
	}
}