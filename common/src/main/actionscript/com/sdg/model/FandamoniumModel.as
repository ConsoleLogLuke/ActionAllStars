package com.sdg.model
{
	import com.boostworthy.animation.management.AnimationManager;
	import com.sdg.control.GameCastController;
	import com.sdg.control.room.RoomController;
	import com.sdg.control.room.RoomManager;
	import com.sdg.control.room.itemClasses.AvatarController;
	import com.sdg.display.render.RenderData;
	import com.sdg.display.render.RenderLayer;
	import com.sdg.display.render.RenderObject;
	import com.sdg.events.RoomEnumEvent;
	import com.sdg.net.Environment;
	import com.sdg.swf.fandemonium.FandemoniumLeftCrowd;
	import com.sdg.swf.fandemonium.FandemoniumRightCrowd;
	
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.media.Sound;
	import flash.net.URLRequest;
	import flash.utils.Timer;

	public class FandamoniumModel extends EventDispatcher
	{
		public static const NONE_STATUS:String = 'none asset status';
		public static const LOADING_STATUS:String = 'loading asset status';
		public static const ERROR_STATUS:String = 'error asset status';
		public static const COMPLETE_STATUS:String = 'complete asset status';
		public static const NO_URL_STATUS:String = 'no url asset status';
		
		private var _roomController:RoomController;
		private var _userTeamSelected:Boolean;
		private var _selectedTeamId:uint;
		private var _room:Room;
		private var _homeTeamFanScore:int;
		private var _awayTeamFanScore:int;
		private var _homeTeamScore:int;
		private var _awayTeamScore:int;
		private var _userAvatar:Avatar;
		private var _userAvatarController:AvatarController;
		private var _gameCastController:GameCastController;
		private var _currentGame:LiveGame;
		private var _currentPrizeItems:FandamoniumPrizeItemCollection;
		private var _prizeQue:FandamoniumPrizeItemCollection;
		private var _initialRoomEnumRefresh:Boolean;
		private var _playAnimationUrlArray:Array;
		private var _playAnimationArray:Array;
		private var _playAnimationStatusArray:Array;
		private var _endGameScreenHomeLogo:DisplayObject;
		private var _endGameScreenAwayLogo:DisplayObject;
		private var _teamSirens1:Array;
		private var _teamSirens2:Array;
		private var _allTeamSirens:Array;
		private var _cheerGameScreenUrl:String;
		private var _teamSelectLogo1:DisplayObject;
		private var _teamSelectLogo2:DisplayObject;
		private var _soundUrlArray:Array;
		private var _soundStatusArray:Array;
		private var _soundArray:Array;
		private var _lastPlay:LiveGamePlayMLB;
		private var _awayCrowd:FandemoniumLeftCrowd;
		private var _homeCrowd:FandemoniumRightCrowd;
		private var _awayCrowdTimeout:Timer;
		private var _homeCrowdTimeout:Timer;
		private var _introHasBeenShown:Boolean;
		private var _introPopupUrl:String;
		private var _fanManiaLogoLeftUrl:String;
		private var _fanManiaLogoRightUrl:String;
		private var _animationManager:AnimationManager;
		private var _waveButtonUrl:String;
		private var _userInitialTokenCount:uint;
		
		public function FandamoniumModel(roomController:RoomController)
		{
			super();
			
			// Default.
			_roomController = roomController;
			_userTeamSelected = false;
			_selectedTeamId = 0;
			_homeTeamFanScore = 0;
			_awayTeamFanScore = 0;
			_homeTeamScore = 0;
			_awayTeamScore = 0;
			_userAvatar = ModelLocator.getInstance().avatar;
			_userAvatarController = RoomManager.getInstance().userController;
			_gameCastController = _roomController.roomView.gameCastController;
			_currentPrizeItems = new FandamoniumPrizeItemCollection();
			_prizeQue = new FandamoniumPrizeItemCollection();
			_initialRoomEnumRefresh = false;
			_playAnimationUrlArray = [];
			_playAnimationArray = [];
			_playAnimationStatusArray = [];
			_teamSirens1 = [];
			_teamSirens2 = [];
			_allTeamSirens = [];
			_soundUrlArray = [];
			_soundStatusArray = [];
			_soundArray = [];
			_awayCrowdTimeout = new Timer(7000);
			_homeCrowdTimeout = new Timer(7000);
			_introHasBeenShown = false;
			_userInitialTokenCount = 0;
			_animationManager = new AnimationManager();
			
			// Set animation urls.
			var fandamoniumGameId:String = '69';
			var assetPath:String = Environment.getAssetUrl() + '/test/gameSwf/gameId/' + fandamoniumGameId + '/gameFile/';
			_playAnimationUrlArray[LiveGamePlayMLB.STRIKE] = assetPath + 'fan_strike_FP.swf';
			_playAnimationUrlArray[LiveGamePlayMLB.BALL] = assetPath + 'fan_ball_FP.swf';
			_playAnimationUrlArray[LiveGamePlayMLB.FOUL] = assetPath + 'fan_foulBall.swf';
			_playAnimationUrlArray[LiveGamePlayMLB.STRIKE_OUT] = assetPath + 'fan_strikeOut_FP.swf';
			_playAnimationUrlArray[LiveGamePlayMLB.WALK] = assetPath + 'fan_walk.swf';
			_playAnimationUrlArray[LiveGamePlayMLB.IN_PLAY_OUT] = assetPath + 'fan_out_FP.swf';
			_playAnimationUrlArray[LiveGamePlayMLB.OUT] = assetPath + 'fan_out_FP.swf';
			_playAnimationUrlArray[LiveGamePlayMLB.SINGLE] = assetPath + 'fan_single.swf';
			_playAnimationUrlArray[LiveGamePlayMLB.DOUBLE] = assetPath + 'fan_double.swf';
			_playAnimationUrlArray[LiveGamePlayMLB.TRIPLE] = assetPath + 'fan_triple.swf';
			_playAnimationUrlArray[LiveGamePlayMLB.HOME_RUN] = assetPath + 'fan_homeRun.swf';
			_playAnimationUrlArray[LiveGamePlayMLB.DOUBLE_PLAY] = assetPath + 'fan_doublePlay.swf';
			_playAnimationUrlArray[LiveGamePlayMLB.TRIPLE_PLAY] = assetPath + 'fan_triplePlay.swf';
			_playAnimationUrlArray[LiveGamePlayMLB.ERROR] = assetPath + 'fan_error.swf';
			_playAnimationUrlArray[LiveGamePlayMLB.RUN] = assetPath + 'fan_runScored5k_FP.swf';
			_playAnimationUrlArray[LiveGamePlayMLB.RUN_TWO] = assetPath + 'fan_runScored10k_FP.swf';
			_playAnimationUrlArray[LiveGamePlayMLB.RUN_THREE] = assetPath + 'fan_runScored15k_FP.swf';
			_playAnimationUrlArray[LiveGamePlayMLB.GRAND_SLAM] = assetPath + 'fan_grandslam.swf';
			
			// Set sound urls.
			_soundUrlArray[LiveGamePlayMLB.IN_PLAY_OUT] = assetPath + 'baseball_bat_crack.mp3';
			_soundUrlArray[LiveGamePlayMLB.SINGLE] = assetPath + 'baseball_bat_crack.mp3';
			_soundUrlArray[LiveGamePlayMLB.DOUBLE] = assetPath + 'baseball_bat_crack.mp3';
			_soundUrlArray[LiveGamePlayMLB.TRIPLE] = assetPath + 'baseball_bat_crack.mp3';
			_soundUrlArray[LiveGamePlayMLB.HOME_RUN] = assetPath + 'baseball_bat_crack.mp3';
			_soundUrlArray[LiveGamePlayMLB.FOUL] = assetPath + 'baseball_bat_crack.mp3';
			_soundUrlArray[LiveGamePlayMLB.STRIKE] = assetPath + 'strike_whoosh.mp3';
			_soundUrlArray[LiveGamePlayMLB.STRIKE_OUT] = assetPath + 'yer_out.mp3';
			_soundUrlArray[LiveGamePlayMLB.BALL] = assetPath + 'mitt_catch.mp3';
			_soundUrlArray[LiveGamePlayMLB.RUN] = assetPath + 'crowd_cheer_short.mp3';
			_soundUrlArray[LiveGamePlayMLB.RUN_TWO] = assetPath + 'crowd_cheer_short.mp3';
			_soundUrlArray[LiveGamePlayMLB.RUN_THREE] = assetPath + 'crowd_cheer_short.mp3';
			_soundUrlArray[LiveGamePlayMLB.GRAND_SLAM] = assetPath + 'crowd_cheer_short.mp3';
			_soundUrlArray[LiveGamePlayMLB.WALK] = assetPath + 'take_yer_base.mp3';
			_soundUrlArray[FandemoniumSoundType.FAN_POINT_PICKUP] = assetPath + 'item_pickup_4.mp3';
			_soundUrlArray[FandemoniumSoundType.FAN_POINT_STOLEN] = assetPath + 'fp_steal.mp3';
			_soundUrlArray[FandemoniumSoundType.MINI_GAME_START] = assetPath + 'airhorn.mp3';
			
			// Cheer game screen url.
			_cheerGameScreenUrl = assetPath + 'cheerGameScreen.swf';
			
			// Intro popup url.
			_introPopupUrl = assetPath + 'fandemoniumIntroScreen.swf';
			
			// Set urls for fan mania logos.
			_fanManiaLogoLeftUrl = assetPath + 'fanManiaLeft.swf';
			_fanManiaLogoRightUrl = assetPath + 'fanManiaRight.swf';
			
			// Set url for wave button.
			_waveButtonUrl = assetPath + 'fan_waveLauncher.swf';
			
			// Use timers to only show crowd animations for a pre-determined amount of time.
			_awayCrowdTimeout.addEventListener(TimerEvent.TIMER, onAwayCrowdTimeout);
			_homeCrowdTimeout.addEventListener(TimerEvent.TIMER, onHomeCrowdTimeout);
		}
		
		////////////////////
		// INSTANCE METHODS
		////////////////////
		
		public function getTeamLogoUrl(teamId:uint):String
		{
			return 'http://' + Environment.getAssetDomain() + '/test/static/clipart/teamLogoTemplate?teamId=' + teamId;
		}
		
		public function addFandamoniumPrize(prizeItem:FandamoniumPrizeItem):void
		{
			// Add a prize item to the room.
			
			// If the room hasn't recieved an initial enum refresh,
			// Add the prize to a que for addition at a later time.
			if (_initialRoomEnumRefresh != true)
			{
				_prizeQue.push(prizeItem);
			}
			else
			{
				// If the room has already recieved an initial enum refresh.
				// Add the prize.
				// Make sure a prize with the same instance id does not already exist.
				var currentItem:FandamoniumPrizeItem = _currentPrizeItems.getFromInstanceId(prizeItem.instanceId);
				if (currentItem == null)
				{
					_currentPrizeItems.push(prizeItem);
					_room.addItem(prizeItem);
				}
			}
		}
		
		public function removeFandamoniumPrize(prizeItem:FandamoniumPrizeItem):void
		{
			// Remove from current prize items.
			var prizeIndex:int = _currentPrizeItems.indexOf(prizeItem);
			if (prizeIndex > -1)
			{
				_currentPrizeItems.removeAt(prizeIndex);
				_room.removeItem(prizeItem);
			}
		}
		
		public function removeAllPrizes():void
		{
			var i:int = 0;
			var len:int = _currentPrizeItems.length;
			for (i; i < len; i++)
			{
				_room.removeItem(_currentPrizeItems.getAt(i));
			}
			
			_currentPrizeItems.empty();
		}
		
		public function getPlayAnimationUrl(playType:String):String
		{
			return (_playAnimationUrlArray[playType] != null) ? _playAnimationUrlArray[playType] : null;
		}
		
		public function getPlayAnimationStatus(playType:String):String
		{
			return (_playAnimationStatusArray[playType] != null) ? _playAnimationStatusArray[playType] : NONE_STATUS;
		}
		
		public function getPlayAnimation(playType:String):MovieClip
		{
			var playAnimation:MovieClip = (_playAnimationArray[playType] != null) ? _playAnimationArray[playType] as MovieClip : null;
			return playAnimation;
		}
		
		public function loadPlayAnimation(playType:String, completeCallback:Function, errorCallback:Function):void
		{
			// Load the animation for this play type.
			var url:String = getPlayAnimationUrl(playType);
			if (url == null) 
			{
				errorCallback(new Event(NO_URL_STATUS));
				return;
			}
			
			// Make sure we are not already loading or have already loaded this animation.
			var status:String = getPlayAnimationStatus(playType);
			if (status == COMPLETE_STATUS)
			{
				// This animation has already been loaded.
				completeCallback(new Event(COMPLETE_STATUS));
				return;
			}
			else if (status == LOADING_STATUS)
			{
				// We are already loading this animation.
				return;
			}
			else if (status == ERROR_STATUS)
			{
				// We already tried to load this animation and there was an error.
				errorCallback(new Event(ERROR_STATUS));
				return;
			}
			
			// Get ready to load this animation.
			var request:URLRequest = new URLRequest(url);
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
			// Set status for the animation.
			_playAnimationStatusArray[playType] = LOADING_STATUS;
			// Do the load.
			loader.load(request);
			
			function onComplete(e:Event):void
			{
				// Remove event listeners.
				loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onComplete);
				loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onError);
				
				// Set status for the animation.
				_playAnimationStatusArray[playType] = COMPLETE_STATUS;
				
				// Store a reference to the loaded animation.
				_playAnimationArray[playType] = loader.content as MovieClip;
				
				// Call complete function.
				completeCallback(new Event(COMPLETE_STATUS));
			}
			
			function onError(e:IOErrorEvent):void
			{
				// Remove event listeners.
				loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onComplete);
				loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onError);
				
				// Set status for the animation.
				_playAnimationStatusArray[playType] = ERROR_STATUS;
				
				// Call error function.
				errorCallback(new Event(ERROR_STATUS));
			}
		}
		
		private function getSoundUrl(type:String):String
		{
			return (_soundUrlArray[type] != null) ? _soundUrlArray[type] : null;
		}
		
		private function getSoundStatus(type:String):String
		{
			return (_soundStatusArray[type] != null) ? _soundStatusArray[type] : NONE_STATUS;
		}
		
		public function playSound(type:String):void
		{
			// Load the sound.
			var url:String = getSoundUrl(type);
			if (url == null) 
			{
				// Set status for the animation.
				_soundStatusArray[type] = NO_URL_STATUS;
				return;
			}
			
			// Make sure we are not already loading or have already loaded this sound.
			var status:String = getSoundStatus(type);
			if (status == COMPLETE_STATUS)
			{
				// This sound has already been loaded.
				// Play the sound.
				var sound:Sound = _soundArray[type] as Sound;
				if (sound != null) sound.play();
				return;
			}
			else if (status == LOADING_STATUS)
			{
				// We are already loading this sound.
				return;
			}
			else if (status == ERROR_STATUS)
			{
				// We already tried to load this sound and there was an error.
				return;
			}
			
			// Get ready to load this sound.
			var request:URLRequest = new URLRequest(url);
			var loader:Sound = new Sound();
			loader.addEventListener(Event.COMPLETE, onComplete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onError);
			// Set status for the sound.
			_soundStatusArray[type] = LOADING_STATUS;
			// Store a reference to the sound.
			_soundArray[type] = loader;
			// Do the load.
			loader.load(request);
			
			function onComplete(e:Event):void
			{
				// Remove event listeners.
				loader.removeEventListener(Event.COMPLETE, onComplete);
				loader.removeEventListener(IOErrorEvent.IO_ERROR, onError);
				
				// Set status for the sound.
				_soundStatusArray[type] = COMPLETE_STATUS;
				
				// Play the sound.
				loader.play();
			}
			
			function onError(e:IOErrorEvent):void
			{
				// Remove event listeners.
				loader.removeEventListener(Event.COMPLETE, onComplete);
				loader.removeEventListener(IOErrorEvent.IO_ERROR, onError);
				
				// Set status for the sound.
				_soundStatusArray[type] = ERROR_STATUS;
			}
		}
		
		public function createSirens():void
		{
			// Create sirens for both teams.
			
			var teamSirenPositions1:Array = [new Point(33, 101), new Point(81, 94), new Point(148, 86), new Point(195, 79)];
			var teamSirenPositions2:Array = [new Point(892, 101), new Point(850, 94), new Point(794, 86), new Point(744, 79)];
			
			// Get reference to background layer.
			var renderLayer:RenderLayer = backgroundLayer;
			
			var i:int = 0;
			var len:int = teamSirenPositions1.length;
			var siren:Siren;
			var pos:Point;
			var sirenRenderObject:RenderObject;
			for (i; i < len; i++)
			{
				pos = teamSirenPositions1[i];
				// Create siren display.
				siren = new Siren();
				siren.x = pos.x;
				siren.y = pos.y;
				_teamSirens1.push(siren);
				
				// Create render object.
				sirenRenderObject = new RenderObject(new RenderData(siren));
				
				// Add fan meter render object to the background layer.
				renderLayer.addItem(sirenRenderObject);
			}
			
			i = 0;
			len = teamSirenPositions2.length;
			for (i; i < len; i++)
			{
				pos = teamSirenPositions2[i];
				// Create siren display.
				siren = new Siren();
				siren.x = pos.x;
				siren.y = pos.y;
				_teamSirens2.push(siren);
				
				// Create render object.
				sirenRenderObject = new RenderObject(new RenderData(siren));
				
				// Add fan meter render object to the background layer.
				renderLayer.addItem(sirenRenderObject);
			}
			
			// Create all sirens array.
			_allTeamSirens = _teamSirens1.concat(_teamSirens2);
		}
		
		public function setSirenColors():void
		{
			var i:int = 0;
			var len:int = _teamSirens1.length;
			var siren:Siren;
			for (i; i < len; i++)
			{
				siren = _teamSirens1[i] as Siren;
				siren.color = _currentGame.awayTeam.color1;
			}
			
			i = 0;
			len = _teamSirens2.length;
			for (i; i < len; i++)
			{
				siren = _teamSirens2[i] as Siren;
				siren.color = _currentGame.homeTeam.color1;
			}
		}
		
		public function setSirenActive(isActive:Boolean):void
		{
			// Turn all sirens on or off.
			var i:int = 0;
			var len:int = _allTeamSirens.length;
			var siren:Siren;
			var setFunction:Function = (isActive == true) ? turnOn : turnOff;
			for (i; i < len; i++)
			{
				siren = _allTeamSirens[i] as Siren;
				setFunction(siren);
			}
			
			function turnOff(siren:Siren):void
			{
				siren.stopSiren();
			}
			
			function turnOn(siren:Siren):void
			{
				siren.startSiren();
			}
		}
		
		public function awayCrowdIdle():void
		{
			if (_awayCrowd != null) _awayCrowd.crowdState = 2;
		}
		
		public function awayCrowdCheer():void
		{
			if (_awayCrowd != null)
			{
				_awayCrowdTimeout.reset();
				_awayCrowd.crowdState = 0;
				_awayCrowdTimeout.start();
			}
		}
		
		public function awayCrowdBoo():void
		{
			if (_awayCrowd != null)
			{
				_awayCrowdTimeout.reset();
				_awayCrowd.crowdState = 1;
				_awayCrowdTimeout.start();
			}
		}
		
		public function homeCrowdIdle():void
		{
			if (_homeCrowd != null) _homeCrowd.crowdState = 2;
		}
		
		public function homeCrowdCheer():void
		{
			if (_homeCrowd != null)
			{
				_homeCrowdTimeout.reset();
				_homeCrowd.crowdState = 0;
				_homeCrowdTimeout.start();
			}
		}
		
		public function homeCrowdBoo():void
		{
			if (_homeCrowd != null)
			{
				_homeCrowdTimeout.reset();
				_homeCrowd.crowdState = 1;
				_homeCrowdTimeout.start();
			}
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		public function get roomController():RoomController
		{
			return _roomController;
		}
		
		public function get userTeamSelected():Boolean
		{
			return _userTeamSelected;
		}
		
		public function get selectedTeamId():uint
		{
			return _selectedTeamId;
		}
		public function set selectedTeamId(value:uint):void
		{
			if (value == _selectedTeamId) return;
			_selectedTeamId = value;
			_userTeamSelected = true;
		}
		
		public function get room():Room
		{
			return _room;
		}
		public function set room(value:Room):void
		{
			if (value == _room) return;
			
			// Set new room.
			_room = value;
			
			// Reset some values.
			_initialRoomEnumRefresh = false;
			
			// Listen for enumeration refresh.
			_room.addEventListener(RoomEnumEvent.ENUM_REFRESH, onRoomEnumRefresh);
		}
		
		public function get homeTeamScore():int
		{
			return _homeTeamScore;
		}
		public function set homeTeamScore(value:int):void
		{
			_homeTeamScore = value;
		}
		
		public function get awayTeamScore():int
		{
			return _awayTeamScore;
		}
		public function set awayTeamScore(value:int):void
		{
			_awayTeamScore = value;
		}
		
		public function get homeTeamFanScore():int
		{
			return _homeTeamFanScore;
		}
		public function set homeTeamFanScore(value:int):void
		{
			_homeTeamFanScore = value;
		}
		
		public function get awayTeamFanScore():int
		{
			return _awayTeamFanScore;
		}
		public function set awayTeamFanScore(value:int):void
		{
			_awayTeamFanScore = value;
		}
		
		public function get userAvatar():Avatar
		{
			return _userAvatar;
		}
		
		public function get userAvatarController():AvatarController
		{
			return _userAvatarController;
		}
		
		public function get gameCastController():GameCastController
		{
			return _gameCastController;
		}
		
		public function get currentGame():LiveGame
		{
			return _currentGame;
		}
		public function set currentGame(value:LiveGame):void
		{
			if (value == _currentGame) return;
			_currentGame = value;
			
			// Reset some values.
			_awayTeamFanScore = 0;
			_homeTeamFanScore = 0;
			_selectedTeamId = 0;
			_userTeamSelected = false;
			_introHasBeenShown = false;
			_userInitialTokenCount = _userAvatar.currency;
		}
		
		public function get backgroundLayer():RenderLayer
		{
			return _roomController.roomView.getRenderLayer(RoomLayerType.BACKGROUND);
		}
		
		public function get foregroundLayer():RenderLayer
		{
			return _roomController.roomView.getRenderLayer(RoomLayerType.FOREGROUND);
		}
		
		public function get currentPrizes():FandamoniumPrizeItemCollection
		{
			return _currentPrizeItems;
		}
		
		public function get endGameScreenHomeLogo():DisplayObject
		{
			return _endGameScreenHomeLogo;
		}
		
		public function set endGameScreenHomeLogo(value:DisplayObject):void
		{
			_endGameScreenHomeLogo = value;
		}
		
		public function get endGameScreenAwayLogo():DisplayObject
		{
			return _endGameScreenAwayLogo;
		}
		
		public function set endGameScreenAwayLogo(value:DisplayObject):void
		{
			_endGameScreenAwayLogo = value;
		}
		
		public function get cheerGameScreenUrl():String
		{
			return _cheerGameScreenUrl;
		}
		
		public function get teamSelectLogo1():DisplayObject
		{
			return _teamSelectLogo1;
		}
		public function set teamSelectLogo1(value:DisplayObject):void
		{
			_teamSelectLogo1 = value;
		}
		
		public function get teamSelectLogo2():DisplayObject
		{
			return _teamSelectLogo2;
		}
		public function set teamSelectLogo2(value:DisplayObject):void
		{
			_teamSelectLogo2 = value;
		}
		
		public function get lastPlay():LiveGamePlayMLB
		{
			return _lastPlay;
		}
		public function set lastPlay(value:LiveGamePlayMLB):void
		{
			_lastPlay = value;
		}
		
		public function get awayCrowd():FandemoniumLeftCrowd
		{
			return _awayCrowd;
		}
		public function set awayCrowd(value:FandemoniumLeftCrowd):void
		{
			_awayCrowd = value;
		}
		
		public function get homeCrowd():FandemoniumRightCrowd
		{
			return _homeCrowd;
		}
		public function set homeCrowd(value:FandemoniumRightCrowd):void
		{
			_homeCrowd = value;
		}
		
		public function get introHasBeenShown():Boolean
		{
			return _introHasBeenShown;
		}
		public function set introHasBeenShown(value:Boolean):void
		{
			_introHasBeenShown = value;
		}
		
		public function get introPopupUrl():String
		{
			return _introPopupUrl;
		}
		
		public function get animationManager():AnimationManager
		{
			return _animationManager;
		}
		
		public function get fanManiaLogoLeftUrl():String
		{
			return _fanManiaLogoLeftUrl;
		}
		
		public function get fanManiaLogoRightUrl():String
		{
			return _fanManiaLogoRightUrl;
		}
		
		public function get waveButtonUrl():String
		{
			return _waveButtonUrl;
		}
		
		public function get userTokensEarnedThisGame():uint
		{
			return _userAvatar.currency - _userInitialTokenCount;
		}
		
		////////////////////
		// EVENT HANDLERS
		////////////////////
		
		private function onRoomEnumRefresh(e:RoomEnumEvent):void
		{
			// Remove event listener.
			_room.removeEventListener(RoomEnumEvent.ENUM_REFRESH, onRoomEnumRefresh);
			
			_initialRoomEnumRefresh = true;
			
			// If there are any prize items in que to be added, add them now.
			var i:int = 0;
			var len:int = _prizeQue.length;
			for (i; i < len; i++)
			{
				addFandamoniumPrize(_prizeQue.getAt(i));
			}
			
			// Clear the prize que.
			_prizeQue.empty();
		}
		
		private function onAwayCrowdTimeout(e:TimerEvent):void
		{
			// Reset the timer.
			_awayCrowdTimeout.reset();
			
			// Send the crowd to the idle state.
			awayCrowdIdle();
		}
		
		private function onHomeCrowdTimeout(e:TimerEvent):void
		{
			// Reset the timer.
			_homeCrowdTimeout.reset();
			
			// Send the crowd to the idle state.
			homeCrowdIdle();
		}
		
	}
}