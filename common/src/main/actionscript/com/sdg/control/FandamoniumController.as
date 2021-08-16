package com.sdg.control
{
	import com.boostworthy.animation.easing.Transitions;
	import com.boostworthy.animation.rendering.RenderMethod;
	import com.sdg.control.room.RoomManager;
	import com.sdg.control.room.itemClasses.RoomEntity;
	import com.sdg.display.IRoomItemDisplay;
	import com.sdg.display.render.RenderData;
	import com.sdg.display.render.RenderLayer;
	import com.sdg.display.render.RenderObject;
	import com.sdg.events.GameCastEvent;
	import com.sdg.events.RoomItemDisplayEvent;
	import com.sdg.events.SimEvent;
	import com.sdg.events.SocketEvent;
	import com.sdg.model.Avatar;
	import com.sdg.model.FandamoniumEndGameData;
	import com.sdg.model.FandamoniumModel;
	import com.sdg.model.FandamoniumPrizeItem;
	import com.sdg.model.FandamoniumPrizeItemCollection;
	import com.sdg.model.FandemoniumMiniGame;
	import com.sdg.model.FandemoniumSoundType;
	import com.sdg.model.LiveGame;
	import com.sdg.model.LiveGamePlayMLB;
	import com.sdg.model.LiveGameTeam;
	import com.sdg.model.PrizeItem;
	import com.sdg.model.RoomLayerType;
	import com.sdg.model.SdgItem;
	import com.sdg.model.SdgItemAssetType;
	import com.sdg.net.socket.SocketClient;
	import com.sdg.swf.fandemonium.FandemoniumEndGame;
	import com.sdg.swf.fandemonium.FandemoniumInstructionScreen;
	import com.sdg.swf.fandemonium.FandemoniumLeftCrowd;
	import com.sdg.swf.fandemonium.FandemoniumRightCrowd;
	import com.sdg.view.FieldCastDisplayMLB;
	import com.sdg.view.FramerateDebugView;
	import com.sdg.view.IRoomView;
	import com.sdg.view.fandamonium.FandamoniumMeter;
	import com.sdg.view.fandamonium.OutfieldWalls;
	
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.TimerEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Point;
	import flash.net.URLRequest;
	import flash.utils.Timer;

	public class FandamoniumController extends EventDispatcher implements IDynamicController
	{
		public static const FRAMERATE_DEBUG:Boolean = false;
		
		private var _model:FandamoniumModel;
		private var _recievedInitialPrizeState:Boolean;
		private var _initialRoomEnumRefresh:Boolean;
		private var _fieldGameCastDisplay:FieldCastDisplayMLB;
		private var _scoreBoardDisplay:MLBScoreBoard;
		private var _teamSelectDialog:FandamoniumTeamSelect;
		private var _fieldCastRenderObject:RenderObject;
		private var _gamePreparedFlags:Array;
		private var _fanMeterDisplay:FandamoniumMeter;
		private var _fanMeterRenderObject:RenderObject;
		private var _outfieldWallsDisplay:OutfieldWalls;
		private var _outfieldWallsRenderObject:RenderObject;
		private var _screenContentContainer:Sprite;
		private var _screenContainerRenderObject:RenderObject;
		private var _screenContentMask:Sprite;
		private var _currentScreenContent:DisplayObject;
		private var _endGameScreens:FandemoniumEndGame;
		private var _canonDisplay:FandemoniumCannon;
		private var _canonRenderObject:RenderObject;
		private var _teamSelectShown:Boolean;
		private var _miniGameIsActiveFlags:Array;
		private var _isScreenOverride:Boolean;
		private var _instructionScreen:Sprite;
		private var _isCanonShootInProgress:Boolean;
		private var _introDisplay:Sprite;
		private var _introIsShown:Boolean;
		private var _waveButtonDisplay:DisplayObject;
		private var _waveButtonVisible:Boolean;
		private var _waveButtonContainer:Sprite;
		
		public function FandamoniumController(model:FandamoniumModel)
		{
			super();
			
			_model = model;
			
			// Default values.
			_recievedInitialPrizeState = false;
			_initialRoomEnumRefresh = false;
			_gamePreparedFlags = [];
			_teamSelectShown = false;
			_miniGameIsActiveFlags = [];
			_instructionScreen = new FandemoniumInstructionScreen();
			_isCanonShootInProgress = false;
			_introIsShown = false;
			_waveButtonVisible = false;
		}
		
		////////////////////
		// INSTANCE METHODS
		////////////////////
		
		public function init():void
		{
			// Create canon.
			createCanon();
			
			// Create the gamecast field display.
			createFieldGamecastDisplay();
			
			// Create crowds.
			createCrowds();
			
			// Create outfield walls.
			createOutfieldWalls();
			
			// Create score board.
			createScoreBoardDisplay();
			
			// Create fan mania logos.
			createFanManiaLogos();
			
			// Create fan meter.
			createFanMeter();
			
			// Create mini-game sirens.
			//_model.createSirens();
			
			// Create framerate debug display.
			if (FRAMERATE_DEBUG == true) createFrameRateDebugDisplay();
			
			// Listen for socket plugin events.
			SocketClient.getInstance().addEventListener(SocketEvent.PLUGIN_EVENT, onSocketPluginEvent);
			
			// Listen for when the user avatar moves.
			_model.userAvatar.entity.data.addEventListener(SimEvent.MOVED, onUserAvatarMove);
			
			// Request for initial prize state.
			RoomManager.getInstance().socketMethods.sendEnumMessage('prizeState');
			
			// Request for fandemonium score.
			RoomManager.getInstance().socketMethods.sendEnumMessage('fandimoniumScore');
			
			_model.gameCastController.addEventListener(GameCastEvent.END_GAME_EVENT, onEndGameEvent);
			_model.gameCastController.addEventListener(GameCastEvent.START_GAME_EVENT, onStartGameEvent);
			
			// If there is a current game, prepare it.
			var currentGame:LiveGame = _model.gameCastController.getCurrentGame();
			if (currentGame != null)
			{
				_model.currentGame = currentGame;
				prepareCurrentGame();
			}
			else
			{
				// Listen for new game events.
				_model.gameCastController.addEventListener(GameCastEvent.NEW_GAME_EVENT, onNewGame);
			}
		}
		
		public function destroy():void
		{
			// Remove event listeners.
			SocketClient.getInstance().removeEventListener(SocketEvent.PLUGIN_EVENT, onSocketPluginEvent);
			_model.userAvatar.entity.data.removeEventListener(SimEvent.MOVED, onUserAvatarMove);
			if (_waveButtonDisplay != null) _waveButtonDisplay.removeEventListener('click', onWaveClick);
			
			// Remove gamecast listener.
			if (_model.currentGame != null)
			{
				_model.gameCastController.removeGameCastListener(_model.currentGame.id, onGamePlayEvent);
			}
			
			_model.gameCastController.removeEventListener(GameCastEvent.END_GAME_EVENT, onEndGameEvent);
			_model.gameCastController.removeEventListener(GameCastEvent.START_GAME_EVENT, onStartGameEvent);
			
			// Remove the users floor marker.
			_model.userAvatar.display.floorMarker = null;
			
			// Remove field cast render object from the background layer.
			var backgroundRenderLayer:RenderLayer = _model.backgroundLayer;
			backgroundRenderLayer.removeItem(_fieldCastRenderObject);
			// Remove score board.
			backgroundRenderLayer.removeItem(_screenContainerRenderObject);
			// Remove outfield walls.
			backgroundRenderLayer.removeItem(_outfieldWallsRenderObject);
			// Remove fan meter.
			var foregroundRenderLayer:RenderLayer = _model.foregroundLayer;
			foregroundRenderLayer.removeItem(_fanMeterRenderObject);
			
			// Make sure the team select dialog is destroyed.
			if (_teamSelectShown == true && _teamSelectDialog != null)
			{
				_model.roomController.roomView.removePopUp(_teamSelectDialog);
				_teamSelectDialog.destroy();
			}
		}
		
		private function createFieldGamecastDisplay():void
		{
			// Create the gamecast field display.
			_fieldGameCastDisplay = new FieldCastDisplayMLB();
			
			// Create render object.
			_fieldCastRenderObject = new RenderObject(new RenderData(_fieldGameCastDisplay));
			
			// Get reference to background layer.
			var renderLayer:RenderLayer = _model.backgroundLayer;
			
			// Add field cast render object to the background layer.
			renderLayer.addItem(_fieldCastRenderObject);
		}
		
		private function createOutfieldWalls():void
		{
			// Create the display.
			_outfieldWallsDisplay = new OutfieldWalls();
			_outfieldWallsDisplay.setAwayTeamWallPoints(new Point(0, 121), new Point(242, 84), new Point(0, 206), new Point(242, 158));
			_outfieldWallsDisplay.setHomeTeamWallPoints(new Point(675, 84), new Point(925, 121), new Point(675, 159), new Point(925, 209));
			
			// Create render object.
			_outfieldWallsRenderObject = new RenderObject(new RenderData(_outfieldWallsDisplay));
			
			// Get reference to background layer.
			var renderLayer:RenderLayer = _model.backgroundLayer;
			
			// Add render object to the background layer.
			renderLayer.addItem(_outfieldWallsRenderObject);
		}
		
		private function createScoreBoardDisplay():void
		{
			// Create display object.
			_screenContentContainer = new Sprite();
			
			// Create render object.
			_screenContainerRenderObject = new RenderObject(new RenderData(_screenContentContainer));
			
			// Get reference to background layer.
			var renderLayer:RenderLayer = _model.backgroundLayer;
			
			// Add screen container render object to the background layer.
			renderLayer.addItem(_screenContainerRenderObject);
			
			// Position the score board.
			_screenContentContainer.x = renderLayer.width / 2 - 2;
			
			// Create content mask.
			_screenContentMask = new Sprite();
			_screenContentMask.graphics.beginFill(0x00ff00);
			_screenContentMask.graphics.drawRect(0, 0, 400, 153);
			_screenContentMask.x = -_screenContentMask.width / 2;
			_screenContentContainer.addChild(_screenContentMask);
			
			// Create the scoreboard
			_scoreBoardDisplay = new MLBScoreBoard();
			
			// Add the scoreboard to the container
			setScreenContent(_scoreBoardDisplay);
		}
		
		private function createFanManiaLogos():void
		{
			// Load the fan mania logos and place them.
			var requestLeft:URLRequest = new URLRequest(_model.fanManiaLogoLeftUrl);
			var requestRight:URLRequest = new URLRequest(_model.fanManiaLogoRightUrl);
			var loaderLeft:Loader = new Loader();
			loaderLeft.contentLoaderInfo.addEventListener(Event.COMPLETE, onLeftComplete);
			loaderLeft.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLeftError);
			var loaderRight:Loader = new Loader();
			loaderRight.contentLoaderInfo.addEventListener(Event.COMPLETE, onRightComplete);
			loaderRight.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onRightError);
			loaderLeft.load(requestLeft);
			loaderRight.load(requestRight);
			
			function onLeftComplete(e:Event):void
			{
				// Remove listeners.
				loaderLeft.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLeftComplete);
				loaderLeft.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onLeftError);
				
				var leftLogo:DisplayObject = loaderLeft.content;
				leftLogo.x = 44;
				leftLogo.y = 78;
				_model.backgroundLayer.addItem(new RenderObject(new RenderData(leftLogo)));
			}
			
			function onRightComplete(e:Event):void
			{
				// Remove listeners.
				loaderRight.contentLoaderInfo.removeEventListener(Event.COMPLETE, onRightComplete);
				loaderRight.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onRightError);
				
				var rightLogo:DisplayObject = loaderRight.content;
				rightLogo.x = 731;
				rightLogo.y = 74;
				_model.backgroundLayer.addItem(new RenderObject(new RenderData(rightLogo)));
			}
			
			function onLeftError(e:IOErrorEvent):void
			{
				// Remove listeners.
				loaderLeft.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLeftComplete);
				loaderLeft.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onLeftError);
			}
			
			function onRightError(e:IOErrorEvent):void
			{
				// Remove listeners.
				loaderRight.contentLoaderInfo.removeEventListener(Event.COMPLETE, onRightComplete);
				loaderRight.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onRightError);
			}
		}
		
		private function createFanMeter():void
		{
			// Create the meter display.
			_fanMeterDisplay = new FandamoniumMeter();
			
			// Create render object.
			_fanMeterRenderObject = new RenderObject(new RenderData(_fanMeterDisplay));
			
			// Get reference to foreground layer.
			var renderLayer:RenderLayer = _model.foregroundLayer;
			
			// Add the wave button container.
			_waveButtonContainer = new Sprite();
			renderLayer.addItem(new RenderObject(new RenderData(_waveButtonContainer)));
			
			// Add fan meter render object to the background layer.
			renderLayer.addItem(_fanMeterRenderObject);
			
			// Position the fan meter.
			_fanMeterDisplay.y = _model.roomController.roomView.height - _fanMeterDisplay.height - 45;
			
			// Load the wave button.
			var url:String = _model.waveButtonUrl;
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
				
				// Set reference to display.
				_waveButtonDisplay = loader.content;
				
				// Listen for clicks.
				_waveButtonDisplay.addEventListener('click', onWaveClick);
				
				// Add the button.
				_waveButtonContainer.addChild(_waveButtonDisplay);
				
				// Position the button.
				_waveButtonDisplay.x = renderLayer.width / 2 - _waveButtonDisplay.width / 2 + 13;
				_waveButtonDisplay.y = renderLayer.height;
				
				// Check if the button should be shown.
				if (_waveButtonVisible == true) showWaveButton();
			}
			
			function onError(e:IOErrorEvent):void
			{
				// Remove listeners.
				loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onComplete);
				loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onError);
			}
		}
		
		private function createCanon():void
		{
			// Create the canon display.
			_canonDisplay = new FandemoniumCannon();
			
			// Create render object.
			_canonRenderObject = new RenderObject(new RenderData(_canonDisplay));
			
			// Get reference to background layer.
			var renderLayer:RenderLayer = _model.backgroundLayer;
			
			// Add fan meter render object to the background layer.
			renderLayer.addItem(_canonRenderObject);
			
			// Position canon.
			_canonDisplay.x = 555;
			_canonDisplay.y = 325;
		}
		
		private function createCrowds():void
		{
			// Create crowd displays.
			_model.awayCrowd = new FandemoniumLeftCrowd();
			_model.homeCrowd = new FandemoniumRightCrowd();
			
			// Create render objects for the crowds.
			var leftRenderObj:RenderObject = new RenderObject(new RenderData(_model.awayCrowd));
			var rightRenderObj:RenderObject = new RenderObject(new RenderData(_model.homeCrowd));
			
			// Get reference to background layer.
			var renderLayer:RenderLayer = _model.backgroundLayer;
			
			// Add the crowd displays to the background layer.
			renderLayer.addItem(leftRenderObj);
			renderLayer.addItem(rightRenderObj);
			
			// Position the crowds.
			_model.awayCrowd.x = 0;
			_model.awayCrowd.y = 0;
			_model.homeCrowd.x = 690;
			_model.homeCrowd.y = 0;
			
		}
		
		private function createFrameRateDebugDisplay():void
		{
			var debugDisplay:FramerateDebugView = new FramerateDebugView();
			
			var rO:RenderObject = new RenderObject(new RenderData(debugDisplay));
			
			// Get reference to foreground layer.
			var renderLayer:RenderLayer = _model.foregroundLayer;
			
			renderLayer.addItem(rO);
			
			debugDisplay.x = 40;
			debugDisplay.y = 40;
		}
		
		private function handlePrizeState(prizeStateParams:Object):void
		{
			_recievedInitialPrizeState = true;
			
			// Generate prizes from the data.
			// Create the "newPrizeState" collection that represents the new prize state from the server.
			// Then compare this to the "currentPrizeState" collection in the model to create 2 more collections.
			// "prizesToAdd" collection is of new prizes that need to be added to the current collection.
			// "prizesToRemove" collection is of prizes that need to be removed from the current collection.
			var prizeState:String = (prizeStateParams.prizeState != null) ? prizeStateParams.prizeState : '';
			var prizeStringArray:Array = prizeState.split(';');
			var currentPrizeState:FandamoniumPrizeItemCollection = _model.currentPrizes;
			var newPrizeState:FandamoniumPrizeItemCollection = new FandamoniumPrizeItemCollection();
			var prizesToAdd:FandamoniumPrizeItemCollection = new FandamoniumPrizeItemCollection();
			var prizesToRemove:FandamoniumPrizeItemCollection = new FandamoniumPrizeItemCollection();
			var i:int = 0;
			var len:int = prizeStringArray.length;
			for (i; i < len; i++)
			{
				// Extract a prize item from a string.
				var prizeString:String = prizeStringArray[i] as String;
				if (prizeString.length < 1) continue;
				var prizeItem:FandamoniumPrizeItem = makeItemFromPrizeString(prizeString);
				if (prizeItem == null) continue;
				
				// Keep a collection of new prize state from the server.
				newPrizeState.push(prizeItem);
				
				// If this prize is not already a current prize, then it is a prize we need to add.
				var currentPrize:PrizeItem = currentPrizeState.getFromInstanceId(prizeItem.instanceId);
				if (currentPrize == null) prizesToAdd.push(prizeItem);
			}
			
			// Determine which prizes should be removed.
			i = 0;
			len = currentPrizeState.length;
			for (i; i < len; i++)
			{
				if (newPrizeState.getFromInstanceId(currentPrizeState.getAt(i).instanceId) == null) prizesToRemove.push(currentPrizeState.getAt(i));
			}
			
			// Remove the prizes that should not be in the room.
			i = 0;
			len = prizesToRemove.length;
			for (i; i < len; i++)
			{
				_model.removeFandamoniumPrize(prizesToRemove.getAt(i));
			}
			
			// If there are prizes to add, shoot the canon.
			_canonDisplay.onShoot = onShoot;
			if (prizesToAdd.length > 0) _canonDisplay.shootCanon();
			
			function onShoot():void
			{
				// Add prizes that need to be added.
				i = 0;
				len = prizesToAdd.length;
				for (i; i < len; i++)
				{
					_model.addFandamoniumPrize(prizesToAdd.getAt(i));
				}
				
				// Use a timer to separte the spawn time of each prize.
				/*i = 0;
				len = prizesToAdd.length;
				trace('Prizes To Add Length: ' + len);
				var spawnTimer:Timer = new Timer(50);
				spawnTimer.addEventListener(TimerEvent.TIMER, onTimer);
				spawnTimer.start();
				
				function onTimer(e:TimerEvent):void
				{
					if (i >= len)
					{
						// Kill timer.
						spawnTimer.removeEventListener(TimerEvent.TIMER, onTimer);
						spawnTimer.reset();
						return;
					}
					
					_model.addFandamoniumPrize(prizesToAdd.getAt(i));
					
					i++;
				}*/
			}
		}
		
		private function handlePrizeSpawn(prizeSpawnParams:Object):void
		{
			// Recieved message from server to spawn a new prize/prizes.
			// Parse the message and spawn prizes.
			var prizeSpawnString:String = (prizeSpawnParams.prizeSpawn != null) ? prizeSpawnParams.prizeSpawn : '';
			var prizeStringArray:Array = prizeSpawnString.split(';');
			var i:int = 0;
			var len:int = prizeStringArray.length;
			var prizeItem:FandamoniumPrizeItem;
			for (i; i < len; i++)
			{
				// Generate prize item object from string.
				var prizeString:String = prizeStringArray[i] as String;
				if (prizeString.length < 1) continue;
				prizeItem = makeItemFromPrizeString(prizeString);
				
				// Add the prize.
				if (prizeItem != null) _model.addFandamoniumPrize(prizeItem);
			}
		}
		
		private function handlePrizeAwarded(prizeAwardedParams:Object):void
		{
			// Determine the instance id for the prize that was awarded.
			var i:int = 0;
			var prizeAwardedString:String = (prizeAwardedParams.prizeAwarded != null) ? prizeAwardedParams.prizeAwarded : null;
			if (prizeAwardedString == null) return;
			var xml:XML = new XML(prizeAwardedString);
			var avatarId:int = (xml.avatarId) ? xml.avatarId : -1;
			var instanceId:int = (xml.instanceId) ? xml.instanceId : -1;
			if (instanceId < 0) return;
			
			// Remove the awarded prize.
			var prizeItem:FandamoniumPrizeItem = _model.currentPrizes.getFromInstanceId(instanceId);
			if (prizeItem == null) return;
			_model.removeFandamoniumPrize(prizeItem);
			
			// If the prize was awarded to you. Show an overhead message.
			if (avatarId == _model.userAvatar.id)
			{
				// Determine if this prize was for your team, or the other team, or just a general prize.
				var prizeTeam:LiveGameTeam = getTeamFromCurrentGameUsingId(prizeItem.teamId);
				var yourTeam:LiveGameTeam = getTeamFromCurrentGameUsingId(_model.selectedTeamId);
				var strokeColor:uint = 0x003399;
				var message:String = "+ " + prizeItem.value;
				if (yourTeam != null && prizeTeam == yourTeam)
				{
					// The prize was for your team.
					strokeColor = yourTeam.color1;
					
					// Play an item pickup sound.
					_model.playSound(FandemoniumSoundType.FAN_POINT_PICKUP);
				}
				else if (prizeTeam != null)
				{
					// The prize was for the other team.
					strokeColor = yourTeam.color1;
					message = prizeItem.value + ' stolen';
					
					// Play an item stolen sound.
					_model.playSound(FandemoniumSoundType.FAN_POINT_PICKUP);
				}
				else
				{
					// The prize was not for any specific team.
					strokeColor = yourTeam.color1;
					
					// Play an item pickup sound.
					_model.playSound(FandemoniumSoundType.FAN_POINT_PICKUP);
				}
				
				_model.userAvatarController.showOverheadMessage(message, strokeColor);
			}
			else
			{
				// The prize was not awarded to you.
				// Play an item pickup sound.
				_model.playSound(FandemoniumSoundType.FAN_POINT_PICKUP);
			}
		}
		
		private function handleFandamoniumScore(scoreParams:Object):void
		{
			// Parse fan scores from a string in the parameters.
			// Set the values on the model.
			var eventId:String = scoreParams.eventId;
			var scoreString:String = scoreParams.fandimoniumScore;
			var scoreArray:Array = scoreString.split(';', 2);
			var score1:int = scoreArray[0];
			var score2:int = scoreArray[1];
			_model.homeTeamFanScore = score1;
			_model.awayTeamFanScore = score2;
			
			// Set the score on the fan meter.
			_fanMeterDisplay.setScore(_model.awayTeamFanScore, _model.homeTeamFanScore);
		}
		
		private function handleMiniGameStarted(params:Object):void
		{
			var gameTypeString:String = (params.miniGameStarted != null) ? params.miniGameStarted : null;
			
			setMiniGameActive(gameTypeString, true);
			
			// Play the mini game start sound.
			_model.playSound(FandemoniumSoundType.MINI_GAME_START);
		}
		
		private function handleMiniGameEnded(params:Object):void
		{
			var gameTypeString:String = (params.miniGameEnded != null) ? params.miniGameEnded : null;
			
			setMiniGameActive(gameTypeString, false);
		}
		
		private function setMiniGameActive(miniGameType:String, isActive:Boolean):void
		{
			_miniGameIsActiveFlags[miniGameType] = isActive;
			
			switch (miniGameType)
			{
				case FandemoniumMiniGame.CHEER_GAME :
					handleCheerGame(isActive);
					break;
			}
		}
		
		private function handleCheerGame(isActive:Boolean):void
		{
			_model.setSirenActive(isActive);
			
			var loader:Loader;
			
			if (isActive)
			{
				// Load cheer game screen.
				var request:URLRequest = new URLRequest(_model.cheerGameScreenUrl);
				loader = new Loader();
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
				loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
				loader.load(request);
				
				// Show the wave action button.
				showWaveButton();
			}
			else
			{
				// Show the scoreboard.
				releaseScreenContentOverride();
				if (_model.currentGame.isGameStarted == true && _model.currentGame.isGameOver == false) setScreenContent(_scoreBoardDisplay);
				
				// Hide the wave action button.
				hideWaveButton();
			}
			
			function onComplete(e:Event):void
			{
				// Remove event listeners.
				loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onComplete);
				loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onError);
				
				// Show the cheer game screen.
				overrideScreenContent(loader.content);
			}
			
			function onError(e:IOErrorEvent):void
			{
				// Remove event listeners.
				loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onComplete);
				loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onError);
			}
		}
		
		private function makeItemFromPrizeString(prizeString:String):FandamoniumPrizeItem
		{
			// Get prize parameters from the prize string.
			var prizeParamsArray:Array = prizeString.split(',', 6);
			var typeId:int = (prizeParamsArray[0] != null) ? prizeParamsArray[0] : -1;
			var value:int = (prizeParamsArray[1] != null) ? prizeParamsArray[1] : -1;
			var instanceId:int = (prizeParamsArray[2] != null) ? prizeParamsArray[2] : -1;
			var x:int = (prizeParamsArray[3] != null) ? prizeParamsArray[3] : 0;
			var y:int = (prizeParamsArray[4] != null) ? prizeParamsArray[4] : 0;
			// Aux is an unknown set of key/value pairs for an item.
			var aux:String = (prizeParamsArray[5] != null) ? prizeParamsArray[5] : '';
			var keyValueArray:Array = aux.split('~');
			
			// Parse out auxilary attributes.
			var i:int = 0;
			var len:int = keyValueArray.length;
			var teamId:int = -1;
			var itemTeam:LiveGameTeam;
			for (i; i < len; i++)
			{
				var keyValuePair:Array = String(keyValueArray[i]).split('=', 2);
				var key:String = keyValuePair[0] as String;
				var keyValue:String = keyValuePair[1] as String;
				
				// Look for 'tmId' (teamId).
				if (key == 'tmId')
				{
					teamId = int(keyValue);
				}
			}
			
			if (instanceId < 0) return null;
			
			// Create the item using the parameters.
			var item:FandamoniumPrizeItem = new FandamoniumPrizeItem(instanceId);
			item.itemId = 4243;
			item.numLayers = 1;
			item.layerType = RoomLayerType.FLOOR;
			item.assetType = SdgItemAssetType.SWF;
			item.spriteTemplateId = 19;
			item.x = x;
			item.y = y;
			item.entity.solidity = 0;
			item.value = value;
			item.teamId = int(teamId);
			
			// Listen for when the item's display has been set.
			item.addEventListener(SdgItem.DISPLAY_SET, onItemDisplaySet);
			
			return item;
			
			function onItemDisplaySet(e:Event):void
			{
				// Now that the display has been set.
				// Remove the event listener.
				item.removeEventListener(SdgItem.DISPLAY_SET, onItemDisplaySet);
				
				// Set properties of the display.
				item.display.mouseEnabled = false;
				
				// If we have a teamId for this item,
				// Try to set the color of the item as the team color.
				itemTeam = getTeamFromCurrentGameUsingId(teamId);
				if (itemTeam == null) return;
				
				// See if we can reference the display SWF so that we can set color.
				if (item.display.content == null)
				{
					// We can't reference the SWF yet, so lets listen for when we can.
					item.display.addEventListener(RoomItemDisplayEvent.CONTENT, onContentSet);
				}
				else
				{
					// Set the color.
					var itemSWF:Object = item.display.content as Object;
					if (itemSWF.pointColor) itemSWF.pointColor = itemTeam.color1;
				}
			}
			
			function onContentSet(e:RoomItemDisplayEvent):void
			{
				// Get reference to item display.
				var itemDisplay:IRoomItemDisplay = e.currentTarget as IRoomItemDisplay;
				if (itemDisplay == null) return;
				
				// Remove listener.
				itemDisplay.removeEventListener(RoomItemDisplayEvent.CONTENT, onContentSet);
				
				// Try to set color.
				if (itemTeam == null) return;
				var itemSWF:Object = itemDisplay.content as Object;
				if (itemSWF.pointColor != null) itemSWF.pointColor = itemTeam.color1;
			}
		}
		
		private function showTeamSelect():void
		{
			// If team select is already shown, don't do anything.
			if (_teamSelectShown == true) return;
			
			// Set flag.
			_teamSelectShown = true;
			
			// Show the team select dialog.
			
			// Create reference to room view.
			var roomView:IRoomView = _model.roomController.roomView;
			
			// Get reference to current game.
			var currentGame:LiveGame = _model.currentGame;
			
			// Create the team select dialog instance.
			_teamSelectDialog = new FandamoniumTeamSelect();
			
			// Give the display a drop shadow.
			_teamSelectDialog.filters = [new DropShadowFilter(4, 45, 0, 1, 24, 24)];
			
			// Set properties of the dialog.
			if (_model.teamSelectLogo1 != null) _teamSelectDialog.teamLogo1 = _model.teamSelectLogo1;
			if (_model.teamSelectLogo2 != null) _teamSelectDialog.teamLogo2 = _model.teamSelectLogo2;
			_teamSelectDialog.onTeamClick1 = teamSelect1;
			_teamSelectDialog.onTeamClick2 = teamSelect2;
			
			// Set team names.
			_teamSelectDialog.teamName1 = currentGame.awayTeam.shortName;
			_teamSelectDialog.teamName2 = currentGame.homeTeam.shortName;
			
			// Set team colors.
			_teamSelectDialog.teamColor1 = currentGame.awayTeam.color1;
			_teamSelectDialog.teamColor2 = currentGame.homeTeam.color1;
			
			// Set the alpha to 0 so we can fade it in.
			_teamSelectDialog.alpha = 0;
			
			// Show and center the dialog box.
			roomView.addPopUp(_teamSelectDialog);
			roomView.centerPopUp(_teamSelectDialog);
			
			// Move it down a little so we can slide it up when it fades in.
			_teamSelectDialog.y += 100;
			
			// Fade it in.
			_model.animationManager.alpha(_teamSelectDialog, 1, 2000, Transitions.CUBIC_OUT, RenderMethod.ENTER_FRAME);
			// Slide it up.
			_model.animationManager.move(_teamSelectDialog, _teamSelectDialog.x, _teamSelectDialog.y - 100, 2000, Transitions.ELASTIC_OUT, RenderMethod.ENTER_FRAME);
			
			function teamSelect1():void
			{
				_model.selectedTeamId = currentGame.awayTeam.id;
				
				finish();
			}
			
			function teamSelect2():void
			{
				_model.selectedTeamId = currentGame.homeTeam.id;
				
				finish();
			}
			
			function finish():void
			{
				// Destroy dialog.
				roomView.removePopUp(_teamSelectDialog);
				_teamSelectDialog.destroy();
				
				// Send team select message to server.
				SocketClient.getInstance().sendPluginMessage("avatar_handler", "fandimoniumSide", {eventId:String(currentGame.id), teamId:_model.selectedTeamId});
			
				// Set flag.
				_teamSelectShown = false;
			}
		}
		
		private function handleAvatarUpdate(params:Object):void
		{
			// Set a floor marker for the avtar, depending on the team they selected.
			
			if (params.update == null) return;
			var avatarXML:XML = new XML(params.update);
			var avatarId:int = (avatarXML.avatarId != null) ? avatarXML.avatarId : -1;
			var teamId:int = (avatarXML.tmId != null) ? avatarXML.tmId : 0;
			if (avatarId < 0) return;
				
			setAvatarTeamMarker(avatarId, teamId);
			
			// If it's the user avatar.
			if (avatarId == _model.userAvatar.id)
			{
				// Determine if the user picked the home or away team.
				var isAwayTeam:Boolean = (teamId == _model.currentGame.awayTeam.id);
				if (_fanMeterDisplay != null) _fanMeterDisplay.userTeamIsAway = isAwayTeam;
			}
		}
		
		private function handleRoomEnumeration(params:Object):void
		{
			var xml:XML = (params.roomEnumeration != null) ? new XML(params.roomEnumeration) : null;
			if (xml == null) return;
			
			// Iterate through all avatar XML sets.
			var i:int = 0;
			while (xml.avatar[i] != null)
			{
				// For each avatar,
				// Determine avatarId and teamId.
				// Then give the avatar a floor marker based on their team selection.
				var avatarXML:XML = xml.avatar[i] as XML;
				i++;
				
				var avatarId:int = (avatarXML.avatarId != null) ? avatarXML.avatarId : -1;
				var teamId:int = (avatarXML.tmId != null) ? avatarXML.tmId : -1;
				if (avatarId < 1 || teamId < 1) continue;
				
				setAvatarTeamMarker(avatarId, teamId);
			}
		}
		
		private function handleTeamPickEvent(params:Object):void
		{
			// If the intro has not been shown, show it.
			// Otherwise if the user has not selected a team, show team select.
			if (_model.introHasBeenShown != true)
			{
				showGameIntro();
			}
			else if (_introIsShown != true && _model.userTeamSelected == false)
			{
				showTeamSelect();
			}
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
			var url:String = _model.getTeamLogoUrl(_model.currentGame.awayTeam.id);
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
						_scoreBoardDisplay.teamLogo1 = logo;
						break;
					case 1 :
						_fanMeterDisplay.teamLogo1 = logo;
						break;
					case 2 :
						_outfieldWallsDisplay.awayTeamLogo = logo;
						break;
					case 3 :
						_model.teamSelectLogo1 = logo;
						if (_teamSelectDialog != null) _teamSelectDialog.teamLogo1 = logo;
						break;
					case 4 :
						_model.endGameScreenAwayLogo = logo;
						break;
				}
				
				// Iterate.
				i++;
				
				// Continue loading the logo until we have placed all needed logos.
				if (i < 5)
				{
					loader.unload();
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
			var url:String = _model.getTeamLogoUrl(_model.currentGame.homeTeam.id);
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
						_scoreBoardDisplay.teamLogo2 = logo;
						break;
					case 1 :
						_fanMeterDisplay.teamLogo2 = logo;
						break;
					case 2 :
						_outfieldWallsDisplay.homeTeamLogo = logo;
						break;
					case 3 :
						_model.teamSelectLogo2 = logo;
						if (_teamSelectDialog != null) _teamSelectDialog.teamLogo2 = logo;
						break;
					case 4 :
						_model.endGameScreenHomeLogo = logo;
						break;
				}
				
				// Iterate.
				i++;
				
				// Continue loading the logo until we have placed all needed logos.
				if (i < 5)
				{
					loader.unload();
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
		
		private function generateTeamFloorMarker(team:LiveGameTeam):Sprite
		{
			// Draw a star using team colors.
			var marker:Sprite = new Sprite();
			marker.graphics.beginFill(team.color1);
			marker.graphics.lineStyle(2, team.color2);
			marker.graphics.moveTo(0, -20); // Top point.
			marker.graphics.lineTo(10, -5);
			marker.graphics.lineTo(35, -5); // Right point.
			marker.graphics.lineTo(15, 5);
			marker.graphics.lineTo(25, 22); // Bottom right.
			marker.graphics.lineTo(0, 15); // Bottom middle.
			marker.graphics.lineTo(-25, 22); // Bottom left.
			marker.graphics.lineTo(-15, 5);
			marker.graphics.lineTo(-35, -5); // Left point.
			marker.graphics.lineTo(-10, -5);
			marker.graphics.lineTo(0, -20); // Top point.
			
			marker.cacheAsBitmap = true;
			return marker;
		}
		
		private function prepareCurrentGame():void
		{
			// Get reference to current game current game.
			var currentGame:LiveGame = _model.currentGame;
			
			// Make sure this game has not already been prepared.
			var preparedFlag:Boolean = _gamePreparedFlags[currentGame.id] as Boolean;
			if (preparedFlag == true) return;
			
			// Set prepared flag to true.
			_gamePreparedFlags[currentGame.id] = true;
			
			// Listen for game play events for this game.
			_model.gameCastController.addGameCastListener(currentGame.id, onGamePlayEvent);
			
			// Pass game data to the scoreboard.
			_scoreBoardDisplay.teamName1 = currentGame.awayTeam.shortName;
			_scoreBoardDisplay.teamName2 = currentGame.homeTeam.shortName;
			_scoreBoardDisplay.teamColor1 = currentGame.awayTeam.color1;
			_scoreBoardDisplay.teamColor2 = currentGame.homeTeam.color1;
			
			// Pass game data to field cast.
			_fieldGameCastDisplay.team1 = currentGame.awayTeam;
			_fieldGameCastDisplay.team2 = currentGame.homeTeam;
			
			// Pass game data to fan meter.
			_fanMeterDisplay.teamName1 = currentGame.awayTeam.shortName;
			_fanMeterDisplay.teamName2 = currentGame.homeTeam.shortName;
			_fanMeterDisplay.setTeamColors1(currentGame.awayTeam.color1, currentGame.awayTeam.color2);
			_fanMeterDisplay.setTeamColors2(currentGame.homeTeam.color1, currentGame.homeTeam.color2);
			_fanMeterDisplay.fanScore1 = _model.awayTeamFanScore;
			_fanMeterDisplay.fanScore2 = _model.homeTeamFanScore;
			_fanMeterDisplay.userTokens = _model.userTokensEarnedThisGame;
			
			// Pass game data to the outfield walls.
			_outfieldWallsDisplay.homeTeamColor = currentGame.homeTeam.color1;
			_outfieldWallsDisplay.awayTeamColor = currentGame.awayTeam.color1;
			
			// Set siren colors.
			_model.setSirenColors();
			
			// Send the crowds to the idle state.
			_model.awayCrowdIdle();
			_model.homeCrowdIdle();
			
			// If the game hasn't started, show the next game screen.
			// Otherwise, show the scoreboard.
			if (currentGame.isGameStarted != true)
			{
				endGameScreens.setNextGame(currentGame.startDate.toLocaleString(), currentGame.awayTeam.name, currentGame.homeTeam.name);
				setScreenContent(endGameScreens);
			}
			
			// If the user has not selected a team,
			// Show a dialog box for them to do so.
			if (_model.userTeamSelected == true)
			{
				// Send team select message to server.
				SocketClient.getInstance().sendPluginMessage("avatar_handler", "fandimoniumSide", {eventId:String(currentGame.id), teamId:_model.selectedTeamId});
			}
			
			// Load team logos.
			loadTeamLogos();
		}
		
		private function setAvatarTeamMarker(avatarId:int, teamId:int):void
		{
			// Give the avatar a floor marker that corresponds to the given team.
			
			// Get reference to the current game.
			var currentGame:LiveGame = _model.currentGame;
			
			var avatar:Avatar = _model.room.getAvatarById(avatarId);
			if (avatar == null) return;
			var team:LiveGameTeam = getTeamFromCurrentGameUsingId(teamId);
			if (team == null)
			{
				// Remove the marker.
				avatar.display.floorMarker = null;
			}
			else
			{
				// Generate and set marker.
				avatar.display.floorMarker = generateTeamFloorMarker(team);
			}
		}
		
		private function getTeamFromCurrentGameUsingId(teamId:int):LiveGameTeam
		{
			// Make sure there is a current game.
			var currentGame:LiveGame = _model.currentGame;
			if (currentGame == null) return null;
			
			if (teamId == currentGame.awayTeam.id)
			{
				return currentGame.awayTeam;
			}
			else if (teamId == currentGame.homeTeam.id)
			{
				return currentGame.homeTeam;
			}
			else
			{
				return null;
			}
		}
		
		private function handlePlayType(playType:String):void
		{
			// Play a sound.
			_model.playSound(playType);
			
			// Show an animation on the jumbotron.
			showPlayAnimation(playType);
		}
		
		private function setScreenContent(content:DisplayObject):void
		{
			if (content == _currentScreenContent) return;
			if (_isScreenOverride == true) return;
			
			// Remove previous content.
			if (_currentScreenContent != null)
			{
				_screenContentContainer.removeChild(_currentScreenContent);
			}
			
			// Set new content.
			_currentScreenContent = content;
			_screenContentContainer.addChild(_currentScreenContent);
			_currentScreenContent.mask = _screenContentMask;
			_currentScreenContent.x = -_currentScreenContent.width / 2;
		}
		
		private function showPlayAnimation(playType:String):void
		{
			// Load the animation.
			_model.loadPlayAnimation(playType, onComplete, onError);
			
			function onComplete(e:Event):void
			{
				// When the animation is loaded, show it.
				var animation:MovieClip = _model.getPlayAnimation(playType);
				if (animation != null) show(animation);
			}
			
			function onError(e:Event):void
			{
				// Do nothing on error.
			}
			
			function show(playAnimation:MovieClip):void
			{
				// Show and play a movieclip on the score board.
				// Remove it when it is over.
				playAnimation.addEventListener(Event.ENTER_FRAME, onEnterFrame);
				playAnimation.gotoAndPlay(1);
				setScreenContent(playAnimation);
				
				function onEnterFrame(e:Event):void
				{
					// When the animation is done, remove it.
					if (playAnimation.currentFrame >= playAnimation.totalFrames)
					{
						// Remove the listener.
						playAnimation.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
						
						// Remove the animation and put the scoreboard back up
						if (_model.currentGame.isGameStarted == true && _model.currentGame.isGameOver == false) setScreenContent(_scoreBoardDisplay);
						
						// Stop the animation.
						playAnimation.stop();
					}
				}
			}
		}
		
		private function overrideScreenContent(content:DisplayObject):void
		{
			// Set the screen content and do not allow it to be changed util 'releaseScreenContentOverride' is called.
			_isScreenOverride = false;
			
			setScreenContent(content);
			
			_isScreenOverride = true;
		}
		
		private function releaseScreenContentOverride():void
		{
			_isScreenOverride = false;
		}
		
		private function animateCrowd(gamePlay:LiveGamePlayMLB):void
		{
			// Animate the crowds based on which crowd recieved a positive play.
			var playType:String = gamePlay.playType;
			if (playType == LiveGamePlayMLB.SINGLE || playType == LiveGamePlayMLB.DOUBLE || playType == LiveGamePlayMLB.TRIPLE || playType == LiveGamePlayMLB.HOME_RUN || playType == LiveGamePlayMLB.WALK)
			{
				// Good for offense.
				if (gamePlay.isInningTop == true)
				{
					// Good for away team.
					_model.awayCrowdCheer();
					_model.homeCrowdBoo();
				}
				else
				{
					// Good for the home team.
					_model.awayCrowdBoo();
					_model.homeCrowdCheer();
				}
			}
			else if (playType == LiveGamePlayMLB.OUT || playType == LiveGamePlayMLB.STRIKE_OUT || playType == LiveGamePlayMLB.DOUBLE_PLAY || playType == LiveGamePlayMLB.TRIPLE_PLAY)
			{
				// Good for defense.
				if (gamePlay.isInningTop == true)
				{
					// Good for home team.
					_model.awayCrowdBoo();
					_model.homeCrowdCheer();
				}
				else
				{
					// Good for the away team.
					_model.awayCrowdCheer();
					_model.homeCrowdBoo();
				}
			}
		}
		
		private function startInstructionScreen():void
		{
			var timer:Timer = new Timer(20000);
			timer.addEventListener(TimerEvent.TIMER, onTimer);
			overrideScreenContent(_instructionScreen);
			timer.start();
			
			function onTimer(e:TimerEvent):void
			{
				timer.removeEventListener(TimerEvent.TIMER, onTimer);
				timer.reset();
				
				releaseScreenContentOverride();
			}
		}
		
		private function showGameIntro():void
		{
			// Show intro popup.
			
			if (_introIsShown == true) return;
			
			_introIsShown = true;
			
			_model.introHasBeenShown = true;
			
			// Make sure it is created.
			var loader:Loader;
			var foreground:RenderLayer = _model.foregroundLayer;
			var rO:RenderObject;
			if (_introDisplay == null)
			{
				var request:URLRequest = new URLRequest(_model.introPopupUrl);
				loader = new Loader();
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
				loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
				loader.load(request);
			}
			else
			{
				show();
			}
			
			function show():void
			{
				// Hide game elements.
				gameElementsVisible = false;
				
				// Listen for close event.
				_introDisplay.addEventListener('close', onClose);
				
				// Set alpah to 0 so we can fade it in.
				_introDisplay.alpha = 0;
				
				// Add it to the foreground layer using a render object.
				rO = new RenderObject(new RenderData(_introDisplay));
				foreground.addItem(rO);
				
				// Center intro popup.
				_introDisplay.x = foreground.width / 2 - _introDisplay.width / 2;
				_introDisplay.y = foreground.height / 2 - _introDisplay.height / 2;
				
				// Move it down a little so we can have it slide up when it fades in.
				_introDisplay.y += 300;
				
				// Fade it in.
				_model.animationManager.alpha(_introDisplay, 1, 2000, Transitions.CUBIC_OUT, RenderMethod.ENTER_FRAME);
				// Slide it up.
				_model.animationManager.move(_introDisplay, _introDisplay.x, _introDisplay.y - 300, 2000, Transitions.ELASTIC_OUT, RenderMethod.ENTER_FRAME);
			}
			
			function onComplete(e:Event):void
			{
				// Remove listenrs.
				loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onComplete);
				loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onError);
				
				// Set reference to intro display.
				_introDisplay = loader.content as Sprite;
				
				// Give the display a drop shadow.
				_introDisplay.filters = [new DropShadowFilter(4, 45, 0, 1, 24, 24)];
				
				show();
			}
			
			function onError(e:IOErrorEvent):void
			{
				// Remove listenrs.
				loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onComplete);
				loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onError);
				
				// If a team has not been selected, show team select.
				if (_model.userTeamSelected != true) showTeamSelect();
			}
			
			function onClose(e:Event):void
			{
				// Remove listener.
				_introDisplay.removeEventListener('close', onClose);
				
				// Hide the intro popup.
				foreground.removeItem(rO);
				
				// Set flag.
				_introIsShown = false;
				
				// Show game elements.
				gameElementsVisible = true;
				
				// If a team has not been selected, show team select.
				if (_model.userTeamSelected != true) showTeamSelect();
			}
		}
		
		private function handleUserFanScore(params:Object):void
		{
			if (params.userFandimoniumScore == null) return;
			var userScore:int = params.userFandimoniumScore;
			
			// Make sure the fan meter exists.
			if (_fanMeterDisplay != null)
			{
				// Pass the user score to the fan meter.
				_fanMeterDisplay.userScore = userScore;
				
				// Update the user token count.
				_fanMeterDisplay.userTokens = _model.userTokensEarnedThisGame;
			}
		}
		
		private function showWaveButton():void
		{
			// Set flag.
			_waveButtonVisible = true;
			
			// Make sure the button exists.
			if (_waveButtonDisplay == null) return;
			
			// ANimate the button into view.
			_model.animationManager.move(_waveButtonDisplay, _waveButtonDisplay.x, 470, 2000, Transitions.CUBIC_OUT, RenderMethod.ENTER_FRAME);
		}
		
		private function hideWaveButton():void
		{
			// Set flag.
			_waveButtonVisible = false;
			
			// Make sure the button exists.
			if (_waveButtonDisplay == null) return;
			
			// ANimate the button out of view.
			_model.animationManager.move(_waveButtonDisplay, _waveButtonDisplay.x, 665, 2000, Transitions.CUBIC_OUT, RenderMethod.ENTER_FRAME);
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		private function get endGameScreens():FandemoniumEndGame
		{
			if (_endGameScreens == null)
				_endGameScreens = new FandemoniumEndGame();
			
			return _endGameScreens;
		}
		
		private function set gameElementsVisible(value:Boolean):void
		{
			// Show or hide.
			// Floor layer, fan meter, jumbotron, field cast, wave button.
			_fanMeterDisplay.visible = value;
			_screenContentContainer.visible = value;
			_fieldGameCastDisplay.visible = value;
			_waveButtonContainer.visible = value;
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
			if (socketPluginParams.action == null) return;
			switch (socketPluginParams.action)
			{
				case 'prizeState' :
					handlePrizeState(socketPluginParams);
					break;
				case 'prizeSpawn' :
					handlePrizeSpawn(socketPluginParams);
					break;
				case 'prizeAwarded' :
					handlePrizeAwarded(socketPluginParams);
					break;
				case 'fandimoniumScore' :
					handleFandamoniumScore(socketPluginParams);
					break;
				case 'update' :
					handleAvatarUpdate(socketPluginParams);
					break;
				case 'roomEnumeration' :
					handleRoomEnumeration(socketPluginParams);
					break;
				case 'miniGameStarted' :
					handleMiniGameStarted(socketPluginParams);
					break;
				case 'miniGameEnded' :
					handleMiniGameEnded(socketPluginParams);
					break;
				case 'teamPickEvent' :
					handleTeamPickEvent(socketPluginParams);
					break;
				case 'userFandimoniumScore' :
					handleUserFanScore(socketPluginParams);
					break;
			}
		}
		
		private function onUserAvatarMove(e:SimEvent):void
		{
			// Check if the user avatar collides with any prizes.
			// Get tile occupants for the tile position of the avatar.
			
			var i:int = 0;
			var currentPrizes:FandamoniumPrizeItemCollection = _model.currentPrizes;
			var len:int = currentPrizes.length;
			var prizeItem:SdgItem;
			var collidedPrize:SdgItem;
			var userAvatarEntity:RoomEntity = _model.userAvatar.entity;
			for (i; i < len; i++)
			{
				// Get reference to prize item.
				prizeItem = currentPrizes.getAt(i);
				if (prizeItem == null) return;
				
				// Get the x distance from this prize item to the user avatar.
				var xDis:Number = Math.abs(prizeItem.entity.x - userAvatarEntity.x);
				// Get the y distance from this prize item to the user avatar.
				var yDis:Number = Math.abs(prizeItem.entity.y - userAvatarEntity.y);
				
				// If the x distance and y distance are both less than 1,
				// We consider these 2 items to be colliding.
				if (xDis < 1 && yDis < 1)
				{
					// Prize item collision.
					collidedPrize = prizeItem;
					
					// Stop looping.
					i = len;
				}
			}
			
			// If there is a collided prize.
			if (collidedPrize != null)
			{
				// Dispatch a message to the server.
				var params:Object = {};
				params.prizeContact = collidedPrize.instanceId.toString();
				RoomManager.getInstance().socketMethods.sendEnumMessage('prizeContact', params);
			}
		}
		
		private function onNewGame(e:GameCastEvent):void
		{
			// Remove new game events.
			_model.gameCastController.removeEventListener(GameCastEvent.NEW_GAME_EVENT, onNewGame);
			
			// Remove gamecast listener for previous game.
			if (_model.currentGame != null)
			{
				_model.gameCastController.removeGameCastListener(_model.currentGame.id, onGamePlayEvent);
			}
			
			// Set current game.
			_model.currentGame = e.liveGame;
			
			// Prepare the current gamne.
			prepareCurrentGame();
		}
		
		private function onGamePlayEvent(e:GameCastEvent):void
		{
			var gamePlay:LiveGamePlayMLB = e.gamePlayMLB;
			
			var currentGame:LiveGame = _model.currentGame;
			
			// If the gameplay event is not for the current game, do nothing.
			if (currentGame.id != gamePlay.gameEventId) return;
			
			// Check if the game is in progress.
			if (_model.currentGame.isGameStarted == true && _model.currentGame.isGameOver == false)
			{
				// If the intro has not been shown, show it.
				// Otherwise if the user has not selected a team, show team select.
				if (_model.introHasBeenShown != true)
				{
					showGameIntro();
				}
				else if (_introIsShown != true && _model.userTeamSelected == false)
				{
					showTeamSelect();
				}
			}
			
			// Save the game score in the model
			_model.homeTeamScore = gamePlay.homeTeamScore;
			_model.awayTeamScore = gamePlay.awayTeamScore;
			
			// Update score board.
			_scoreBoardDisplay.score1 = gamePlay.awayTeamScore;
			_scoreBoardDisplay.score2 = gamePlay.homeTeamScore;
			_scoreBoardDisplay.balls = gamePlay.balls;
			_scoreBoardDisplay.strikes = gamePlay.strikes;
			_scoreBoardDisplay.outs = gamePlay.outs;
			_scoreBoardDisplay.inning = gamePlay.inning;
			_scoreBoardDisplay.inningIsTop = gamePlay.isInningTop;
			if (gamePlay.comment.length > 0) _scoreBoardDisplay.tickerText = gamePlay.comment;
			
			// Update field cast.
			_fieldGameCastDisplay.setGamePlay(gamePlay);
			
			// If the game hasn't started, show the next game screen.
			// Otherwise, show the scoreboard.
			if (currentGame.isGameStarted != true)
			{
				endGameScreens.setNextGame(currentGame.startDate.toLocaleString(), currentGame.awayTeam.name, currentGame.homeTeam.name);
				setScreenContent(endGameScreens);
			}
			else if (currentGame.isGameOver != true)
			{
				setScreenContent(_scoreBoardDisplay);
			}
			
			// Handle the type of play.
			handlePlayType(gamePlay.playType);
			
			// Animate crowd.
			animateCrowd(gamePlay);
			
			// If an inning just started, show the instruction screen.
			if (_model.lastPlay != null && _model.lastPlay.inningEnded == true && gamePlay.inningEnded == false)
			{
				startInstructionScreen();
			}
			
			// Keep reference of latest play.
			_model.lastPlay = gamePlay;
		}
		
		private function onStartGameEvent(e:GameCastEvent):void
		{
			// Get the current game
			var currentGame:LiveGame = _model.currentGame;
			
			// If the end event is not for the current game, ignore it.
			if (currentGame.id != e.liveGame.id) return;
		}
		
		private function onEndGameEvent(e:GameCastEvent):void
		{
			// Get the current game
			var currentGame:LiveGame = _model.currentGame;
			
			// If the end event is not for the current game, ignore it.
			if (currentGame.id != e.liveGame.id) return;
			
			// Remove gamecast listener for this game.
			_model.gameCastController.removeGameCastListener(currentGame.id, onGamePlayEvent);
			
			// Get the teams
			var homeTeam:LiveGameTeam = currentGame.homeTeam;
			var awayTeam:LiveGameTeam = currentGame.awayTeam;
			
			// Get top fan team/score
			var topTeamName:String = "";
			var topTeamScore:int = 0;
			var topTeamColor:uint = 0x000000;
			
			if (_model.homeTeamFanScore > _model.awayTeamFanScore)
			{
				topTeamName = homeTeam.shortName + " Fans";
				topTeamScore = _model.homeTeamFanScore;
				topTeamColor = homeTeam.color1;
				
			}
			else if (_model.homeTeamFanScore < _model.awayTeamFanScore)
			{
				topTeamName = awayTeam.shortName + " Fans";
				topTeamScore = _model.awayTeamFanScore;
				topTeamColor = awayTeam.color1;
			}
			else
			{
				topTeamName = "Tie!";
				topTeamScore = _model.homeTeamFanScore;
			}
			
			// Determine the top avatar.
			var topAvatarScore:int = 0;
			var topAvatarName:String = "";
			var topAvatarTeamColor:uint = 0x000000;
			
			var endGameData:FandamoniumEndGameData = FandamoniumEndGameData.GetDataFromGameCastEvent(e);
			if (endGameData != null)
			{
				topAvatarScore = endGameData.topAvatarScore;
				topAvatarName = endGameData.topAvatarName;
				var topAvatarTeam:LiveGameTeam = getTeamFromCurrentGameUsingId(endGameData.topAvatarTeamId);
				if (topAvatarTeam)
					topAvatarTeamColor = topAvatarTeam.color1;
			}
			
			// Add end game screen to jumbotron.
			releaseScreenContentOverride();
			overrideScreenContent(endGameScreens);
			
			// Set end screen params.
			endGameScreens.setEndGameScreen(homeTeam.shortName, _model.homeTeamScore, homeTeam.color1, _model.endGameScreenHomeLogo,
											awayTeam.shortName, _model.awayTeamScore, awayTeam.color1, _model.endGameScreenAwayLogo,
											topTeamScore, topTeamName, topTeamColor,
											topAvatarScore, topAvatarName, topAvatarTeamColor);
											
			// After 10 seconds, prepare the next game.
			var timer:Timer = new Timer(10000);
			timer.addEventListener(TimerEvent.TIMER, onTimerInterval);
			timer.start();
			
			function onTimerInterval(e:TimerEvent):void
			{
				// Kill timer.
				timer.removeEventListener(TimerEvent.TIMER, onTimerInterval);
				timer.reset();
				
				// Remove my team affiliation.
				SocketClient.getInstance().sendPluginMessage("avatar_handler", "fandimoniumSide", {eventId:String(currentGame.id), teamId:0});
				
				// Release screen override.
				releaseScreenContentOverride();
				
				// If there is a current game, prepare it.
				var newGame:LiveGame = _model.gameCastController.getCurrentGame();
				if (newGame != null)
				{
					_model.currentGame = newGame;
					prepareCurrentGame();
				}
				else
				{
					// Listen for new game events.
					_model.gameCastController.addEventListener(GameCastEvent.NEW_GAME_EVENT, onNewGame);
				}
			}
		}
		
		private function onWaveClick(e:Event):void
		{
			// Make the user avtar do the wave action.
			_model.userAvatarController.animate('wave');
		}
		
	}
}