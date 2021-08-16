package com.sdg.game.models
{
	public class UnityNBATier
	{
		private var _locked:Boolean;
		private var _teams:Array;
		
		public function UnityNBATier(teams:Array = null)
		{
			_teams = teams;
		}
		
		public function addTeam(team:UnityNBATeam):void
		{
			if (_teams == null)
				_teams = new Array();
			
			_teams.push(team);
		}
		
		public function set locked(value:Boolean):void
		{
			_locked = value;
		}
		
		public function get locked():Boolean
		{
			return _locked;
		}
		
		public function get teams():Array
		{
			return _teams;
		}
	}
}