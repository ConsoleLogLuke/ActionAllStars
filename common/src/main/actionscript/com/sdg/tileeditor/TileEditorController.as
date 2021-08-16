package com.sdg.tileeditor
{
	import com.good.goodui.GoodAlert;
	import com.good.goodui.GoodButtonListDialog;
	import com.good.goodui.GoodDialog;
	import com.good.goodui.GoodDropDown;
	import com.good.goodui.GoodDropDownDialog;
	import com.good.goodui.GoodInput;
	import com.good.goodui.GoodInputDialog;
	import com.good.goodui.GoodMessage;
	import com.sdg.business.SdgServiceDelegate;
	import com.sdg.model.IIdObject;
	import com.sdg.model.IdObject;
	import com.sdg.model.IdObjectCollection;
	import com.sdg.model.RoomConfig;
	import com.sdg.model.ServerModel;
	import com.sdg.sim.map.TileSet;
	import com.sdg.sim.map.TileSetCollection;
	
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;

	public class TileEditorController extends EventDispatcher
	{
		protected var _model:TileEditorModel;
		protected var _view:TileEditorView;
		
		public function TileEditorController(model:TileEditorModel)
		{
			super();
			
			_model = model;
			_view = _model.view;
		}
		
		internal function init():void
		{
			// Set servers on the view.
			_view.servers = _model.servers;
			
			// Hide some controls.
			_view.tileSetDropDownVisible = false;
			_view.roomDropDownVisible = false;
			
			// Listen for view events.
			_view.addEventListener(TileEditorView.ADD_TILE_SET_CLICK, onAddTileSetClick);
			_view.addEventListener(TileEditorView.REMOVE_TILE_SET_CLICK, onRemoveTileSetClick);
			
			// Listen for server select.
			_view.addEventListener(TileEditorView.SERVER_SELECT, onInitialServerSelect);
			_view.addEventListener(TileEditorView.SERVER_SELECT, onServerSelect);
			
			// Listen for view events.
			_view.addEventListener(TileEditorView.SAVE_CLICK, onSaveClick);
			_view.addEventListener(TileEditorView.ROOM_SELECT, onRoomSelect);
			
			// Listen for model events.
			_model.addEventListener(TileEditorModel.TILE_SETS_UPDATE, onTileSetsUpdate);
			
			// Message user to select a server.
			var message:GoodMessage = new GoodMessage(300, 200, 'Select a server to use.');
			_view.showDialog(message);
			
			function onInitialServerSelect(e:Event):void
			{
				// Remove event listener.
				_view.removeEventListener(TileEditorView.SERVER_SELECT, onInitialServerSelect);
				
				// Remove message.
				_view.removeDialog(message);
				
				// Set server on model.
				_model.currentServer = _view.selectedServer;
				
				// Message to the user that we are loading the rooms from the server.
				message = new GoodMessage(300, 200, 'Loading rooms from the server...');
				_view.showDialog(message);
				
				// Load room reed from the server.
				var url:String = _model.roomFeedUrl;
				var request:URLRequest = new URLRequest(url);
				var loader:URLLoader = new URLLoader();
				loader.addEventListener(Event.COMPLETE, onComplete);
				loader.addEventListener(IOErrorEvent.IO_ERROR, onError);
				loader.load(request);
				
				function onComplete(e:Event):void
				{
					// Remove listeners.
					loader.removeEventListener(Event.COMPLETE, onComplete);
					loader.removeEventListener(IOErrorEvent.IO_ERROR, onError);
					
					// Remove previous message.
					_view.removeDialog(message);
					
					// Parse loaded data into XML.
					var roomFeedXML:XML = new XML(loader.data);
					_model.roomFeedXML = roomFeedXML;
					
					// Set the room list on the view.
					_view.rooms = _model.rooms;
					
					// Listen for room select.
					_view.addEventListener(TileEditorView.ROOM_SELECT, onInitialRoomSelect);
					
					// Show the room drop down.
					_view.roomDropDownVisible = true;
					
					// Message the user to choose a room.
					message = new GoodMessage(300, 200, 'Choose a room to edit.');
					_view.showDialog(message);
				}
				
				function onError(e:IOErrorEvent):void
				{
					// Remove listeners.
					loader.removeEventListener(Event.COMPLETE, onComplete);
					loader.removeEventListener(IOErrorEvent.IO_ERROR, onError);
					
					// Remove previous message.
					_view.removeDialog(message);
					
					// Message that there was an error.
					var alert:GoodAlert = new GoodAlert(300, 200, 'There was an error loading the rooms from the server.', onOk);
					_view.showDialog(alert, true);
					
					function onOk():void
					{
						// Remove the alert.
						_view.removeDialog(alert);
					}
				}
				
				function onInitialRoomSelect(e:Event):void
				{
					// Remove listener.
					_view.removeEventListener(TileEditorView.ROOM_SELECT, onInitialRoomSelect);
					
					// Remove previous message.
					_view.removeDialog(message);
				}
			}
		}
		
		protected function showRoom(roomConfig:RoomConfig):void
		{
			// Show tile map control.
			_view.tileMapControlVisible = true;
			
			// Clear current room on the view.
			_view.clearCurrentRoom();
			
			// Set tile sets.
			_view.tileSets = roomConfig.tileSets;
			
			// Select the first tile set.
			if (roomConfig.tileSets.getAt(0)) _view.selectedTileSet = roomConfig.tileSets.getAt(0);
			
			// Show tile set drop down.
			_view.tileSetDropDownVisible = true;
			
			// Load room background.
			var url:String = _model.getRoomBackgroundUrl(roomConfig.backgroundId);
			var request:URLRequest = new URLRequest(url);
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onBackgroundError);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onBackgroundComplete);
			loader.load(request);
			
			function onBackgroundError(e:IOErrorEvent):void
			{
				// Remove event listeners.
				loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onBackgroundError);
				loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onBackgroundComplete);
			}
			
			function onBackgroundComplete(e:Event):void
			{
				// Remove event listeners.
				loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onBackgroundError);
				loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onBackgroundComplete);
				
				// Set background image.
				_view.roomBackground = loader.content;
			}
		}
		
		protected function saveRoomConfig():void
		{
			// Pass data to server and save room config.
			var roomConfig:RoomConfig = _model.currentRoomConfig;
			var attributes:XML = roomConfig.getAttributesXML();
			var url:String = _model.roomUpdateUrl;
			var request:URLRequest = new URLRequest(url);
			var variables:URLVariables = new URLVariables();
			var requestParams:Object = {roomId: roomConfig.id,
										attributes: escape(attributes.children().toString())};
							
			variables.payload = SdgServiceDelegate.makePayloadXml(requestParams);
			request.data = variables;
			request.method = URLRequestMethod.POST;
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, onComplete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onError);
			loader.load(request);
			
			function onError(e:IOErrorEvent):void
			{
				// Remove event listeners.
				loader.removeEventListener(Event.COMPLETE, onComplete);
				loader.removeEventListener(IOErrorEvent.IO_ERROR, onError);
			}
			
			function onComplete(e:Event):void
			{
				// Remove event listeners.
				loader.removeEventListener(Event.COMPLETE, onComplete);
				loader.removeEventListener(IOErrorEvent.IO_ERROR, onError);
				
				// Message that the room was saved.
				var alert:GoodAlert = new GoodAlert(300, 200, 'The room configuration was saved.', onOk);
				_view.showDialog(alert, true);
				
				function onOk():void
				{
					_view.removeDialog(alert);
				}
			}
		}
		
		protected function addWalkTileSet():void
		{
			// Make sure there is a current room configuration.
			var currentRoomConfig:RoomConfig = _model.currentRoomConfig;
			if (!currentRoomConfig) return;
			
			// There should only be 1 walk tile set so make sure there isn't one already.
			var currentWalkTiles:TileSet = currentRoomConfig.tileSets.getFromId(TileSet.WALK_TILES);
			
			// If there is already a walk tile set,
			// Message the user that they can not add another.
			if (currentWalkTiles)
			{
				var alert:GoodAlert = new GoodAlert(300, 200, 'There is already a walk tile set for this room. You can only have 1.', onOk);
				_view.showDialog(alert, true);
				
				return;
				
				function onOk():void
				{
					_view.removeDialog(alert);
				}
			}
			
			// Create a new walk tile set.
			var cols:uint = _model.defaultTileSetCols;
			var rows:uint = _model.defaultTileSetRows;
			var orginX:uint = _model.defaultTileSetOrginX;
			var orginY:uint = _model.defaultTileSetOrginY;
			var walkTileSet:TileSet = new TileSet(TileSet.WALK_TILES, 'Walk', cols, rows, orginX, orginY, '0');
			
			// Add the tile set to the current room configuration.
			_model.addTileSetToCurrentRoom(walkTileSet);
			
			// Select the new tile set in the view.
			_view.selectedTileSet = walkTileSet;
		}
		
		protected function addSpawnTileSet():void
		{
			// Make sure there is a current room configuration.
			var currentRoomConfig:RoomConfig = _model.currentRoomConfig;
			if (!currentRoomConfig) return;
			
			// Show a dialog that lets the user choose a room to make spawn tiles from.
			var roomDropDown:GoodDropDown = new GoodDropDown(0, 'Rooms', _model.rooms);
			var dialog:GoodDropDownDialog = new GoodDropDownDialog(300, 200, 'Choose the room that the tiles will spawn from.', roomDropDown, onOk, onCancel, 'Make Spawn Tiles', 'Cancel', 0x4ca756, 0xe40022);
			_view.showDialog(dialog, true);
			
			function onOk():void
			{
				// Remove the dialog.
				_view.removeDialog(dialog);
				
				// Make sure the user selected a room.
				var alert:GoodAlert;
				if (roomDropDown.currentItemIndex < 0)
				{
					// The user did not select a room.
					// Alert them.
					alert = new GoodAlert(300, 200, 'You did not select a room.', onAlertOk);
					_view.showDialog(alert, true);
					
					return;
					
					function onAlertOk():void
					{
						// Remove the alert and re-show the dialog.
						_view.removeDialog(alert);
						_view.showDialog(dialog, true);
					}
				}
				
				// Determine which room was selected.
				var selectedRoom:IIdObject = _model.rooms.getAt(roomDropDown.currentItemIndex);
				
				// Determine what the value will be for this new tile set.
				// We will make it the id of the room that the tiles will spawn from.
				var tileSetValue:String = selectedRoom.id.toString();
				
				// Make sure there is NOT already a set of spawn tiles for this room.
				var spawnTileSets:TileSetCollection = currentRoomConfig.tileSets.getMultipleFromId(TileSet.SPAWN_TILES);
				if (spawnTileSets.getMultipleFromValue(tileSetValue).length > 0)
				{
					// This spawn tile set already exists for the current room.
					// Alert the user.
					alert = new GoodAlert(300, 200, 'There is already a spawn tile set that spawns from this room.', onDuplicateAlertOk);
					_view.showDialog(alert, true);
					
					// Select the tile set in the view.
					_view.selectedTileSet = spawnTileSets.getFromValue(tileSetValue);
					
					return;
					
					function onDuplicateAlertOk():void
					{
						// Remove the alert.
						_view.removeDialog(alert);
					}
				}
				
				// Create new tile set.
				var cols:uint = _model.defaultTileSetCols;
				var rows:uint = _model.defaultTileSetRows;
				var orginX:uint = _model.defaultTileSetOrginX;
				var orginY:uint = _model.defaultTileSetOrginY;
				var spawnTileSet:TileSet = new TileSet(TileSet.SPAWN_TILES, 'Spawn from ' + selectedRoom.name, cols, rows, orginX, orginY, tileSetValue);
			
				// Add the tile set to the current room configuration.
				_model.addTileSetToCurrentRoom(spawnTileSet);
				
				// Select the new tile set in the view.
				_view.selectedTileSet = spawnTileSet;
			}
			
			function onCancel():void
			{
				// Remove the dialog and do nothing.
				_view.removeDialog(dialog);
			}
		}
		
		protected function addExitTileSet():void
		{
			// Make sure there is a current room configuration.
			var currentRoomConfig:RoomConfig = _model.currentRoomConfig;
			if (!currentRoomConfig) return;
			
			// Show a dialog that lets the user choose a room to make exit tiles to.
			var roomDropDown:GoodDropDown = new GoodDropDown(0, 'Rooms', _model.rooms);
			var dialog:GoodDropDownDialog = new GoodDropDownDialog(300, 200, 'Choose the room that the tiles will exit to.', roomDropDown, onOk, onCancel, 'Make Exit Tiles', 'Cancel', 0x4ca756, 0xe40022);
			_view.showDialog(dialog, true);
			
			function onOk():void
			{
				// Remove the dialog.
				_view.removeDialog(dialog);
				
				// Make sure the user selected a room.
				var alert:GoodAlert;
				if (roomDropDown.currentItemIndex < 0)
				{
					// The user did not select a room.
					// Alert them.
					alert = new GoodAlert(300, 200, 'You did not select a room.', onAlertOk);
					_view.showDialog(alert, true);
					
					return;
					
					function onAlertOk():void
					{
						// Remove the alert and re-show the dialog.
						_view.removeDialog(alert);
						_view.showDialog(dialog, true);
					}
				}
				
				// Determine which room was selected.
				var selectedRoom:IIdObject = _model.rooms.getAt(roomDropDown.currentItemIndex);
				
				// Determine what the value will be for this new tile set.
				// We will make it the id of the room that the tiles will exit to.
				var tileSetValue:String = selectedRoom.id.toString();
				
				// Make sure there is NOT already a set of exit tiles for this room.
				var exitTileSets:TileSetCollection = currentRoomConfig.tileSets.getMultipleFromId(TileSet.EXIT_TILES);
				if (exitTileSets.getMultipleFromValue(tileSetValue).length > 0)
				{
					// This exit tile set already exists for the current room.
					// Alert the user.
					alert = new GoodAlert(300, 200, 'There is already an exit tile set that exits to this room.', onDuplicateAlertOk);
					_view.showDialog(alert, true);
					
					// Select the tile set in the view.
					_view.selectedTileSet = exitTileSets.getFromValue(tileSetValue);
					
					return;
					
					function onDuplicateAlertOk():void
					{
						// Remove the alert.
						_view.removeDialog(alert);
					}
				}
				
				// Create new tile set.
				var cols:uint = _model.defaultTileSetCols;
				var rows:uint = _model.defaultTileSetRows;
				var orginX:uint = _model.defaultTileSetOrginX;
				var orginY:uint = _model.defaultTileSetOrginY;
				var exitTileSet:TileSet = new TileSet(TileSet.EXIT_TILES, 'Exit to ' + selectedRoom.name, cols, rows, orginX, orginY, tileSetValue);
			
				// Add the tile set to the current room configuration.
				_model.addTileSetToCurrentRoom(exitTileSet);
				
				// Select the new tile set in the view.
				_view.selectedTileSet = exitTileSet;
			}
			
			function onCancel():void
			{
				// Remove the dialog and do nothing.
				_view.removeDialog(dialog);
			}
		}
		
		protected function addWallTileSet():void
		{
			// Make sure there is a current room configuration.
			var currentRoomConfig:RoomConfig = _model.currentRoomConfig;
			if (!currentRoomConfig) return;
			
			// Show a dialog that lets the user choose which type of wall set to create.
			var wallSides:IdObjectCollection = new IdObjectCollection([new IdObject(TileSet.LEFT_WALL_TILES, 'Left Wall'), new IdObject(TileSet.RIGHT_WALL_TILES, 'Right Wall')]);
			var wallSideDropDown:GoodDropDown = new GoodDropDown(0, 'Wall Sides', wallSides);
			var dialog:GoodDropDownDialog = new GoodDropDownDialog(300, 200, 'Choose a wall side.', wallSideDropDown, onOk, onCancel, 'Make Wall Tiles', 'Cancel', 0x4ca756, 0xe40022);
			_view.showDialog(dialog, true);
			
			function onOk():void
			{
				// Remove the dialog.
				_view.removeDialog(dialog);
				
				// Make sure the user selected a side.
				var alert:GoodAlert;
				if (wallSideDropDown.currentItemIndex < 0)
				{
					// The user did not select a side.
					// Alert them.
					alert = new GoodAlert(300, 200, 'You did not select a side.', onAlertOk);
					_view.showDialog(alert, true);
					
					return;
					
					function onAlertOk():void
					{
						// Remove the alert and re-show the dialog.
						_view.removeDialog(alert);
						_view.showDialog(dialog, true);
					}
				}
				
				// Determine selected wall.
				var selectedWall:IIdObject = wallSides.getAt(wallSideDropDown.currentItemIndex);
				
				// Create new tile set.
				var cols:uint = _model.defaultTileSetCols;
				var rows:uint = _model.defaultTileSetRows;
				var orginX:uint = _model.defaultTileSetOrginX;
				var orginY:uint = _model.defaultTileSetOrginY;
				var tileSetValue:String = '0';
				var wallTileSet:TileSet = new TileSet(selectedWall.id, selectedWall.name, cols, rows, orginX, orginY, tileSetValue);
				
				// Add the tile set to the current room configuration.
				_model.addTileSetToCurrentRoom(wallTileSet);
				
				// Select the new tile set in the view.
				_view.selectedTileSet = wallTileSet;
			}
			
			function onCancel():void
			{
				// Remove the dialog and do nothing.
				_view.removeDialog(dialog);
			}
		}
		
		protected function addCustomTileSet():void
		{
			// Make sure there is a current room configuration.
			var currentRoomConfig:RoomConfig = _model.currentRoomConfig;
			if (!currentRoomConfig) return;
			
			// Show a dialog that lets the user specify a custom value.
			var input:GoodInput = new GoodInput(0, 'Custom Value', 100);
			var dialog:GoodInputDialog = new GoodInputDialog(300, 200, 'Specify a custom value.', input, onOk, onCancel, 'Make Custom Tiles', 'Cancel', 0x4ca756, 0xe40022);
			_view.showDialog(dialog, true);
			
			function onOk():void
			{
				// Remove the dialog.
				_view.removeDialog(dialog);
				
				// Make sure the user specified a value.
				var alert:GoodAlert;
				if (input.value.length < 1)
				{
					// The user did not specify a value.
					// Alert them.
					alert = new GoodAlert(300, 200, 'You did not specify a value.', onAlertOk);
					_view.showDialog(alert, true);
					
					return;
					
					function onAlertOk():void
					{
						// Remove the alert and re-show the dialog.
						_view.removeDialog(alert);
						_view.showDialog(dialog, true);
					}
				}
				
				// Set tile set value.
				var tileSetValue:String = input.value;
				
				// Make sure there is not already a custom tile set with this value.
				var customTileSets:TileSetCollection = currentRoomConfig.tileSets.getMultipleFromId(TileSet.CUSTOM_TILES);
				if (customTileSets.getMultipleFromValue(tileSetValue).length > 0)
				{
					// This custom tile set already exists for the current room.
					// Alert the user.
					alert = new GoodAlert(300, 200, 'There is already a custom tile set with this value.', onDuplicateAlertOk);
					_view.showDialog(alert, true);
					
					// Select the tile set in the view.
					_view.selectedTileSet = customTileSets.getFromValue(tileSetValue);
					
					return;
					
					function onDuplicateAlertOk():void
					{
						// Remove the alert.
						_view.removeDialog(alert);
					}
				}
				
				// Create new tile set.
				var cols:uint = _model.defaultTileSetCols;
				var rows:uint = _model.defaultTileSetRows;
				var orginX:uint = _model.defaultTileSetOrginX;
				var orginY:uint = _model.defaultTileSetOrginY;
				var customTileSet:TileSet = new TileSet(TileSet.CUSTOM_TILES, 'Custom ' + tileSetValue, cols, rows, orginX, orginY, tileSetValue);
			
				// Add the tile set to the current room configuration.
				_model.addTileSetToCurrentRoom(customTileSet);
				
				// Select the new tile set in the view.
				_view.selectedTileSet = customTileSet;
			}
			
			function onCancel():void
			{
				// Remove the dialog and do nothing.
				_view.removeDialog(dialog);
			}
		}
		
		protected function showServer():void
		{
			// Get server.
			var server:IIdObject = _model.currentServer;
			
			// Message to the user that we are loading the rooms from the server.
			var message:GoodMessage = new GoodMessage(300, 200, 'Loading rooms from the server...');
			_view.showDialog(message);
			
			// Load room feed from the server.
			var url:String = _model.roomFeedUrl;
			var request:URLRequest = new URLRequest(url);
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, onComplete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onError);
			loader.load(request);
			
			function onComplete(e:Event):void
			{
				// Remove listeners.
				loader.removeEventListener(Event.COMPLETE, onComplete);
				loader.removeEventListener(IOErrorEvent.IO_ERROR, onError);
				
				// Remove previous message.
				_view.removeDialog(message);
				
				// Parse loaded data into XML.
				var roomFeedXML:XML = new XML(loader.data);
				_model.roomFeedXML = roomFeedXML;
				
				// Set the room list on the view.
				_view.rooms = _model.rooms;
				
				// Listen for room select.
				_view.addEventListener(TileEditorView.ROOM_SELECT, onInitialRoomSelect);
				
				// Show the room drop down.
				_view.roomDropDownVisible = true;
				
				// Message the user to choose a room.
				message = new GoodMessage(300, 200, 'Choose a room to edit.');
				_view.showDialog(message);
			}
			
			function onError(e:IOErrorEvent):void
			{
				// Remove listeners.
				loader.removeEventListener(Event.COMPLETE, onComplete);
				loader.removeEventListener(IOErrorEvent.IO_ERROR, onError);
				
				// Remove previous message.
				_view.removeDialog(message);
				
				// Message that there was an error.
				var alert:GoodAlert = new GoodAlert(300, 200, 'There was an error loading the rooms from the server.', onOk);
				_view.showDialog(alert, true);
				
				function onOk():void
				{
					// Remove the alert.
					_view.removeDialog(alert);
				}
			}
			
			function onInitialRoomSelect(e:Event):void
			{
				// Remove listener.
				_view.removeEventListener(TileEditorView.ROOM_SELECT, onInitialRoomSelect);
				
				// Remove previous message.
				_view.removeDialog(message);
			}
		}
		
		////////////////////
		// EVENT HANDLERS
		////////////////////
		
		private function onSaveClick(e:Event):void
		{
			// Use a dialog to make sure the user wants to save the room configuration.
			var dialog:GoodDialog = new GoodDialog(300, 200, 'Are you sure that you want to save the room configuration?', onSaveConfirm, onSaveCancel, 'Yes, Save', 'Cancel', 0x4ca756, 0xe40022);
			_view.showDialog(dialog, true);
			
			function onSaveConfirm():void
			{
				_view.removeDialog(dialog);
				saveRoomConfig();
			}
			
			function onSaveCancel():void
			{
				_view.removeDialog(dialog);
			}
		}
		
		private function onAddTileSetClick(e:Event):void
		{
			// Allow the user the process of adding a tile set.
			
			_view.removeEventListener(TileEditorView.ADD_TILE_SET_CLICK, onAddTileSetClick);
			
			// Show a dialog that lets the user pick which type of tile set they want to add.
			var dialog:GoodButtonListDialog = new GoodButtonListDialog(300, 320, 'Which type of tile set would you like to add?', ['Walk', 'Spawn', 'Exit', 'Wall', 'Custom', 'Cancel'], [onWalkSelect, onSpawnSelect, onExitSelect, onWallSelect, onCustomSelect, onCancelSelect], [0x677192, 0x677192, 0x677192, 0x677192, 0x677192, 0xff0000]);
			_view.showDialog(dialog, true);
			
			function onWalkSelect():void
			{
				finish();
				
				addWalkTileSet();
			}
			
			function onSpawnSelect():void
			{
				finish();
				
				addSpawnTileSet();
			}
			
			function onExitSelect():void
			{
				finish();
				
				addExitTileSet();
			}
			
			function onWallSelect():void
			{
				finish();
				
				addWallTileSet();
			}
			
			function onCustomSelect():void
			{
				finish();
				
				addCustomTileSet();
			}
			
			function onCancelSelect():void
			{
				finish();
			}
			
			function finish():void
			{
				// Remove the dialog.
				_view.removeDialog(dialog);
				
				_view.addEventListener(TileEditorView.ADD_TILE_SET_CLICK, onAddTileSetClick);
			}
		}
		
		private function onRemoveTileSetClick(e:Event):void
		{
			// Make sure the user wants to remove the current tile set.
			
			// Get a reference to the current tile set.
			var currentTileSet:TileSet = _view.selectedTileSet;
			
			// Show a dialog to the user to make sure they want to remove the tile set.
			var dialog:GoodDialog = new GoodDialog(300, 200, 'Are you sure that you want to remove the "' + currentTileSet.name + '" tile set?', onConfirm, onCancel, 'Yes', 'Cancel', 0x4ca756, 0xe40022);
			_view.showDialog(dialog, true);
			
			function onConfirm():void
			{
				// Remove the dialog.
				_view.removeDialog(dialog);
				
				// Remove the tile set.
				_model.removeTileSetFromCurrentRoom(currentTileSet);
				
				// Select the first tile set on the view.
				var firstTileSet:TileSet = _model.currentRoomConfig.tileSets.getAt(0);
				_view.selectedTileSet = firstTileSet;
			}
			
			function onCancel():void
			{
				// Remove the dialog and do nothing.
				_view.removeDialog(dialog);
			}
		}
		
		private function onTileSetsUpdate(e:Event):void
		{
			// Set tile sets on the view.
			_view.tileSets = _model.currentRoomConfig.tileSets;
		}
		
		private function onServerSelect(e:Event):void
		{
			// Get server.
			var server:ServerModel = _view.selectedServer;
			
			// Make sure this is not the server that is already selected.
			var currentServer:ServerModel = _model.currentServer;
			if (server == currentServer) return;
			
			// Check if there is a current currentServer.
			if (currentServer)
			{
				// Show a dialog to make sure the user wants to change the server.
				var dialog:GoodDialog = new GoodDialog(300, 200, 'Are you sure you want to change servers? You will lose unsaved changes.', onConfirm, onCancel, 'Yes', 'Cancel', 0x4ca756, 0xe40022);
				_view.showDialog(dialog, true);
			}
			else
			{
				// If there is not a current server,
				// Do the server select.
				doSelect();
			}
			
			function onConfirm():void
			{
				// Remove the dialog.
				_view.removeDialog(dialog);
				
				// Do the new server select.
				doSelect();
			}
			
			function onCancel():void
			{
				// Remove the dialog.
				_view.removeDialog(dialog);
				
				// Re-select the current server on the view.
				_view.selectedServer = currentServer;
			}
			
			function doSelect():void
			{
				// Set current server on model.
				_model.currentServer = server;
				
				showServer();
			}
		}
		
		private function onRoomSelect(e:Event):void
		{
			// Get room.
			var room:IIdObject = _view.selectedRoom;
			
			// Make sure this is not the room that is already selected.
			var currentRoom:IIdObject = _model.currentRoom;
			if (room == currentRoom) return;
			
			// Check if there is a current room.
			if (currentRoom)
			{
				// Show a dialog to make sure the user wants to change the room.
				var dialog:GoodDialog = new GoodDialog(300, 200, 'Are you sure you want to change rooms? You will lose unsaved changes.', onConfirm, onCancel, 'Yes', 'Cancel', 0x4ca756, 0xe40022);
				_view.showDialog(dialog, true);
			}
			else
			{
				// If there is not a current room,
				// Do the room select.
				doSelect();
			}
			
			function onConfirm():void
			{
				// Remove the dialog.
				_view.removeDialog(dialog);
				
				// Do the new room select.
				doSelect();
			}
			
			function onCancel():void
			{
				// Remove the dialog.
				_view.removeDialog(dialog);
				
				// Re-select the current room on the view.
				_view.selectedRoom = _model.currentRoom;
			}
			
			function doSelect():void
			{
				// Set current room on model.
				_model.currentRoom = room;
				
				// Get current room config.
				var roomConfig:RoomConfig = _model.currentRoomConfig;
				
				showRoom(roomConfig);
			}
		}
		
	}
}