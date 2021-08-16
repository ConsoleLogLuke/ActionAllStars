package com.sdg.events
{
	import com.adobe.cairngorm.control.CairngormEvent;

	public class GameAttributesEvent extends CairngormEvent
	{
		public static const GAME_ATTRIBUTES:String = "gameAttributes";
		
		private var _avatarId:uint;
		private var _gameId:uint;
		private var _achievementId:uint;
		private var _team1ItemId:uint;
		private var _team2ItemId:uint;
		
		public function GameAttributesEvent(avatarId:uint, gameId:uint, achievementId:uint = 0, team1ItemId:uint = 0, team2ItemId:uint = 0)
		{
			super(GAME_ATTRIBUTES);
			_avatarId = avatarId;
			_gameId = gameId;
			_achievementId = achievementId;
			_team1ItemId = team1ItemId;
			_team2ItemId = team2ItemId;
		}
		
		public function get avatarId():int
		{
			return _avatarId;
		}
		
		public function get gameId():uint
		{
			return _gameId;
		}
		
		public function get achievementId():uint
		{
			return _achievementId;
		}
		
		public function get team1ItemId():uint
		{
			return _team1ItemId;
		}
		
		public function get team2ItemId():uint
		{
			return _team2ItemId;
		}
	}
}