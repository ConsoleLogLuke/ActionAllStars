package com.sdg.tileeditor
{
	import com.sdg.model.IIdObject;
	import com.sdg.model.IdObject;
	import com.sdg.model.IdObjectCollection;
	import com.sdg.model.RoomConfig;
	import com.sdg.model.ServerModel;
	import com.sdg.model.ServerModelCollection;
	import com.sdg.sim.map.TileSet;
	import com.sdg.sim.map.TileSetCollection;
	
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;

	public class TileEditorModel extends EventDispatcher
	{
		public static const CONFIG_READY:String = 'config ready';
		public static const CONFIG_URL:String = 'config/tileEditorConfig.xml';
		public static const TILE_SETS_UPDATE:String = 'new tile set';
		
		protected var _view:TileEditorView;
		protected var _controller:TileEditorController;
		
		protected var _viewContainer:DisplayObjectContainer;
		protected var _currentServer:ServerModel;
		protected var _servers:ServerModelCollection;
		protected var _roomFeedXML:XML;
		protected var _rooms:IdObjectCollection;
		protected var _roomConfigs:Array;
		protected var _currentRoom:IIdObject;
		protected var _currentRoomConfig:RoomConfig;
		protected var _defaultTileSetCols:uint;
		protected var _defaultTileSetRows:uint;
		protected var _defaultTileSetOrginX:uint;
		protected var _defaultTileSetOrginY:uint;
		
		public function TileEditorModel()
		{
			super();
			
			_defaultTileSetCols = 43;
			_defaultTileSetRows = 43;
			_defaultTileSetOrginX = 10;
			_defaultTileSetOrginY = 10;
			
			// Create view.
			_view = new TileEditorView();
			
			// Create controller.
			_controller = new TileEditorController(this);
			
			// Load configuration.
			addEventListener(CONFIG_READY, onConfigReady);
			loadConfig();
			
			function onConfigReady():void
			{
				// Remove listener.
				removeEventListener(CONFIG_READY, onConfigReady);
				
				// Initialize.
				init();
			}
		}
		
		public function getRoomBackgroundUrl(backgroundId:uint):String
		{
			var domain:String = 'mdr-dev01';
			return 'http://' + domain + '/test/static/roomBackground?backgroundId=' + backgroundId.toString();
		}
		
		public function getRoomConfig(room:IIdObject):RoomConfig
		{
			var index:uint = _rooms.indexOf(room);
			var roomConfig:RoomConfig = _roomConfigs[index] as RoomConfig;
			
			return roomConfig;
		}
		
		public function addTileSetToCurrentRoom(tileSet:TileSet):void
		{
			// Make sure there is a current room config.
			if (!_currentRoomConfig) return;
			
			// Add the tile set.
			_currentRoomConfig.tileSets.push(tileSet);
			
			// Dispatch a tile sets update event.
			dispatchEvent(new Event(TILE_SETS_UPDATE));
		}
		
		public function removeTileSetFromCurrentRoom(tileSet:TileSet):void
		{
			// Make sure there is a current room config.
			if (!_currentRoomConfig) return;
			
			// Make sure this tile set is part of the current room config.
			var index:int = _currentRoomConfig.tileSets.indexOf(tileSet);
			if (index < 0) return;
			
			// Remove the tile set.
			_currentRoomConfig.tileSets.removeAt(index);
			
			// Dispatch a tile sets update event.
			dispatchEvent(new Event(TILE_SETS_UPDATE));
		}
		
		//////////////////////
		// INTERNAL METHODS
		//////////////////////
		
		
		
		//////////////////////
		// PROTECTED METHODS
		//////////////////////
		
		protected function init():void
		{	
			// Initialize controller.
			_controller.init();
		}
		
		protected function loadConfig():void
		{
			var url:String = CONFIG_URL;
			var request:URLRequest = new URLRequest(url);
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, onComplete);
			loader.addEventListener(ProgressEvent.PROGRESS, onProgress);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onError);
			loader.load(request);
			
			function onError(e:IOErrorEvent):void
			{
				// Remove event listeners.
				remove();
			}
			
			function onProgress(e:ProgressEvent):void
			{
				
			}
			
			function onComplete(e:Event):void
			{
				// Remove event listeners.
				remove();
				
				// Parse config data into xml.
				var configXML:XML = new XML(loader.data);
				
				// Parse server collection.
				_servers = ServerModel.ServerModelCollectionFromXML(configXML.child('servers'));
				
				// Dispatch config ready event.
				dispatchEvent(new Event(CONFIG_READY));
			}
			
			function remove():void
			{
				// Remove event listeners.
				loader.removeEventListener(Event.COMPLETE, onComplete);
				loader.removeEventListener(ProgressEvent.PROGRESS, onProgress);
				loader.removeEventListener(IOErrorEvent.IO_ERROR, onError);
			}
		}
		
		protected function addDefaultWalkTiles(roomConfig:RoomConfig):void
		{
			// Make sure there aren't any walk tiles.
			var walkTileSet:TileSet = roomConfig.tileSets.getFromId(TileSet.WALK_TILES);
			if (walkTileSet != null) return;
			
			// Create default walk tile set.
			walkTileSet = new TileSet(TileSet.WALK_TILES, 'Walk', _defaultTileSetCols, _defaultTileSetRows, _defaultTileSetOrginX, _defaultTileSetOrginY);
			
			// Add the tile set to the collection.
			roomConfig.tileSets.push(walkTileSet);
		}
		
		//////////////////////
		// GET/SET METHODS
		//////////////////////
		
		public function get view():TileEditorView
		{
			return _view;
		}
		
		public function get currentServer():ServerModel
		{
			return _currentServer;
		}
		public function set currentServer(value:ServerModel):void
		{
			if (value == _currentServer) return;
			_currentServer = value;
		}
		
		public function get roomFeedUrl():String
		{
			return 'http://' + _currentServer.domain + '/test/room/list';
		}
		
		public function get servers():ServerModelCollection
		{
			return _servers;
		}
		
		public function get rooms():IdObjectCollection
		{
			return _rooms;
		}
		
		public function set roomFeedXML(value:XML):void
		{
			_roomFeedXML = value;
			
			// Create room configurations from xml feed.
			var i:uint = 0;
			var rooms:IdObjectCollection = new IdObjectCollection();
			var roomConfigs:Array = [];
			var roomsXML:XML = new XML(_roomFeedXML.allRooms);
			while (roomsXML.room[i])
			{
				var roomXML:XML = roomsXML.room[i];
				var id:uint = roomXML.roomId;
				var name:String = roomXML.name;
				var avatarId:uint = roomXML.avatarId;
				var attributes:String = roomXML.attributes;
				var attributesXML:XML = new XML('<attributes>' + attributes + '</attributes>');
				var backgroundId:uint = (attributesXML.backgroundId) ? attributesXML.backgroundId : 0;
				var soundId:int = 0;
				var soundVolume:int = 100;
				if (attributesXML.soundId)
				{
					soundId = attributesXML.soundId;
					soundVolume = (attributesXML.soundId.@volume) ? attributesXML.soundId.@volume : 100;
				}
				var storeId:uint = (attributesXML.storeId) ? attributesXML.storeId : 0;
				var tileSets:TileSetCollection = (attributesXML.tiles) ? TileSet.TileSetCollectionFromEncodedString(attributesXML.tiles) : new TileSetCollection();
				
				var roomConfig:RoomConfig = new RoomConfig(id, name, avatarId, backgroundId, soundId, soundVolume, storeId, tileSets);
				
				// Make sure there are walk tiles.
				addDefaultWalkTiles(roomConfig);
				
				rooms.push(new IdObject(id, name));
				roomConfigs.push(roomConfig);
				
				i++;
			}
			
			_rooms = rooms;
			_roomConfigs = roomConfigs;
		}
		
		public function get currentRoom():IIdObject
		{
			return _currentRoom;
		}
		public function set currentRoom(value:IIdObject):void
		{
			// Make sure it is a valid room.
			var index:int = _rooms.indexOf(value);
			if (index < 0) return;
			
			// Set new value.
			_currentRoom = value;
			
			// Set current room config.
			_currentRoomConfig = _roomConfigs[index] as RoomConfig;
		}
		
		public function get currentRoomConfig():RoomConfig
		{
			return _currentRoomConfig;
		}
		
		public function get roomUpdateUrl():String
		{
			return 'http://' + _currentServer.domain + '/webtools/room/update';
		}
		
		public function get defaultTileSetCols():uint
		{
			return _defaultTileSetCols;
		}
		
		public function get defaultTileSetRows():uint
		{
			return _defaultTileSetRows;
		}
		
		public function get defaultTileSetOrginX():uint
		{
			return _defaultTileSetOrginX;
		}
		
		public function get defaultTileSetOrginY():uint
		{
			return _defaultTileSetOrginY;
		}
		
	}
}