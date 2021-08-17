package com.sdg.control.room
{
	import com.adobe.cairngorm.control.CairngormEventDispatcher;
	import com.sdg.components.controls.ProgressAlertChrome;
	import com.sdg.components.controls.SdgAlertChrome;
	import com.sdg.control.AASModuleLoader;
	import com.sdg.control.ControllerMap;
	import com.sdg.control.IDynamicController;
	import com.sdg.control.PDAController;
	import com.sdg.control.room.itemClasses.AvatarController;
	import com.sdg.control.room.itemClasses.IRoomItemController;
	import com.sdg.control.room.itemClasses.PetController;
	import com.sdg.control.room.itemClasses.RoomEntity;
	import com.sdg.core.IProgressInfo;
	import com.sdg.display.IRoomItemDisplay;
	import com.sdg.events.DoodadActionEvent;
	import com.sdg.events.ExternalGameEvent;
	import com.sdg.events.RoomEnumEvent;
	import com.sdg.events.RoomItemActionEvent;
	import com.sdg.events.RoomItemDisplayEvent;
	import com.sdg.events.RoomNavigateEvent;
	import com.sdg.events.SdgSwfEvent;
	import com.sdg.events.SimEvent;
	import com.sdg.events.SocketPetEvent;
	import com.sdg.factory.RoomItemControllerFactory;
	import com.sdg.model.Avatar;
	import com.sdg.model.HardCodedExitPoints;
	import com.sdg.model.InventoryItem;
	import com.sdg.model.ItemType;
	import com.sdg.model.ModelLocator;
	import com.sdg.model.PetItem;
	import com.sdg.model.Room;
	import com.sdg.model.RoomLayerType;
	import com.sdg.model.SdgItem;
	import com.sdg.net.Environment;
	import com.sdg.net.socket.SocketClient;
	import com.sdg.pet.PetManager;
	import com.sdg.quest.QuestManager;
	import com.sdg.sim.SimEngine;
	import com.sdg.sim.map.IOccupancyTile;
	import com.sdg.sim.map.TileMap;
	import com.sdg.util.Delay;
	import com.sdg.utils.Constants;
	import com.sdg.utils.ProgressMonitor;
	import com.sdg.utils.StoreTrackingUtil;
	import com.sdg.utils.StringUtil;
	import com.sdg.view.IRoomView;

	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.utils.Timer;

	import mx.binding.utils.BindingUtils;
	import mx.binding.utils.ChangeWatcher;
	import mx.events.ModuleEvent;
	import mx.modules.ModuleLoader;

	public class RoomController extends RoomControllerBase
	{
		// RoomType mapped to game controller modules.
		private static const _roomUiControllerMap:Object = {
			8: 'roomcontroller/SkateboardGameModule.swf'
		}
		private static var _petMonitorInterval:int;

		protected var _editModeWatcher:ChangeWatcher;
		protected var _itemControllerFactory:RoomItemControllerFactory;
		protected var _progressMonitor:ProgressMonitor;
		protected var _simEngine:SimEngine;
		protected var _controllers:Array = [];
		protected var _resolveItemInventoryIds:Array;
		protected var _roomSound:Object;
		protected var _roomSoundVolume:Number;
		protected var _defaultVolume:Number = 1;
		protected var _isMuted:Boolean = false;

		private var _currentRoomSoundId:String;
		private var _isLoadingBackgroundSound:Boolean;
		private var _roomSoundLoader:Loader;
		private var _enabled:Boolean;
		private var _uiController:RoomUIController;
		private var _defaultUiController:RoomUIController;
		private var _petMonitorTimer:Timer;
		private var _messagedForLowPetEnergy:Boolean;
		private var _messagedForLowPetHappiness:Boolean;
		private var _newSoundLoader:Loader;
		private var _localAvatarCollisionTileCoordinates:Array;
		private var _isSpeedBoostActive:Boolean;
		private var _localAvatarSpeedPriorSpeedBoost:Number;

		public function RoomController(roomView:IRoomView)
		{
			// setup initial values
			_itemControllerFactory = new RoomItemControllerFactory();
			_progressMonitor = new ProgressMonitor();
			_simEngine = new SimEngine();
			_roomView = roomView;
			_roomView.addEventListener(SdgSwfEvent.INIT_CONTROLLER, initController);
			_currentRoomSoundId = '';
			_resolveItemInventoryIds = [];
			_localAvatarCollisionTileCoordinates = [];

			// Determine granularity at which to monitor the pet.
			_petMonitorInterval = PetItem.DURATION_OF_FULL_ENERGY / PetItem.ENERGY_LEVEL_STEPS / 8;

			// Create userController and set it on RoomManager.
			_itemControllerFactory.setItem(_localAvatar);
			_roomManager.userController = _itemControllerFactory.createInstance() as AvatarController;

			// Create UI controller.
			_defaultUiController = _uiController = new RoomUIController();

			// Pass room view to the PDA controller.
			if (Constants.PDA_ENABLED) PDAController.getInstance().roomView = _roomView;

			// Pass the room view to the Quest Manager.
			QuestManager.roomView = _roomView;

			// Listen to quest manager events.
			QuestManager.getInstance().addEventListener(QuestManager.ACTIVE_QUESTS_UPDATE, onActiveQuestsUpdate);

			// Start simEngine.
			_simEngine.start();
		}

		////////////////////
		// PUBLIC METHODS
		////////////////////

		public function initController(data:Object):void
		{
			// Determine which controller should be created, create it
			if (data.controllerID == null) return;
			var controllerID:int = int(data.controllerID);
			var controllerClass:Class = ControllerMap.getClass(controllerID);
			if (controllerClass == null) return;
			var controller:IDynamicController;
			try
			{
				controller = new controllerClass(_roomView, data);
				if (controller != null) _controllers.push(controller);
			}
			catch (e:Error)
			{
				trace('Could not instantiate dynamic controller.');
				trace(e.message);
			}

			// Initialize the controller.
			if (controller != null) controller.init();
		}

		public function backgroundAction(params:Object):void
		{
			if (params.action == "shopStore")
			{
				StoreTrackingUtil.trackCatalogStoreClick(_room.storeId);
				var storeId:int = RoomManager.getInstance().currentRoom.storeId;
				params.storeId = storeId > 0 ? storeId : 1;
				AASModuleLoader.openStoreModule(params, 'StoreModule', 'Store', true);
			}
			else if (params.action == "printshop")
			{
				AASModuleLoader.openPrintShopModule();
			}
			else if ("walkToRoom" == params.action)
			{
				var toRoomId:String = params.toRoomId;
				var fromRoomId:String = params.fromRoomId;
				var walkToX:int = params.walkToX;
				var walkToY:int = params.walkToY;

				// Have the avatar walk to a trigger tile that goes through the door.
				var exitPoint:Point = HardCodedExitPoints.GetHardCodedExitPoint(fromRoomId, toRoomId);
				if (exitPoint)
				{
					userController.walk(exitPoint.x, exitPoint.y);
				}
				else
				{
					userController.walk(walkToX, walkToY);
				}
			}
		}

		public function setupRoomSound(room:Room):void
		{
			// Check soundId for the new room.
			// If it's new/different then load the new sound.
			if (room == null) return;
			if (_roomSoundLoader == null || room.backgroundMusicSoundId != _currentRoomSoundId)
			{
				loadNewRoomSound(room.backgroundMusicSoundId, room.backgroundMusicVolume);
			}
			else
			{
				// If the sound id is the same.
				// Try to reset the volume.
				if (_isMuted)
				{
					roomSoundVolume = 0;
				}
				else
				{
					roomSoundVolume = room.backgroundMusicVolume;
				}
			}
		}

		public function setRoomSound(value:uint):void
		{
			if (!_isMuted)
				roomSoundVolume = value;
		}

		public function muteRoomSound():void
		{
			_isMuted = true;
			roomSoundVolume = 0;
		}

		public function unMuteRoomSound():void
		{
			_isMuted = false;
			roomSoundVolume = _defaultVolume;
			//_roomView.getRoomController().roomSoundVolume = 5;
		}

		////////////////////
		// PROTECTED METHODS
		////////////////////

		override protected function cleanUp():void
		{
			trace('RoomController.cleanUp()');
			super.cleanUp();

			// clean up controllers
			var i:int = 0;
			var len:int = _controllers.length;
			for (i; i < len; i++)
			{
				IDynamicController(_controllers[i]).destroy();
				_controllers.splice(i, 1);
			}

			// Unwatch editMode property.
			_editModeWatcher.unwatch();

			// Remove item action listener.
			_roomManager.removeEventListener(RoomItemActionEvent.ROOM_ITEM_ACTION, itemActionHandler);

			// Remove other listeners.
			_roomManager.removeEventListener(ExternalGameEvent.LOAD_GAME, onExternalGameLoad);
			_localAvatar.removeEventListener(Avatar.LEASHED_PET_UPDATE, onLocalAvatarLeashedPetUpdate);
			_localAvatar.entity.data.removeEventListener(SimEvent.MOVED, onLocalAvatarMove);

			// Remove socket event listeners.
			SocketClient.removePluginActionHandler(SocketPetEvent.PET_PLAYED, onPetPlayedSocketEvent);
			SocketClient.removePluginActionHandler(SocketPetEvent.PET_CONSUMED, onPetConsumedSocketEvent);
			SocketClient.removePluginActionHandler(DoodadActionEvent.PET_LEASH, onPetLeashSocketEvent);
			SocketClient.removePluginActionHandler(DoodadActionEvent.PET_UNLEASH, onPetUnleashSocketEvent);
			SocketClient.removePluginActionHandler(SocketPetEvent.PET_FOLLOW_MODE, onPetFollowModeSocketEvent);

			// Stop minitoring local pet.
			stopMonitoringLocalLeashedPet();

			// Clear list of tiles that are checked for collision every time the local avatar moves.
			_localAvatarCollisionTileCoordinates = [];

			_progressMonitor.removeAllSources();
		}

		override protected function setUp():void
		{
			trace('RoomController.setUp()');
			super.setUp();

			// Set context on ui controller.
			_uiController.context = _context;

			// Add userController to context.
			_context.addItemController(userController.item, userController);

			// Bind to editMode property.
			_editModeWatcher = BindingUtils.bindSetter(editModeChanged, _room, "editMode");

			// Add item action listener.
			_roomManager.addEventListener(RoomItemActionEvent.ROOM_ITEM_ACTION, itemActionHandler);

			// Listen to the main application for game load events.
			_roomManager.addEventListener(ExternalGameEvent.LOAD_GAME, onExternalGameLoad);

			// Listen for socket events.
			SocketClient.addPluginActionHandler(SocketPetEvent.PET_PLAYED, onPetPlayedSocketEvent);
			SocketClient.addPluginActionHandler(SocketPetEvent.PET_CONSUMED, onPetConsumedSocketEvent);
			SocketClient.addPluginActionHandler(DoodadActionEvent.PET_LEASH, onPetLeashSocketEvent);
			SocketClient.addPluginActionHandler(DoodadActionEvent.PET_UNLEASH, onPetUnleashSocketEvent);
			SocketClient.addPluginActionHandler(SocketPetEvent.PET_FOLLOW_MODE, onPetFollowModeSocketEvent);

			// Check if the avatar has a leashed pet.
			// Also listen for when the avatar leashes/unleashes a pet.
			_localAvatar.addEventListener(Avatar.LEASHED_PET_UPDATE, onLocalAvatarLeashedPetUpdate);
			if (_localAvatar.leashedPetInventoryId > 0)
			{
				// Start monitoring the pet that the local avatar has leashed.
				monitorLocalLeashedPet();
			}

			// Monitor local avatar collision on specific types of tiles.
			// Get floor tile map.
			var floorTileMap:TileMap = _room.getMapLayer(RoomLayerType.FLOOR);
			// Get all speed boost tile coordinates.
			var speedBoostTileCoordinates:Array = (floorTileMap) ? floorTileMap.getTileSet('speedboost', true) : [];
			// Add speed boost tile coordinates to a list hat will be checked for collision every time the local avatar moves.
			_localAvatarCollisionTileCoordinates = _localAvatarCollisionTileCoordinates.concat(speedBoostTileCoordinates);

			// Listen for when the local avatar moves.
			// This is so we can detect collision with specific tiles.
			_localAvatar.entity.data.addEventListener(SimEvent.MOVED, onLocalAvatarMove);

			_progressMonitor.addSource(_context.progressInfo);
		}

		protected function editModeChanged(editMode:Boolean):void
		{
			// Change UI controller, depending on whether or not we entered edit mode.
			var newUiController:RoomUIController = (editMode) ? new PrivateRoomEditor() : _defaultUiController;
			setCustomUIController(newUiController);
		}

		//This will be useful for inworld games like Bunny Defense and the pet game
		public function setCustomUIController(newUiController:RoomUIController):void
		{
			if (newUiController == _uiController) return;

			// Setting the context on the UI controller should trigger any necesary clean up or setup.
			_uiController.context = null;
			_uiController = newUiController;
			_uiController.context = _context;
		}
		public function useDefaultUIController():void
		{
			setCustomUIController(_defaultUiController);
		}

		////////////////////
		// PRIVATE METHODS
		////////////////////

		private function loadNewRoomSound(soundId:String = '', volume:Number = 1):void
		{
			// Load background music.
			if (soundId != '')
			{
				_isLoadingBackgroundSound = true;

				var soundUrl:String = Environment.getAssetUrl() + "/test/static/sound?soundId=" + soundId;

				// Sounds are actualy SWF files with sound loops inside them.
				var request:URLRequest = new URLRequest(soundUrl);

				if (_newSoundLoader != null)
				{
					_newSoundLoader.close();
					killRoomSoundLoader();
				}

				_newSoundLoader = new Loader();

				// Set new sound id.
				_currentRoomSoundId = soundId;

				// Try to set volume.
				_defaultVolume = volume;

				_newSoundLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onRoomSoundComplete);
				_newSoundLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onRoomSoundError);
				_newSoundLoader.load(request);
			}
			else
			{
				// Just stop the current sound.
				destroyRoomSound();
			}
		}

		private	function onRoomSoundComplete(e:Event):void
		{
			// We successfuly loaded a room sound, which is actualy a swf file.
			// Kill room sound loader.
			killRoomSoundLoader();

			// Destroy the previous sound.
			destroyRoomSound();

			// Set new sound.
			_roomSoundLoader = _newSoundLoader;
			_roomSound = _roomSoundLoader.content;

			if (_isMuted)
			{
				roomSoundVolume = 0;
			}
			else
			{
				roomSoundVolume = _defaultVolume;
			}

			_newSoundLoader = null;
		}

		private function onRoomSoundError(e:IOErrorEvent):void
		{
			// Failed to load room sound.
			// Kill room sound loader.
			killRoomSoundLoader();
			_newSoundLoader = null;
		}

		private function killRoomSoundLoader():void
		{
			_newSoundLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onRoomSoundComplete);
			_newSoundLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onRoomSoundError);
			_isLoadingBackgroundSound = false;
		}

		private function destroyRoomSound():void
		{
			// Stop room sound.
			if (_roomSoundLoader != null)
			{
				// Try to call destroy method on room sound.
				var roomSound:Object = _roomSoundLoader.content as Object;
				// Win 7 bug #679, will crash on this line, put a try catch so as not to block execution
				try
				{
					if (roomSound != null && roomSound.destroy != null) roomSound.destroy();
				}
				catch (e:Error)
				{
					trace('RoomController->destroyRoomSound encountered an error.');
					trace('\terrorID = ' + e.errorID);
					trace('\tname = ' + e.name);
					trace('\tmessage = ' + e.message);
				}

				_roomSoundLoader.unload();
				_roomSoundLoader = null;
			}
		}

		private function updateAllResolveItems():void
		{
			// Make sure there is a room instance.
			if (_room == null) return;

			var items:Array = _room.getAllInventoryItems();
			for each (var item:InventoryItem in items)
			{
				updateResolveItemInRoom(item);
			}
		}

		private function updateResolveItemInRoom(item:SdgItem):void
		{
			// If this item is a resolve item for missions/quests,
			// Flag it as being so.

			// Make sure this is an inventory item.
			var invetoryItem:InventoryItem = item as InventoryItem;
			if (invetoryItem == null) return;
			// Get item controller.
			var itemController:IRoomItemController = getItemController(item);
			if (itemController == null) return;
			// Determine the resolve status for this inventory item.
			var inventoryItemResolveStatus:int = QuestManager.getInventoryItemResolveStatus(invetoryItem.inventoryItemId);
			// Set floor as 0.
			if (inventoryItemResolveStatus < 0) inventoryItemResolveStatus = 0;
			itemController.itemResolveStatus = inventoryItemResolveStatus;
		}

		private function monitorLocalLeashedPet():void
		{
			// Monitor happiness/energy levels of the leashed local pet(owned by the local avatar).
			// Create timer to monitor the pet.
			_petMonitorTimer = new Timer(_petMonitorInterval);
			_petMonitorTimer.addEventListener(TimerEvent.TIMER, onPetMonitorTimerInterval);
			_petMonitorTimer.start();
		}

		private function stopMonitoringLocalLeashedPet():void
		{
			if (!_petMonitorTimer) return;

			_petMonitorTimer.removeEventListener(TimerEvent.TIMER, onPetMonitorTimerInterval);
			_petMonitorTimer.reset();
			_petMonitorTimer = null;
		}

		private function handleMonitoredPetEnergyHappinessLevels():void
		{
			// Get a reference to the leashed local pet.
			var petController:PetController = _context.getItemControllerWithInventoryId(_localAvatar.leashedPetInventoryId) as PetController;
			if (!petController) return;

			checkPetEnergyHappiness(petController);
		}

		private function checkPetEnergyHappiness(petController:PetController):void
		{
			var petItem:PetItem = petController.petItem;
			var isLeashed:Boolean = petItem.isLeashed;
			var levelsAreLow:Boolean = false;
			if (!petItem) return;

			// If the pet energy or happiness levels is at 0, unleash the pet and message it to the user.
			var message:String;
			if (isLeashed && petItem.energy <= 0)
			{
				// Must unleash the pet because the pet has no energy.
				PetManager.unleashPet(petItem.id);
				message = petItem.name + ' went back to your home turf.';
				// Use a different message if in the local users turf.
				if (_localAvatar.privateRoom == _room.id) message = petItem.name + ' had to be unleashed.';
				SdgAlertChrome.show(message, 'Your pet was tired');
			}
			else if (isLeashed && petItem.happiness <= 0)
			{
				// Must unleash the pet because the pet has 0 happiness.
				PetManager.unleashPet(petItem.id);
				message = petItem.name + ' went back to your home turf.';
				// Use a different message if in the local users turf.
				if (_localAvatar.privateRoom == _room.id) message = petItem.name + ' had to be unleashed.';
				SdgAlertChrome.show(message, 'Your pet was sad');
			}
			else if (petItem.energyLevelStep < 2)
			{
				// Pet energy level is getting low.
				// Message this to user.
				if (!_messagedForLowPetEnergy && isLeashed) SdgAlertChrome.show('Food will provide energy.', StringUtil.GetStringWithinCharacterLimit(petItem.name, 19) + ' is tired');
				_messagedForLowPetEnergy = true;
				levelsAreLow = true;
			}
			else if (petItem.happinessLevelStep < 2)
			{
				// Pet happiness level is getting low.
				// Message this to user.
				if (!_messagedForLowPetEnergy && isLeashed) SdgAlertChrome.show('Play will provide happiness.', StringUtil.GetStringWithinCharacterLimit(petItem.name, 19) + ' is sad');
				_messagedForLowPetHappiness = true;
				levelsAreLow = true;
			}

			// Show an effect over the pet.
			if (levelsAreLow) petController.showOverheadAsset(new PetEffectWarning(), _petMonitorInterval / 3);
		}

		private function showRoomItemEffect(roomItemController:IRoomItemController, effectAsset:DisplayObject, offX:Number = 0, offY:Number = 0, duration:int = 3000):void
		{
			var itemDisplay:IRoomItemDisplay = roomItemController.display;
			var imgRect:Rectangle = itemDisplay.getImageRect(true);
			effectAsset.x = itemDisplay.x + imgRect.x + imgRect.width / 2 + offX;
			effectAsset.y = itemDisplay.y + imgRect.y + imgRect.height / 2 + offY;
			_roomView.uiLayer.addChild(effectAsset);

			var timer:Timer = new Timer(duration);
			timer.addEventListener(TimerEvent.TIMER, onTimer);
			timer.start();

			function onTimer(e:TimerEvent):void
			{
				// Hide asset.
				timer.removeEventListener(TimerEvent.TIMER, onTimer);
				timer.reset();
				timer = null;

				if (_roomView.uiLayer.contains(effectAsset)) _roomView.uiLayer.removeChild(effectAsset);
				effectAsset = null;
			}
		}

		private function loadRoomControllerModule(moduleUrl:String):void
		{
			// Load a room controller module.
			// Use a timer to prevent a load hang.
			var timeoutLimit:int = 10000;
			var timer:Timer = new Timer(timeoutLimit);
			timer.addEventListener(TimerEvent.TIMER, onTimeout);

			// Prepare to load module.
			var loader:ModuleLoader = new ModuleLoader();
			loader.applicationDomain = ApplicationDomain.currentDomain;
			loader.addEventListener(ModuleEvent.READY, onModuleReady);
			loader.addEventListener(ModuleEvent.ERROR, onModuleError);
			loader.addEventListener(ModuleEvent.PROGRESS, onModuleProgress);

			// Show progress alert to let the user know that we are loading content.
			var progressAlert:ProgressAlertChrome = ProgressAlertChrome.show('Loading game.', 'Skateboard Game', null, null, false, null, null, true, false, 430, 200, 60000);

			// Start timer.
			timer.start();

			// Load module.
			loader.loadModule(moduleUrl);

			function onTimeout(e:TimerEvent):void
			{
				cleanup();
				handleErrorCase();
			}

			function onModuleProgress(e:ModuleEvent):void
			{
				// Reset timer.
				timer.reset();
				timer.start();
			}

			function onModuleError(e:ModuleEvent):void
			{
				cleanup();
				handleErrorCase();
			}

			function onModuleReady(e:ModuleEvent):void
			{
				cleanup();

				// Extract room ui controller from loaded module.
				var module:Object = loader.child;
				// Grab varios params to pass to module.
				var incomingGameParams:Object = (ModelLocator.getInstance().incomingGameParams) ? ModelLocator.getInstance().incomingGameParams : null;
				var isPractice:Boolean = (incomingGameParams && incomingGameParams.isPractice);
				var gameId:int = (incomingGameParams && incomingGameParams.gameId) ? incomingGameParams.gameId : 0;
				if (module['createController']) setCustomUIController(module.createController({isPractice: isPractice, gameId: gameId}));
			}

			function cleanup():void
			{
				// Remove listeners.
				loader.removeEventListener(ModuleEvent.READY, onModuleReady);
				loader.removeEventListener(ModuleEvent.ERROR, onModuleError);
				loader.removeEventListener(ModuleEvent.PROGRESS, onModuleProgress);
				timer.removeEventListener(TimerEvent.TIMER, onTimeout);

				timer.reset();
				timer = null;

				// Remove progress alert.
				progressAlert.close(0);
			}

			function handleErrorCase():void
			{
				// The room controller module failed to load.
				// Message the user.
				SdgAlertChrome.show('Failed to load.', 'Error');
				// Send the user to the previous room.
				// Room enumeration must refresh before we can switch rooms. Listen for this.
				if (_room.isEnumRefreshed)
				{
					// Room enum is refreshed so we can send user to previous room.
					CairngormEventDispatcher.getInstance().dispatchEvent(new RoomNavigateEvent(RoomNavigateEvent.ENTER_PREV_ROOM));
				}
				else
				{
					// Room enum has not been refreshed so we need to listen for this event.
					_room.addEventListener(RoomEnumEvent.ENUM_REFRESH, onRoomEnumRefresh);
				}

				function onRoomEnumRefresh(e:RoomEnumEvent):void
				{
					// Now that room enum has refreshed, we can send the user to the rpevious room.
					_room.removeEventListener(RoomEnumEvent.ENUM_REFRESH, onRoomEnumRefresh);
					CairngormEventDispatcher.getInstance().dispatchEvent(new RoomNavigateEvent(RoomNavigateEvent.ENTER_PREV_ROOM));
				}
			}
		}

		////////////////////
		// GET/SET METHODS
		////////////////////

		public function get enabled():Boolean
		{
			return _enabled;
		}

		public function set enabled(value:Boolean):void
		{
			_enabled = value;

			_roomView.enabled = _enabled;

			if (_enabled)
				_simEngine.start();
			else
				_simEngine.stop();
		}

		public function get currentRoom():Room
		{
			return _room;
		}
		public function set currentRoom(room:Room):void
		{
			// Clear old context.
			if (_context) _context.clear();

			// Use default UI controller.
			useDefaultUIController();

			// Set new context.
			context = (room) ? new RoomContext(_simEngine, room, _roomView, _itemControllerFactory) : null;

			// Setup room sound.
			setupRoomSound(room);

			// Check if we should load a room ui controller specific for this room type.
			var roomControllerModuleUrl:String = (room) ? _roomUiControllerMap[room.roomType] : null;
			if (roomControllerModuleUrl) loadRoomControllerModule(roomControllerModuleUrl);
		}

		public function get roomView():IRoomView
		{
			return _roomView;
		}

		public function get isMuted():Boolean
		{
			return _isMuted;
		}

		public function get roomSoundVolume():Number
		{
			return _roomSoundVolume;
		}

		// NOTE: This SETTER bypasses muting checks - only call after checking mute value
		public function set roomSoundVolume(value:Number):void
		{
			_roomSoundVolume = value;

			// We've experience issues with the following call, specifically on WIN 7 machines.
			// Use a try/catch block so we don't hault code execution on this line.
			try
			{
				if (_roomSound != null && _roomSound.setVolume != null) _roomSound.setVolume(value);
			}
			catch (e:Error)
			{
				trace('RoomController->roomSoundVolume(' + value + ') encountered an error.');
				trace('\terrorID = ' + e.errorID);
				trace('\tname = ' + e.name);
				trace('\tmessage = ' + e.message);
			}
		}

		////////////////////
		// EVENT HANDLERS
		////////////////////

		override protected function handleAddedItemController(itemController:IRoomItemController):void
		{
			super.handleAddedItemController(itemController);

			// Add to progress monitor.
			var itemProgressInfo:IProgressInfo = itemController.progressInfo;
			if (itemProgressInfo) _progressMonitor.addSource(itemProgressInfo);

			// Update the resolve status for the item.
			updateResolveItemInRoom(itemController.item);

			// If the added item is a pet owned by the local avatar, do a check on there energy/happiness levels.
			if (itemController.item.itemTypeId == ItemType.PETS && itemController.item.avatarId == _localAvatar.avatarId)
			{
				itemController.display.addEventListener(RoomItemDisplayEvent.CONTENT, onLocalPetContentComplete);
			}

			function onLocalPetContentComplete(e:RoomItemDisplayEvent):void
			{
				// Remove listener.
				itemController.display.removeEventListener(RoomItemDisplayEvent.CONTENT, onLocalPetContentComplete);
				// Check pets energy/happiness levels.
				checkPetEnergyHappiness(PetController(itemController));
			}
		}

		override protected function handleRemovedItemController(itemController:IRoomItemController):void
		{
			// Make sure there is an item controller.
			if (itemController == null) return;

			// Remove from progress monitor.
			_progressMonitor.removeSource(itemController.progressInfo);

			super.handleRemovedItemController(itemController);
		}

		protected function itemActionHandler(event:RoomItemActionEvent):void
		{
			// create local var for action name and params
			var action:String = event.action;
			var params:Object = event.params;

			var controller:IRoomItemController;
			controller = getItemController(event.item);
			controller.processAction(action, params);

			// process actions on room action listeners
			var listeners:Array = _room.roomActionListeners[action] as Array;
			if (listeners != null)
			{
				var i:int;
				var len:int = listeners.length;
				for (i = 0; i < len; i++)
				{
					controller = getItemController(listeners[i] as SdgItem);
					controller.processAction(action, params);
				}
			}
		}

		private function onExternalGameLoad(e:ExternalGameEvent):void
		{
			// Stop current room sound.
			destroyRoomSound();
		}

		private function onActiveQuestsUpdate(e:Event):void
		{
			// When the list of active quests have been updated,
			// Update the esolve items.
			updateAllResolveItems();
		}

		private function onPetPlayedSocketEvent(e:SocketPetEvent):void
		{
			// Get a reference to the pet that has been played with.
			var petController:PetController = PetController(_context.getItemControllerWithInventoryId(e.petInventoryId));
			if (!petController) return;

			// Set the pets happiness and energy levels.
			var petItem:PetItem = PetItem(petController.item);
			petItem.setEnergy(e.energy, e.energyTimeStamp);
			petItem.setHappiness(e.happiness, e.happinessTimeStamp);

			// Show an effect over the pet.
			petController.showOverheadAsset(new PetEffectHappiness(), 3000);

			// Set flag.
			_messagedForLowPetHappiness = false;
		}

		private function onPetConsumedSocketEvent(e:SocketPetEvent):void
		{
			// Get a reference to the pet that has consumed an item.
			var petController:PetController = PetController(_context.getItemControllerWithInventoryId(e.petInventoryId));
			if (!petController) return;

			// Set the pets happiness and energy levels.
			var petItem:PetItem = PetItem(petController.item);
			petItem.setEnergy(e.energy, e.energyTimeStamp);
			petItem.setHappiness(e.happiness, e.happinessTimeStamp);

			// Show an effect over the pet.
			petController.showOverheadAsset(new PetEffectEnergy(), 3000);

			// Set flag.
			_messagedForLowPetEnergy = false;
		}

		private function onPetMonitorTimerInterval(e:TimerEvent):void
		{
			// On each interval, check the pets energy/happiness levels and handle them accordingly.
			handleMonitoredPetEnergyHappinessLevels();
		}

		private function onLocalAvatarLeashedPetUpdate(e:Event):void
		{
			// If we were monitoring a pet, stop.
			if (_petMonitorTimer) stopMonitoringLocalLeashedPet();

			// If the local avatar has a leashed pet, start monitoring the pet.
			if (_localAvatar.leashedPetInventoryId > 0)
			{
				// Start monitoring the pet that the local avatar has leashed.
				monitorLocalLeashedPet();
			}
		}

		private function onPetLeashSocketEvent(e:DoodadActionEvent):void
		{
			// Make sure it is the local avatar that has leashed a pet.
			if (_localAvatar.avatarId != e.senderAvatarId) return;

			// Set local avatar's leashed pet.
			_localAvatar.leashedPetInventoryId = e.id;

			// Show leash effect.
			// If the pet is owned by the local avatar and we are in the local avatars turf, don't show effect.
			var petController:PetController = _roomManager.roomContext.getItemControllerWithInventoryId(e.id) as PetController;
			if (!petController) return;
			petController.petItem.isFollowingOwner = true;
			var isLocalPetInLocalTurf:Boolean = (petController.item.avatarId == _localAvatar.avatarId && _room.id == _localAvatar.privateRoom);
			if (!isLocalPetInLocalTurf) showRoomItemEffect(petController, new PetEffectLeash());

		}

		private function onPetUnleashSocketEvent(e:DoodadActionEvent):void
		{
			// If the local user's pet has been unleashed, reset the value on the avatar.
			if (_localAvatar.leashedPetInventoryId != e.id) return;
			trace('Handling unleashed pet (' + e.id + ') for avatar (' + _localAvatar.avatarId + ').');
			_localAvatar.leashedPetInventoryId = 0;
			_localAvatar.leashedPetItemId = 0;

			// Show leash effect.
			// If the pet is owned by the local avatar and we are in the local avatars turf, don't show effect.
			var petController:IRoomItemController = _roomManager.roomContext.getItemControllerWithInventoryId(e.id);
			if (!petController) return;
			var isLocalPetInLocalTurf:Boolean = (petController.item.avatarId == _localAvatar.avatarId && _room.id == _localAvatar.privateRoom);
			if (!isLocalPetInLocalTurf) showRoomItemEffect(petController, new PetEffectLeash());
		}

		private function onPetFollowModeSocketEvent(e:SocketPetEvent):void
		{
			var petController:PetController = _roomManager.roomContext.getItemControllerWithInventoryId(e.petInventoryId) as PetController;
			if (!petController) return;
			petController.petItem.isFollowingOwner = (e.followMode) != 0; // Non-SDG - manually convert the int to a boolean
		}

		private function onLocalAvatarMove(e:SimEvent):void
		{
			// Check if the user avatar collides with specific tiles.

			// Since speed boost is the only type of tile we currently check collision for,
			// Don't do a collision check if speed boost is already active.
			// If we make other types of tiles that we want to check collision for, we need to remove this.
			if (_isSpeedBoostActive) return;

			// Define collision threshold.
			// How close the avatar must be to a tile to collide with it.
			var collisionThresholdX:Number = 1;
			var collisionThresholdY:Number = 1;

			// Make sure there is still a room reference.
			if (!_room) return;

			var i:int = 0;
			var len:int = _localAvatarCollisionTileCoordinates.length;
			var collidedTileCoordinate:Point;
			var userAvatarEntity:RoomEntity = _localAvatar.entity;
			for (i; i < len; i++)
			{
				// Get reference to item.
				var tileCoordinate:Point = _localAvatarCollisionTileCoordinates[i];
				if (tileCoordinate == null) return;

				// Get the x distance from this tile to the user avatar.
				var xDis:Number = Math.abs(tileCoordinate.x - userAvatarEntity.x);
				// Get the y distance from this tile to the user avatar.
				var yDis:Number = Math.abs(tileCoordinate.y - userAvatarEntity.y);

				// If the x distance and y distance are both less than the treshold,
				// We consider this to be a collision.
				if (xDis < collisionThresholdX && yDis < collisionThresholdY)
				{
					// Item collision.
					collidedTileCoordinate = tileCoordinate;

					// Stop looping.
					i = len;
				}
			}

			// If there is a collided tile.
			// Let the server know.
			if (collidedTileCoordinate != null)
			{
				// Get a reference to the tile so we can handle it properly.
				var collidedTile:IOccupancyTile = _room.getMapLayer(RoomLayerType.FLOOR).getTile(collidedTileCoordinate.x, collidedTileCoordinate.y);
				var collidedTileId:String = (collidedTile) ? collidedTile.tileSetID : '';
				// Handle tile collision based on tile set id.
				switch (collidedTileId)
				{
					case 'speedboost':
						// Increase walk speed for 5 seconds.
						// Make sure speed boost is not already active.
						if (_isSpeedBoostActive) return;
						_localAvatarSpeedPriorSpeedBoost = userController.walkSpeedMultiplier;
						userController.walkSpeedMultiplier *= 2;
						_isSpeedBoostActive = true;
						// Have local avatar re-send a walk message for the tile that they may be currently walking to, to trigger the increased speed.
						var localAvatarLastWalkCoordinate:Point = userController.lastWalkCoordinate;
						if (localAvatarLastWalkCoordinate) userController.walk(localAvatarLastWalkCoordinate.x, localAvatarLastWalkCoordinate.y);
						Delay.CallFunctionAfterDelay(5000, onSpeedBoostTimeout);
						break;
					default:
						// Do nothing.
				}
			}
		}

		private function onSpeedBoostTimeout():void
		{
			// Reset avatar speed.
			userController.walkSpeedMultiplier = _localAvatarSpeedPriorSpeedBoost;
			_isSpeedBoostActive = false;
		}

	}
}
