package com.sdg.control
{
	import com.sdg.events.GameCastEvent;
	import com.sdg.events.SocketEvent;
	import com.sdg.model.GameCastRecordMLB;
	import com.sdg.model.LiveGame;
	import com.sdg.model.LiveGameCollection;
	import com.sdg.model.LiveGamePlayMLB;
	import com.sdg.model.LiveGamePlayer;
	import com.sdg.model.LiveGamePlayerCollection;
	import com.sdg.net.Environment;
	import com.sdg.net.socket.SocketClient;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;

	public class GameCastController extends EventDispatcher
	{
		public static const IS_LIVE:Boolean = false;
		
		private var _games:LiveGameCollection;
		private var _players:LiveGamePlayerCollection;
		private var _gameCastListeners:Array;
		private var _rosterLoadedFlags:Array;
		private var _gamePlayEventQue:Array;
		private var _previousPlayArray:Array;
		
		public function GameCastController()
		{
			super();
			
			// Default values.
			_games = new LiveGameCollection();
			_players = new LiveGamePlayerCollection();
			_gameCastListeners = [];
			_rosterLoadedFlags = [];
			_gamePlayEventQue = [];
			_previousPlayArray = [];
			
			// If this is live, then listen to the server for gamecast events.
			if (IS_LIVE == true)
			{
				// Add socket event listener.
				SocketClient.getInstance().addEventListener(SocketEvent.PLUGIN_EVENT, onSocketPluginEvent);
			}
			else
			{
				// If it's not live, load a recorded gamecast.
				var gameCastUrl:String = Environment.getAssetUrl() + '/test/gameSwf/gameId/69/gameFile/gameCastRecord.xml';
				loadRecordedGameCast(gameCastUrl);
			}
		}
		
		////////////////////
		// INSTANCE METHODS
		////////////////////
		
		public function destroy():void
		{
			// Remove event listeners.
			SocketClient.getInstance().removeEventListener(SocketEvent.PLUGIN_EVENT, onSocketPluginEvent);
		}
		
		private function addGame(game:LiveGame):void
		{
			// Make sure we are not already keeping track of this game.
			var currentGame:LiveGame = _games.getFromId(game.id);
			if (currentGame != null) return;
			
			// Add the game to the collection.
			_games.push(game);
			
			// Set flag.
			_rosterLoadedFlags[game.id] = false;
			
			// Dispatch a new game event.
			var event:GameCastEvent = new GameCastEvent(GameCastEvent.NEW_GAME_EVENT);
			event.liveGame = game;
			dispatchEvent(event);
			
			// Load the roster for this game.
			var url:String = 'http://' + Environment.getAssetDomain() + '/test/dyn/playerInfo/get?eventId=' + game.id;
			var request:URLRequest = new URLRequest(url);
			var urlLoader:URLLoader = new URLLoader(request);
			urlLoader.addEventListener(Event.COMPLETE, onRosterLoadComplete);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onRosterLoadError);
			urlLoader.load(request);
			
			function onRosterLoadComplete(e:Event):void
			{
				// Remove event listeners.
				urlLoader.removeEventListener(Event.COMPLETE, onRosterLoadComplete);
				urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, onRosterLoadError);
				
				// Create XML from returned data.
				var xml:XML = new XML(urlLoader.data);
				var rosterXML:XMLList = xml.roster;
				
				// Create players and team rosters.
				var i:int = 0;
				var i2:int;
				var playersXML:XML;
				var playerXML:XML;
				var player:LiveGamePlayer;
				while (rosterXML.players[i] != null)
				{
					playersXML = rosterXML.players[i];
					i2 = 0;
					while(playersXML.player[i2] != null)
					{
						playerXML = playersXML.player[i2];
						player = LiveGamePlayer.PlayerFromXML(playerXML);
						addPlayer(player);
						i2++;
					}
					i++;
				}
				
				// Set flag.
				_rosterLoadedFlags[game.id] = true;
				
				// Determine if there is a qued gameplay event for this game.
				// If so, parse it.
				if (_gamePlayEventQue[game.id] != null)
				{
					var gamePlayXML:XML = _gamePlayEventQue[game.id] as XML;
					if (gamePlayXML != null) parseGamePlayEvent(gamePlayXML);
					_gamePlayEventQue[game.id] = null;
				}
			}
			
			function onRosterLoadError(e:IOErrorEvent):void
			{
				// Remove event listeners.
				urlLoader.removeEventListener(Event.COMPLETE, onRosterLoadComplete);
				urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, onRosterLoadError);
			}
		}
		
		private function addPlayer(player:LiveGamePlayer):void
		{
			// Make sure we aren't already keeping track of this player.
			var currentPlayer:LiveGamePlayer = _players.getFromId(player.id);
			if (currentPlayer != null) return;
			
			// Add the player to the collection.
			_players.push(player);
		}
		
		private function handleTeamPickEvent(gameParams:Object):void
		{
			// Create a live game object.
			var newGameXML:XML = (gameParams.teamPickEvent != null) ? new XML(gameParams.teamPickEvent) : null;
			if (newGameXML == null) return;
			var liveGame:LiveGame = LiveGame.LiveGameFromXML(newGameXML);
			
			// Begin keeping track of this game.
			addGame(liveGame);
		}
		
		private function handleNewGameEvent(gameParams:Object):void
		{
			// Create a live game object.
			var newGameXML:XML = (gameParams.newGameEvent != null) ? new XML(gameParams.newGameEvent) : null;
			if (newGameXML == null) return;
			var liveGame:LiveGame = LiveGame.LiveGameFromXML(newGameXML);
			
			// Begin keeping track of this game.
			addGame(liveGame);
		}
		
		private function handleEndGameEvent(endGameParams:Object):void
		{
			var gameEndXML:XML = (endGameParams.gameEndEvent != null) ? new XML(endGameParams.gameEndEvent) : null;
			if (gameEndXML == null) return;
			
			// Create a game cast event.
			var liveGame:LiveGame = _games.getFromId(gameEndXML.gameEventId);
			if (liveGame == null) return;
			liveGame.isGameOver = true;
			
			var gameCastEvent:GameCastEvent = new GameCastEvent(GameCastEvent.END_GAME_EVENT);
			gameCastEvent.liveGame = liveGame;
			gameCastEvent.params = endGameParams;
			dispatchEvent(gameCastEvent);
			
			if (gameEndXML.hasOwnProperty("nextGameEvent"))
			{
				var nextGameXML:XML = new XML(gameEndXML.nextGameEvent.gameEvent);
				var nextGame:LiveGame = LiveGame.LiveGameFromXML(nextGameXML);
				addGame(nextGame);
			}
		}
		
		private function handleGamePlayEvent(gamePlayParams:Object):void
		{
			var gamePlayXML:XML = (gamePlayParams.gamePlayEvent != null) ? new XML(gamePlayParams.gamePlayEvent) : null;
			if (gamePlayXML == null) return;
			
			parseGamePlayEvent(gamePlayXML);
		}
		
		private function parseGamePlayEvent(xml:XML):void
		{
			var gamePlayXML:XML = xml;
			
			// Determine game event id.
			var gameEventId:String = (gamePlayXML.gameEventId != null) ? gamePlayXML.gameEventId : '';
			
			// Check that we are keeping track of this game.
			var liveGame:LiveGame = _games.getFromId(gameEventId);
			if (liveGame == null) return;
			
			// Make sure that the roster for this game event has been loaded.
			if (_rosterLoadedFlags[liveGame.id] != true)
			{
				// If the roster has not been loaded.
				// Que the game play event to parse later once the roster is loaded.
				_gamePlayEventQue[liveGame.id] = gamePlayXML;
				return;
			}
			
			// Modify xml.
			// Add player information into base nodes.
			addPlayerDetail('base1PlayerId', 'base1Player');
			addPlayerDetail('base2PlayerId', 'base2Player');
			addPlayerDetail('base3PlayerId', 'base3Player');
			// Add player info for pitcher and batter.
			addPlayerDetail('pitcherId', 'pitcher');
			addPlayerDetail('batterPlayerId', 'batterPlayer');
			
			// Create an MLB game play object.
			var gamePlay:LiveGamePlayMLB = LiveGamePlayMLB.LiveGamePlayFromXML(gamePlayXML);
			
			// Determine and set play type.
			var previousPlay:LiveGamePlayMLB = _previousPlayArray[liveGame.id] as LiveGamePlayMLB;
			if (previousPlay != null) LiveGamePlayMLB.SetPlayParamsFromConsecutivePlays(previousPlay, gamePlay);
			
			// Determine if that game has started.
			if (gamePlay.gameProgress == 'In Progress' || gamePlay.inning > 1 || gamePlay.isInningTop == false || gamePlay.balls > 0 || gamePlay.strikes > 0 || gamePlay.outs > 0)
			{
				liveGame.isGameStarted = true;
				
				var startGameEvent:GameCastEvent = new GameCastEvent(GameCastEvent.START_GAME_EVENT);
				startGameEvent.liveGame = liveGame;
				dispatchEvent(startGameEvent);
			}
			
			// Create a game cast event.
			var gameCastEvent:GameCastEvent = new GameCastEvent(GameCastEvent.PLAY_EVENT);
			gameCastEvent.xml = gamePlayXML;
			gameCastEvent.gamePlayMLB = gamePlay;
			
			// Determine if we should call functions for object listening for game cast events.
			var i:int = 0;
			var len:int = _gameCastListeners.length;
			for (i; i < len; i++)
			{
				var link:Array = _gameCastListeners[i];
				var gameId:String = link[0] as String;
				if (gameId != gameEventId) continue;
				
				// Call function.
				// Pass in game cast event.
				var callback:Function = link[1] as Function;
				callback(gameCastEvent);
			}
			
			// Keep track of this play for later reference.
			_previousPlayArray[liveGame.id] = gamePlay;
			
			function addPlayerDetail(nodeName:String, newNodeName:String):void
			{
				// Get a reference to the base node.
				var originalNode:XMLList = gamePlayXML.child(nodeName);
				
				// Make sure we have a base node.
				if (originalNode == null) return;
				
				// Get player id.
				var playerId:uint = originalNode.toString();
				
				// Get player object.
				var player:LiveGamePlayer = _players.getFromId(playerId);
				if (player == null) return;
				
				// Create a new XML node with player info.
				var playerNode:XML = new XML('<' + newNodeName + '><playerId>' + player.id + '</playerId><displayName>' + player.name + '</displayName><teamId>' + player.teamId + '</teamId><number>' + player.number + '</number></' + newNodeName + '>');
				
				// Add the new player node to the XML.
				// If a node with the new node name already exiists, replace it.
				var currentNode:XMLList = gamePlayXML.child(newNodeName);
				if (currentNode.length() > 0)
				{
					gamePlayXML.replace(newNodeName, playerNode);
				}
				else
				{
					gamePlayXML = gamePlayXML.appendChild(playerNode);
				}
            }
		}
		
		public function addGameCastListener(gameEventId:String, callbackFunction:Function):void
		{
			// When we recieve play events for the game with this id,
			// Call the callback function.
			
			// Keep track of this in an array.
			var link:Array = [gameEventId, callbackFunction];
			_gameCastListeners.push(link);
		}
		
		public function removeGameCastListener(gameEventId:String, callbackFunction:Function):void
		{
			// Stop calling the callback function when we recieve play events for this game event id.
			
			// Search for this link.
			var i:int = 0;
			var len:int = _gameCastListeners.length;
			for (i; i < len; i++)
			{
				var link:Array = _gameCastListeners[i];
				var gameId:String = link[0] as String;
				if (gameId != gameEventId) continue;
				var callback:Function = link[1] as Function;
				
				// If the link matches,
				// Remove it.
				if (callback == callbackFunction)
				{
					_gameCastListeners.splice(i, 1);
					return;
				}
			}
		}
		
		private function loadRecordedGameCast(url:String):void
		{
			var request:URLRequest = new URLRequest(url);
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, onComplete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onError);
			loader.load(request);
			
			function onComplete(e:Event):void
			{
				// Remove event listeners.
				loader.removeEventListener(Event.COMPLETE, onComplete);
				loader.removeEventListener(IOErrorEvent.IO_ERROR, onError);
				
				// Turn the loaded data into a game cast record object.
				var gameCastRecordXML:XML = new XML(loader.data);
				var gameCastRecord:GameCastRecordMLB = new GameCastRecordMLB(gameCastRecordXML);
				
				// Add the game.
				addGame(gameCastRecord.game);
				
				// Play back the record.
				gameCastRecord.addEventListener(GameCastEvent.PLAY_EVENT, onRecordedPlayEvent);
				gameCastRecord.playBack(true);
				
				function onRecordedPlayEvent(e:GameCastEvent):void
				{
					parseGamePlayEvent(e.xml);
				}
			}
			function onError(e:IOErrorEvent):void
			{
				// Remove event listeners.
				loader.removeEventListener(Event.COMPLETE, onComplete);
				loader.removeEventListener(IOErrorEvent.IO_ERROR, onError);
			}
		}
		
		public function getCurrentGame():LiveGame
		{
			// Determine the most current game and return it.
			
			var len:int = _games.length;
			var currentGame:LiveGame;
			var gameTime:uint;
			for (var i:int = 0; i < len; i++)
			{
				var game:LiveGame = _games.getAt(i);
				
				// If this game is over, skip this game.
				if (game.isGameOver) continue;
				
				// If there is not already a current game, this game becomes the current game.
				if (currentGame != null)
				{
					// If this game starts before the other current game, it becomes the current game.
					if (game.startDate.time < gameTime)
					{
						// Make this the current game.
						currentGame = game;
						gameTime = game.startDate.time;
					}
				}
				else
				{
					// Make this the current game.
					currentGame = game;
					gameTime = game.startDate.time;
				}
			}
			
			// Return the current game, if any.
			return currentGame;
		}
		
		////////////////////
		// EVENT HANDLERS
		////////////////////
		
		private function onSocketPluginEvent(e:SocketEvent):void
		{
			// Get reference to plugin event parameters.
			var socketPluginParams:Object = e.params;
			
			// Check action name.
			// Look for specific actions.
			switch (socketPluginParams.action)
			{
				case 'newGameEvent' :
					handleNewGameEvent(socketPluginParams);
					break;
				case 'gamePlayEvent' :
					handleGamePlayEvent(socketPluginParams);
					break;
				case 'gameEndEvent' :
					handleEndGameEvent(socketPluginParams);
					break;
				case 'teamPickEvent' :
					handleTeamPickEvent(socketPluginParams);
					break;
			}
		}
		
	}
}