package com.sdg.events
{
	import flash.events.Event;
	
	public class StartGameEvent extends Event
	{
		public static const START_GAME:String = "startGame";
		protected var _numPlayers:int;
		protected var _team1ItemId:int;
		protected var _team2ItemId:int;
		
		public function StartGameEvent(numPlayers:int, team1ItemId:int, team2ItemId:int)
		{
			super(START_GAME);
			
			_numPlayers = numPlayers;
			_team1ItemId = team1ItemId;
			_team2ItemId = team2ItemId;
		}
		
		public function get numPlayers():int
		{
			return _numPlayers;
		}
		
		public function get team1ItemId():int
		{
			return _team1ItemId;
		}
		
		public function get team2ItemId():int
		{
			return _team2ItemId;
		}
	}
}