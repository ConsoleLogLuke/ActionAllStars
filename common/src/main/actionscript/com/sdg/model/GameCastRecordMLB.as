package com.sdg.model
{
	import com.sdg.events.GameCastEvent;
	
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	public class GameCastRecordMLB extends EventDispatcher
	{
		private var _game:LiveGame;
		private var _gamePlayRecord:Array;
		private var _gamePlayTimes:Array;
		private var _initialTime:Number;
		private var _isRecording:Boolean;
		private var _playBackIndex:uint;
		private var _isPlayBack:Boolean;
		
		public function GameCastRecordMLB(recordXML:XML = null)
		{
			super();
			
			_isRecording = true;
			_isPlayBack = false;
			_initialTime = ModelLocator.getInstance().serverDate.time;
			_gamePlayRecord = [];
			_gamePlayTimes = [];
			_playBackIndex = 0;
			
			// If record xml was passed in,
			// Generate the record from that xml.
			if (recordXML != null) generateRecordFromXML(recordXML);
		}
		
		////////////////////
		// INSTANCE METHODS
		////////////////////
		
		public function addGamePlayEvent(gamePlay:LiveGamePlayMLB):void
		{
			// Store the gameplay xml.
			
			// If the game object is not set, throw an error.
			if (_isRecording != true)
			{
				throw(new Error('Recording on this object is now disabled.'));
			}
			else if (_game == null)
			{
				throw(new Error('You must first set the game object before you can record game play events.'));
			}
			
			// Make sure the event id for the play event matches the game id.
			if (_game.id != gamePlay.gameEventId) return;
			
			// Keep track of the game play object and the time it was added.
			_gamePlayRecord.push(gamePlay);
			_gamePlayTimes.push(ModelLocator.getInstance().serverDate.time - _initialTime);
		}
		
		public function printRecord():String
		{
			var i:int = 0;
			var len:int = _gamePlayRecord.length;
			var root:XML = new XML('<gameCastRecord initialTime="' + _initialTime + '"></gameCastRecord>');
			
			// Append game event xml.
			if (_game != null) root.appendChild(LiveGame.GetGameXML(_game));
			
			// Append game play event xml.
			for (i; i < len; i++)
			{
				var gamePlay:LiveGamePlayMLB = _gamePlayRecord[i] as LiveGamePlayMLB;
				if (gamePlay == null) continue;
				var gamePlayXML:XML = LiveGamePlayMLB.GetGamePlayXML(gamePlay);
				// Append time offset to the xml.
				gamePlayXML.appendChild('<timeOffset>' + _gamePlayTimes[i] + '</timeOffset>');
				// Append the gameplay.
				root.appendChild(gamePlayXML);
			}
			
			return root.toXMLString();
		}
		
		private function generateRecordFromXML(gameCastRecordXML:XML):void
		{
			// Set recording to false.
			_isRecording = false;
			
			// Get initial time.
			var initialTime:uint = gameCastRecordXML.@initialTime;
			_initialTime = initialTime;
			
			// Parse the game event.
			var gameEventXML:XML = XML(gameCastRecordXML.gameEvent[0]);
			var game:LiveGame = LiveGame.LiveGameFromXML(gameEventXML);
			_game = game;
			
			// Now parse all gameplay events.
			var i:int = 0;
			var gamePlayArray:Array = [];
			var timeOffsetArray:Array = [];
			while(gameCastRecordXML.baseballGamePlay[i] != null)
			{
				var gamePlayXML:XML = new XML(gameCastRecordXML.baseballGamePlay[i]);
				var gamePlay:LiveGamePlayMLB = LiveGamePlayMLB.LiveGamePlayFromXML(gamePlayXML);
				var timeOffset:uint = gamePlayXML.timeOffset;
				_gamePlayRecord.push(gamePlay);
				_gamePlayTimes.push(timeOffset);
				i++;
			}
		}
		
		public function playBack(startInProgress:Boolean = false):void
		{
			// Make sure we are not already playing back.
			if (_isPlayBack == true) return;
			
			// Set play back to true.
			_isPlayBack = true;
			
			// Set recording to false;
			_isRecording = false;
			
			_playBackIndex = 0;
			var interval:uint = 100;
			var playBackTime:uint = 0;
			var timer:Timer = new Timer(interval);
			timer.addEventListener(TimerEvent.TIMER, onTimer);
			
			// If start in progress is true,
			// Start playback from the first in progress event.
			if (startInProgress == true)
			{
				var i:int = 0;
				var len:int = _gamePlayTimes.length;
				for (i; i < len; i++)
				{
					var gamePlay:LiveGamePlayMLB = _gamePlayRecord[i] as LiveGamePlayMLB;
					if (gamePlay.gameProgress == 'In Progress')
					{
						_playBackIndex = i;
						playBackTime = _gamePlayTimes[i];
						break;
					}
				}
			}
			
			// Start the timer.
			timer.start();
			
			function onTimer(e:TimerEvent):void
			{
				// If there are no more game play events to play back,
				// Stop play back.
				if (_playBackIndex >= _gamePlayTimes.length)
				{
					timer.removeEventListener(TimerEvent.TIMER, onTimer);
					timer.reset();
					_isPlayBack = false;
					return;
				}
				
				// Determine if it is time to dispatch a gameplay event.
				playBackTime += interval;
				var gamePlayTime:uint = _gamePlayTimes[_playBackIndex];
				if (playBackTime >= gamePlayTime)
				{
					// Dispatch this gameplay event.
					// Create a game cast event.
					var gameCastEvent:GameCastEvent = new GameCastEvent(GameCastEvent.PLAY_EVENT);
					gameCastEvent.gamePlayMLB = _gamePlayRecord[_playBackIndex] as LiveGamePlayMLB;
					gameCastEvent.xml = LiveGamePlayMLB.GetGamePlayXML(gameCastEvent.gamePlayMLB);
					dispatchEvent(gameCastEvent);
					
					// Increment play back index.
					_playBackIndex++;
				}
			}
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		public function get game():LiveGame
		{
			return _game;
		}
		public function set game(value:LiveGame):void
		{
			if (value == _game) return;
			_game = value;
			// Clear plays and times.
			_gamePlayRecord = [];
			_gamePlayTimes = [];
		}
		
	}
}