package com.sdg.events
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	public class GetTeamsEvent extends CairngormEvent
	{
		public static const GET_TEAMS:String = "getTeams";
		public static const TEAMS_RECEIVED:String = "teamsReceived";
		public static const GET_TEAMS_ERROR:String = "getTeamsError";
		
		protected var _getOwned:Boolean;
		protected var _teamsXml:XMLList;
		
		public function GetTeamsEvent(type:String, getOwned:Boolean, teamsXml:XMLList = null)
		{
			super(type);
			_getOwned = getOwned;
			_teamsXml = teamsXml;
		}
		
		public function get teamsXml():XMLList
		{
			return _teamsXml;
		}
		
		public function get getOwned():Boolean
		{
			return _getOwned;
		}
	}
}