package com.sdg.events
{
	import com.sdg.model.LiveGame;
	import com.sdg.model.LiveGamePlayMLB;
	
	import flash.events.Event;

	public class GameCastEvent extends Event
	{
		public static const NEW_GAME_EVENT:String = 'new game event';
		public static const PLAY_EVENT:String = 'game cast play event';
		public static const START_GAME_EVENT:String = 'start game event';
		public static const END_GAME_EVENT:String = 'end game event';
		
		private var _xml:XML;
		private var _liveGame:LiveGame;
		private var _gamePlayMLB:LiveGamePlayMLB;
		private var _params:Object;
		
		public function GameCastEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		public function get xml():XML
		{
			return _xml;
		}
		public function set xml(value:XML):void
		{
			_xml = value;
		}
		
		public function get liveGame():LiveGame
		{
			return _liveGame;
		}
		public function set liveGame(value:LiveGame):void
		{
			_liveGame = value;
		}
		
		public function get gamePlayMLB():LiveGamePlayMLB
		{
			return _gamePlayMLB;
		}
		public function set gamePlayMLB(value:LiveGamePlayMLB):void
		{
			_gamePlayMLB = value;
		}
		
		public function get params():Object
		{
			return _params;
		}
		
		public function set params(value:Object):void
		{
			_params = value;
		}
	}
}