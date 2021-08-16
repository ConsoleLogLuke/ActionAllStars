package com.sdg.events
{
	import com.adobe.cairngorm.control.CairngormEvent;

	public class ChallengesEvent extends CairngormEvent
	{
		public static const CHALLENGES:String = "challenges";
		
		private var _gameId:uint;
		
		public function ChallengesEvent(gameId:uint)
		{
			_gameId = gameId;
			super(CHALLENGES);
		}
		
		// properties
		
		public function get gameId():uint
		{
		   	return _gameId;	
		}
	}
}