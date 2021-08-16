package com.sdg.game.counter
{
	import com.sdg.net.Environment;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;

	/**
	 * GamePlayCounter handles loading of data related to game play count for the local user.
	 *  
	 * @author Tommy
	 * 
	 */	
	public class GamePlayCounter extends EventDispatcher
	{
		public static const MAX_FREE_PLAYS_PER_DAY:int = 1;
		
		private static var _instance:GamePlayCounter;
		private static var _localAvatarId:int;
		private static var _isLoaded:Boolean;
		private static var _gamePlayCountDaily:Array;
		private static var _gamePlayCountAllTime:Array;
		private static var _isAllTimeCountLoaded:Array;
		
		public function GamePlayCounter()
		{
			super();
		}
		
		////////////////////
		// PUBLIC FUNCTIONS
		////////////////////
		
		public static function init(localAvatarId:int):void
		{
			_instance = new GamePlayCounter();
			
			_localAvatarId = localAvatarId;
			_isLoaded = false;
			_gamePlayCountDaily = [];
			_gamePlayCountAllTime = [];
			_isAllTimeCountLoaded = [];
			
			loadPlayCountData(_localAvatarId);
		}
		
		public static function getPlayCount(gameId:int):int
		{
			// Make sure data has been loaded.
			if (!_isLoaded) return -1;
			
			var count:int = _gamePlayCountDaily[gameId] as int;
			return count;
		}
		
		public static function getPlayCountAllTime(gameId:int):int
		{
			// Make sure data has been loaded.
			if (!_isAllTimeCountLoaded[gameId]) return -1;
			
			var count:int = _gamePlayCountAllTime[gameId] as int;
			return count;
		}
		
		public static function incrementGamePlay(gameId:int):int
		{
			// Returns new count.
			var currentCountDaily:int = _gamePlayCountDaily[gameId] as int;
			var currentCountAllTime:int = _gamePlayCountAllTime[gameId] as int;
			_gamePlayCountDaily[gameId] = currentCountDaily + 1;
			_gamePlayCountAllTime[gameId] = currentCountAllTime + 1;
			
			return currentCountDaily + 1;
		}
		
		public static function loadAllTimeGamePlayCount(gameId:int, onComplete:Function = null, onError:Function = null):void
		{
			loadPlayCountData(_localAvatarId, gameId, onComplete, onError);
		}
		
		public static function isAllTimeCountLoaded(gameId:int):Boolean
		{
			return _isAllTimeCountLoaded[gameId];
		}
		
		////////////////////
		// PRIVATE FUNCTIONS
		////////////////////
		
		private static function loadPlayCountData(avatarId:int, gameId:int = -1, onCompleteCallback:Function = null, onErrorCallback:Function = null):void
		{
			// Load game play count for local avatar.
			var url:String;
			if (gameId > 0)
			{
				url = Environment.getApplicationUrl() + '/test/gameAllTime?avatarId=' + avatarId + '&gameId=' + gameId;
			}
			else
			{
				url = Environment.getApplicationUrl() + '/test/gameLimit?avatarId=' + avatarId;
			}
			var request:URLRequest = new URLRequest(url);
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, onComplete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onError);
			loader.load(request);
			
			function onError(e:IOErrorEvent):void
			{
				// Remove listeners.
				loader.removeEventListener(Event.COMPLETE, onComplete);
				loader.removeEventListener(IOErrorEvent.IO_ERROR, onError);
				
				// Callback.
				if (onErrorCallback != null) onErrorCallback();
			}
			
			function onComplete(e:Event):void
			{
				// Remove listeners.
				loader.removeEventListener(Event.COMPLETE, onComplete);
				loader.removeEventListener(IOErrorEvent.IO_ERROR, onError);
				
				// Parse xml.
				var gamePlayCountXml:XML = new XML(loader.data);
				var i:int = 0;
				while(gamePlayCountXml.game[i])
				{
					// Parse out daily game play count for each game node.
					var gameXml:XML = gamePlayCountXml.game[i] as XML;
					i++;
					if (!gameXml) continue;
					var thisGameId:int = gameXml.@gameId;
					if (gameId > 0)
					{
						// If a game id was passed in, we only want to parse out the value for "all time" plays.
						if (thisGameId != gameId) continue;
						// If a game id was passed in, parse "all time" play count as well.
						var allTimePlayCount:int = gameXml.@atp;
						if (allTimePlayCount) _gamePlayCountAllTime[gameId] = allTimePlayCount;
					}
					else
					{
						// No game id was passed in, so we want to parse out the value for game plays today only.
						var playCount:int = gameXml.@not;
						if (!thisGameId || !playCount) continue;
						_gamePlayCountDaily[thisGameId] = playCount;
					}
				}
				
				// Set flag.
				_isLoaded = true;
				if (gameId) _isAllTimeCountLoaded[gameId] = true;
				
				// Callback.
				if (onCompleteCallback != null) onCompleteCallback();
				
				// Dispatch a complete event.
				_instance.dispatchEvent(new Event(Event.COMPLETE));
			}
		}
		
		////////////////////
		// GET/SET FUNCTIONS
		////////////////////
		
		public static function get isLoaded():Boolean
		{
			return _isLoaded;
		}
		
	}
}