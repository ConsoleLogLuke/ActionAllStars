package com.sdg.model
{
	public class Team
	{
		protected var _teamId:uint;
		protected var _teamColor1:uint;
		protected var _teamColor2:uint;
		protected var _teamColor3:uint;
		protected var _teamColor4:uint;
		protected var _teamName:String;
		protected var _cityName:String;
		protected var _leagueId:uint;
		
		public function Team(teamId:uint, teamName:String = null, cityName:String = null, leagueId:int = 0,
							teamColor1:uint = 0, teamColor2:uint = 0, teamColor3:uint = 0, teamColor4:uint = 0)
		{
			_teamId = teamId;
			_teamColor1 = teamColor1;
			_teamColor2 = teamColor2;
			_teamColor3 = teamColor3;
			_teamColor4 = teamColor4;
			_teamName = teamName;
			_cityName = cityName;
			_leagueId = leagueId;
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		public function get teamId():uint
		{
			return _teamId;
		}
		
		public function get teamName():String
		{
			return _teamName;
		}
		
		public function get cityName():String
		{
			return _cityName;
		}
		
		public function get teamColor1():uint
		{
			return _teamColor1;
		}
		
		public function get teamColor2():uint
		{
			return _teamColor2;
		}
		
		public function get teamColor3():uint
		{
			return _teamColor3;
		}
		
		public function get teamColor4():uint
		{
			return _teamColor4;
		}
		
		public function get leagueId():uint
		{
			return _leagueId;
		}
	}
}
