package com.sdg.control
{
	import com.sdg.events.GameCastEvent;
	import com.sdg.model.GameCastRecordMLB;
	import com.sdg.model.LiveGame;
	import com.sdg.utils.Constants;
	
	import flash.events.EventDispatcher;

	public class GameCastRecorder extends EventDispatcher
	{
		private var _gameCastController:GameCastController;
		private var _gameCastRecords:Array;
		
		public function GameCastRecorder(gameCastController:GameCastController)
		{
			super();
			
			_gameCastRecords = [];
			_gameCastController = gameCastController;
			if (Constants.GAME_CAST_RECORDING_ENABLED == true) _gameCastController.addEventListener(GameCastEvent.NEW_GAME_EVENT, onNewGame);
		}
		
		////////////////////
		// INSTANCE METHODS
		////////////////////
		
		public function printRecord(gameEventId:String):String
		{
			var gameCastRecord:GameCastRecordMLB = _gameCastRecords[gameEventId] as GameCastRecordMLB;
			return (gameCastRecord != null) ? gameCastRecord.printRecord() : '';
		}
		
		////////////////////
		// EVENT HANDLERS
		////////////////////
		
		private function onNewGame(e:GameCastEvent):void
		{
			// Get reference to game.
			var game:LiveGame = e.liveGame;
			
			// Create new game record.
			var gameCastRecord:GameCastRecordMLB = new GameCastRecordMLB();
			gameCastRecord.game = game;
			_gameCastRecords[game.id] = gameCastRecord;
			
			_gameCastController.addGameCastListener(game.id, onGamePlayEvent);
		}
		
		private function onGamePlayEvent(e:GameCastEvent):void
		{
			var gameCastRecord:GameCastRecordMLB = _gameCastRecords[e.gamePlayMLB.gameEventId] as GameCastRecordMLB;
			if (gameCastRecord != null) gameCastRecord.addGamePlayEvent(e.gamePlayMLB);
		}
		
	}
}