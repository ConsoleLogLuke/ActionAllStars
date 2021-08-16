package com.sdg.control.room
{
	import com.sdg.control.GameCastController;
	import com.sdg.display.render.RenderData;
	import com.sdg.display.render.RenderLayer;
	import com.sdg.display.render.RenderObject;
	import com.sdg.events.GameCastEvent;
	import com.sdg.model.LiveGame;
	import com.sdg.model.LiveGamePlayMLB;
	import com.sdg.model.RoomLayerType;
	import com.sdg.net.Environment;
	
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.geom.Matrix;
	import flash.net.URLRequest;

	public class DiamondRunController extends EventDispatcher implements IRoomSpecificController
	{
		private var _roomController:RoomController;
		private var _fanManiaScreenDisplay:DisplayObject;
		private var _assetPath:String;
		private var _currentGame:LiveGame;
		private var _lastPlay:LiveGamePlayMLB;
		private var _gamePreparedFlags:Array;
		private var _awayLogo:DisplayObject;
		private var _homeLogo:DisplayObject;
		
		public function DiamondRunController(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		////////////////////
		// INSTANCE METHODS
		////////////////////
		
		public function initRoom(roomController:RoomController):void
		{
			// Disable this functionality.
			return;
			
			
			_roomController = roomController;
			_assetPath = Environment.getAssetUrl() + '/test/gameSwf/gameId/69/gameFile/';
			_gamePreparedFlags = [];
			
			// Create the fan mania screen.
			createFanManiaScreen();
			
			// Get a reference to the gamecast controller.
			var gameCastController:GameCastController = _roomController.roomView.gameCastController;
			
			// Listen for gamecast events.
			gameCastController.addEventListener(GameCastEvent.END_GAME_EVENT, onEndGameEvent);
			gameCastController.addEventListener(GameCastEvent.START_GAME_EVENT, onStartGameEvent);
			
			// If there is a current game, prepare it.
			var currentGame:LiveGame = gameCastController.getCurrentGame();
			if (currentGame != null)
			{
				_currentGame = currentGame;
				prepareCurrentGame();
			}
			else
			{
				// Listen for new game events.
				gameCastController.addEventListener(GameCastEvent.NEW_GAME_EVENT, onNewGame);
			}
		}
		
		public function init():void
		{
			
		}
		
		public function destroy():void
		{
			if (_roomController == null) return;
			var gameCastController:GameCastController = _roomController.roomView.gameCastController;
			gameCastController.addEventListener(GameCastEvent.END_GAME_EVENT, onEndGameEvent);
			gameCastController.addEventListener(GameCastEvent.START_GAME_EVENT, onStartGameEvent);
		}
		
		private function prepareCurrentGame():void
		{
			// Get reference to current game current game.
			var currentGame:LiveGame = _currentGame;
			
			// Make sure this game has not already been prepared.
			var preparedFlag:Boolean = _gamePreparedFlags[currentGame.id] as Boolean;
			if (preparedFlag == true) return;
			
			// Set prepared flag to true.
			_gamePreparedFlags[currentGame.id] = true;
			
			// Get a reference to the gamecast controller.
			var gameCastController:GameCastController = _roomController.roomView.gameCastController;
			
			// Listen for game play events for this game.
			gameCastController.addGameCastListener(currentGame.id, onGamePlayEvent);
			
			// Update the screen with proper values.
			updateScreen();
			
			// If the game hasn't started, show the next game screen.
			// Otherwise, show the scoreboard.
			/*if (currentGame.isGameStarted != true)
			{
				endGameScreens.setNextGame(currentGame.startDate.toLocaleString(), currentGame.awayTeam.name, currentGame.homeTeam.name);
				setScreenContent(endGameScreens);
			}
			else
			{
				_model.roomController.buddyClickEnabled = false;
			}*/
			
			// Load team logos.
			loadTeamLogos();
		}
		
		private function loadTeamLogos():void
		{
			// Load away and home team logos.
			
			loadAwayTeamLogo();
			loadHomeTeamLogo();
		}
		
		private function loadAwayTeamLogo():void
		{
			var i:int = 0;
			var len:int = 1;
			var url:String = 'http://' + Environment.getAssetDomain() + '/test/static/clipart/teamLogoTemplate?teamId=' + _currentGame.awayTeam.id;
			var request:URLRequest = new URLRequest(url);
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLogoComplete);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLogoError);
			loader.load(request);
			
			function onLogoComplete(e:Event):void
			{
				// Set display object.
				var logo:DisplayObject = loader.content;
				
				// Determine where this logo should be placed.
				switch(i)
				{
					case 0 :
						_awayLogo = logo;
						updateScreen();
						break;
				}
				
				// Iterate.
				i++;
				
				// Continue loading the logo until we have placed all needed logos.
				if (i < len)
				{
					loader.load(request);
				}
				else
				{
					// Remove event listeners.
					loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLogoComplete);
					loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onLogoError);
				}
			}
			
			function onLogoError(e:IOErrorEvent):void
			{
				// Remove event listeners.
				loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLogoComplete);
				loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onLogoError);
			}
		}
		
		private function loadHomeTeamLogo():void
		{
			var i:int = 0;
			var len:int = 1;
			var url:String = 'http://' + Environment.getAssetDomain() + '/test/static/clipart/teamLogoTemplate?teamId=' + _currentGame.homeTeam.id;
			var request:URLRequest = new URLRequest(url);
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLogoComplete);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLogoError);
			loader.load(request);
			
			function onLogoComplete(e:Event):void
			{
				// Set display object.
				var logo:DisplayObject = loader.content;
				
				// Determine where this logo should be placed.
				switch(i)
				{
					case 0 :
						_homeLogo = logo;
						updateScreen();
						break;
				}
				
				// Iterate.
				i++;
				
				// Continue loading the logo until we have placed all needed logos.
				if (i < len)
				{
					loader.load(request);
				}
				else
				{
					// Remove event listeners.
					loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLogoComplete);
					loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onLogoError);
				}
			}
			
			function onLogoError(e:IOErrorEvent):void
			{
				// Remove event listeners.
				loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLogoComplete);
				loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onLogoError);
			}
		}
		
		private function createFanManiaScreen():void
		{
			// Load the fan mania screen swf.
			var url:String = _assetPath + 'diamond_run_screen.swf';
			var request:URLRequest = new URLRequest(url);
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
			loader.load(request);
			
			function onComplete(e:Event):void
			{
				// Remove listeners.
				loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onComplete);
				loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onError);
				
				// Set display reference.
				_fanManiaScreenDisplay = loader.content;
				
				// Scew the screen.
				var skewMatrix:Matrix = new Matrix(1, -Math.atan2(33, 142));
				_fanManiaScreenDisplay.transform.matrix = skewMatrix;
				
				// Position the screen.
				_fanManiaScreenDisplay.x = 341;
				_fanManiaScreenDisplay.y = 70;
				
				// Cache as bitmap.
				_fanManiaScreenDisplay.cacheAsBitmap = true;
				
				// Add the screen to the background.
				var renderLayer:RenderLayer = _roomController.roomView.getRenderLayer(RoomLayerType.BACKGROUND);
				renderLayer.addItem(new RenderObject(new RenderData(_fanManiaScreenDisplay)));
				
				// Update the screen with proper values.
				updateScreen();
			}
			
			function onError(e:IOErrorEvent):void
			{
				// Remove listeners.
				loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onComplete);
				loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onError);
			}
			
		}
		
		private function updateScreen():void
		{
			// Make sure there is a current game and the screen display exists.
			if (_currentGame == null || _fanManiaScreenDisplay == null) return;
			
			// Try to pass values to the screen.
			var screen:Object = _fanManiaScreenDisplay as Object;
			try
			{
				screen.teamName1 = _currentGame.awayTeam.shortName;
				screen.teamName2 = _currentGame.homeTeam.shortName;
				if (_awayLogo != null) screen.teamLogo1 = _awayLogo;
				if (_homeLogo != null) screen.teamLogo2 = _homeLogo;
			}
			catch (e:Error)
			{
				trace(e.message);
			}
		}
		
		////////////////////
		// EVENT HANDLERS
		////////////////////
		
		private function onNewGame(e:GameCastEvent):void
		{
			// Get a reference to the gamecast controller.
			var gameCastController:GameCastController = _roomController.roomView.gameCastController;
			
			// Remove new game events listener.
			gameCastController.removeEventListener(GameCastEvent.NEW_GAME_EVENT, onNewGame);
			
			// Remove gamecast listener for previous game.
			if (_currentGame != null)
			{
				gameCastController.removeGameCastListener(_currentGame.id, onGamePlayEvent);
			}
			
			// Set current game.
			_currentGame = e.liveGame;
			
			// Prepare the current gamne.
			prepareCurrentGame();
		}
		
		private function onStartGameEvent(e:GameCastEvent):void
		{
			
		}
		
		private function onEndGameEvent(e:GameCastEvent):void
		{
			// Get a reference to the gamecast controller.
			var gameCastController:GameCastController = _roomController.roomView.gameCastController;
			
			// Check for a new game.
			var currentGame:LiveGame = gameCastController.getCurrentGame();
			if (currentGame != null)
			{
				_currentGame = currentGame;
				prepareCurrentGame();
			}
			else
			{
				// Listen for new game events.
				gameCastController.addEventListener(GameCastEvent.NEW_GAME_EVENT, onNewGame);
			}
		}
		
		private function onGamePlayEvent(e:GameCastEvent):void
		{
			var gamePlay:LiveGamePlayMLB = e.gamePlayMLB;
			
			var currentGame:LiveGame = _currentGame;
			
			// If the gameplay event is not for the current game, do nothing.
			if (currentGame.id != gamePlay.gameEventId) return;
			
			// Check if the game is in progress.
			if (_currentGame.isGameStarted == true && _currentGame.isGameOver == false)
			{
				// Game is in progress.
			}
			
			// Save the game score in the model
			//_model.homeTeamScore = gamePlay.homeTeamScore;
			//_model.awayTeamScore = gamePlay.awayTeamScore;
			
			// Update score board.
			/*_scoreBoardDisplay.score1 = gamePlay.awayTeamScore;
			_scoreBoardDisplay.score2 = gamePlay.homeTeamScore;
			_scoreBoardDisplay.balls = gamePlay.balls;
			_scoreBoardDisplay.strikes = gamePlay.strikes;
			_scoreBoardDisplay.outs = gamePlay.outs;
			_scoreBoardDisplay.inning = gamePlay.inning;
			_scoreBoardDisplay.inningIsTop = gamePlay.isInningTop;
			if (gamePlay.comment.length > 0) _scoreBoardDisplay.tickerText = gamePlay.comment;*/
			
			// If the game hasn't started, show the next game screen.
			// Otherwise, show the scoreboard.
			/*if (currentGame.isGameStarted != true)
			{
				endGameScreens.setNextGame(currentGame.startDate.toLocaleString(), currentGame.awayTeam.name, currentGame.homeTeam.name);
				setScreenContent(endGameScreens);
			}
			else
			{
				setScreenContent(_scoreBoardDisplay);
			}*/
			
			// Keep reference of latest play.
			_lastPlay = gamePlay;
		}
		
	}
}