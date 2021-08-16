package com.sdg.tileeditor
{
	import com.good.goodgraphics.GoodMinus;
	import com.good.goodgraphics.GoodPlus;
	import com.good.goodgraphics.GoodRect;
	import com.good.goodui.GoodButton;
	import com.good.goodui.GoodDialogControl;
	import com.good.goodui.GoodDropDown;
	import com.good.goodui.GoodIconButton;
	import com.sdg.model.IIdObject;
	import com.sdg.model.IdObjectCollection;
	import com.sdg.model.ServerModel;
	import com.sdg.model.ServerModelCollection;
	import com.sdg.sim.map.TileMap;
	import com.sdg.sim.map.TileSet;
	import com.sdg.sim.map.TileSetCollection;
	import com.sdg.view.FluidView;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	public class TileEditorView extends FluidView
	{
		public static const SERVER_SELECT:String = 'server select';
		public static const ROOM_SELECT:String = 'room select';
		public static const TILE_SET_SELECT:String = 'room select';
		public static const SAVE_CLICK:String = 'save click';
		public static const ADD_TILE_SET_CLICK:String = 'add tile set click';
		public static const REMOVE_TILE_SET_CLICK:String = 'remove tile set click';
		
		protected var _backing:Sprite;
		protected var _topBar:GoodRect;
		protected var _serverDropDown:GoodDropDown;
		protected var _roomDropDown:GoodDropDown;
		protected var _tileSetDropDown:GoodDropDown;
		protected var _tileMapControl:TileMapControl;
		protected var _saveButton:GoodButton;
		protected var _dialogLayer:Sprite;
		protected var _dialogShadow:DropShadowFilter;
		protected var _addTileSetButton:GoodIconButton;
		protected var _removeTileSetButton:GoodIconButton;
		protected var _dialogControl:GoodDialogControl;
		protected var _mouseCoordinateField:TextField;
		
		protected var _servers:ServerModelCollection;
		protected var _rooms:IdObjectCollection;
		protected var _roomBackground:DisplayObject;
		protected var _tileSets:TileSetCollection;
		
		public function TileEditorView()
		{
			super(100, 100);
			
			_dialogShadow = new DropShadowFilter(4, 45, 0, 0.6, 16, 16);
			
			_backing = new Sprite();
			
			_tileMapControl = new TileMapControl(925, 665, 33, 33);
			_tileMapControl.isoAngle = TileMap.ISO_ANGLE;
			_tileMapControl.orginScreenOffset = new Point(925 / 2, 100);
			_tileMapControl.visible = false;
			_tileMapControl.addEventListener(TileMapControl.MOUSE_COORDINATES, onTileMapMouseCoordinates);
			
			_topBar = new GoodRect(_width, 40, 0, 0xa9a9a9);
			
			_serverDropDown = new GoodDropDown(0, 'Servers');
			_serverDropDown.width = 130;
			_serverDropDown.addEventListener(GoodDropDown.ITEM_SELECT, onServerItemSelect);
			
			_roomDropDown = new GoodDropDown(0, 'Rooms');
			_roomDropDown.color = 0x929ab4;
			_roomDropDown.width = 230;
			_roomDropDown.addEventListener(GoodDropDown.ITEM_SELECT, onRoomSelect);
			
			_tileSetDropDown = new GoodDropDown(0, 'Tile Sets');
			_tileSetDropDown.color = 0x1969b3;
			_tileSetDropDown.width = 280;
			_tileSetDropDown.addEventListener(GoodDropDown.ITEM_SELECT, onTileSetSelect);
			
			_addTileSetButton = new GoodIconButton('Add Tile Set', new GoodPlus(10, 10, 0xffffff, 0.22), _tileSetDropDown.color);
			_addTileSetButton.useLabel = false;
			_addTileSetButton.addEventListener(MouseEvent.CLICK, onAddTileSetClick);
			
			_removeTileSetButton = new GoodIconButton('Remove Tile Set', new GoodMinus(10, 10, 0xffffff, 0.22), 0xe40022);
			_removeTileSetButton.useLabel = false;
			_removeTileSetButton.addEventListener(MouseEvent.CLICK, onRemoveTileSetClick);
			
			_saveButton = new GoodButton('Save', 0x4ca756);
			_saveButton.visible = false
			_saveButton.addEventListener(MouseEvent.CLICK, onSaveClick);
			
			_mouseCoordinateField = new TextField();
			_mouseCoordinateField.defaultTextFormat = new TextFormat('Arial', 18, 0xffffff, true);
			_mouseCoordinateField.autoSize = TextFieldAutoSize.RIGHT;
			_mouseCoordinateField.selectable = false;
			_mouseCoordinateField.filters = [new DropShadowFilter(1, 45, 0, 1, 3, 3)];
			
			_dialogLayer = new Sprite();
			_dialogControl = new GoodDialogControl(_width, _height);
			
			// Add children.
			addChild(_backing);
			addChild(_tileMapControl);
			addChild(_mouseCoordinateField);
			addChild(_saveButton);
			addChild(_dialogLayer);
			addChild(_dialogControl);
			addChild(_topBar);
			_topBar.addChild(_serverDropDown);
			_topBar.addChild(_roomDropDown);
			_topBar.addChild(_tileSetDropDown);
			_topBar.addChild(_addTileSetButton);
			_topBar.addChild(_removeTileSetButton);
			
			render();
		}
		
		public function destroy():void
		{
			// Remove all event listeners.
			_serverDropDown.removeEventListener(GoodDropDown.ITEM_SELECT, onServerItemSelect);
			_roomDropDown.removeEventListener(GoodDropDown.ITEM_SELECT, onRoomSelect);
			_tileSetDropDown.removeEventListener(GoodDropDown.ITEM_SELECT, onTileSetSelect);
			_saveButton.removeEventListener(MouseEvent.CLICK, onSaveClick);
			_addTileSetButton.removeEventListener(MouseEvent.CLICK, onAddTileSetClick);
			_tileMapControl.removeEventListener(TileMapControl.MOUSE_COORDINATES, onTileMapMouseCoordinates);
		}
		
		override protected function render():void
		{
			_backing.graphics.clear();
			_backing.graphics.beginFill(0x404040);
			_backing.graphics.drawRect(0, 0, _width, _height);
			
			var margin:Number = 10;
			
			_topBar.width = _width;
			_topBar.height = 40;
			_topBar.y = -1;
			
			_serverDropDown.x = margin;
			_serverDropDown.y = _topBar.height / 2 - _serverDropDown.height / 2;
			
			_roomDropDown.x = _serverDropDown.x + _serverDropDown.width + margin;
			_roomDropDown.y = _serverDropDown.y;
			
			_tileSetDropDown.x = _roomDropDown.x + _roomDropDown.width + margin;
			_tileSetDropDown.y = _serverDropDown.y;
			
			_addTileSetButton.x = _tileSetDropDown.x + _tileSetDropDown.width + margin;
			_addTileSetButton.y = _serverDropDown.y;
			
			_removeTileSetButton.x = _addTileSetButton.x + _addTileSetButton.width + margin;
			_removeTileSetButton.y = _serverDropDown.y;
			
			// Scale map control if necesary.
			var mapMaxW:Number = Math.min(_width - margin * 2, 925);
			var mapMaxH:Number = Math.min(_height - _topBar.height - _saveButton.height - margin * 3, 665);
			var newMapScale:Number = Math.min(mapMaxW / _tileMapControl.width, mapMaxH / _tileMapControl.height);
			_tileMapControl.scaleX = _tileMapControl.scaleY = newMapScale;
			var newMapW:Number = _tileMapControl.width * newMapScale;
			var newMapH:Number = _tileMapControl.height * newMapScale;
			
			_tileMapControl.x = _width / 2 - newMapW / 2;
			_tileMapControl.y = _topBar.y + _topBar.height + margin;
			
			_saveButton.x = _tileMapControl.x;
			_saveButton.y = _tileMapControl.y + newMapH + margin;
			
			_mouseCoordinateField.x = _tileMapControl.x + newMapW;
			_mouseCoordinateField.y = _saveButton.y;
			
			_dialogControl.width = _width;
			_dialogControl.height = _height;
		}
		
		public function showDialog(dialog:DisplayObject, isModal:Boolean = false):void
		{
			_dialogControl.addDialog(dialog, isModal);
		}
		
		public function removeDialog(dialog:DisplayObject):void
		{
			_dialogControl.removeDialog(dialog);
		}
		
		public function clearCurrentRoom():void
		{
			_tileMapControl.removeTemplate();
			
			// Clear the tile map control.
			_tileMapControl.clearTileMap(true);
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		public function set servers(value:ServerModelCollection):void
		{
			_servers = value;
			_serverDropDown.items = new IdObjectCollection(_servers.toArray());
		}
		
		public function get selectedServer():ServerModel
		{
			return _servers.getAt(_serverDropDown.currentItemIndex);
		}
		public function set selectedServer(value:ServerModel):void
		{
			// Determine index of server.
			var index:int = _servers.indexOf(value);
			
			_serverDropDown.currentItemIndex = index;
		}
		
		public function set rooms(value:IdObjectCollection):void
		{
			_rooms = value;
			_roomDropDown.items = _rooms;
		}
		
		public function get selectedRoom():IIdObject
		{
			return _rooms.getAt(_roomDropDown.currentItemIndex);
		}
		public function set selectedRoom(value:IIdObject):void
		{
			// Determine index of tile set.
			var index:int = _rooms.indexOf(value);
			
			_roomDropDown.currentItemIndex = index;
		}
		
		public function get roomBackground():DisplayObject
		{
			return _roomBackground;
		}
		public function set roomBackground(value:DisplayObject):void
		{
			_roomBackground = value;
			_tileMapControl.template = _roomBackground;
		}
		
		public function get tileMapControlVisible():Boolean
		{
			return _tileMapControl.visible;
		}
		public function set tileMapControlVisible(value:Boolean):void
		{
			_tileMapControl.visible = value;
			_saveButton.visible = value;
		}
		
		public function get tileSets():TileSetCollection
		{
			return _tileSets;
		}
		public function set tileSets(value:TileSetCollection):void
		{
			_tileSets = value;
			
			var tileSets:IdObjectCollection = new IdObjectCollection(_tileSets.toArray());
			_tileSetDropDown.items = tileSets;
		}
		
		public function get selectedTileSet():TileSet
		{
			return _tileSets.getAt(_tileSetDropDown.currentItemIndex);
		}
		public function set selectedTileSet(value:TileSet):void
		{
			// Determine index of tile set.
			var index:int = _tileSets.indexOf(value);
			
			_tileSetDropDown.currentItemIndex = index;
		}
		
		public function get roomDropDownVisible():Boolean
		{
			return _roomDropDown.visible;
		}
		public function set roomDropDownVisible(value:Boolean):void
		{
			_roomDropDown.visible = value;
		}
		
		public function get tileSetDropDownVisible():Boolean
		{
			return _tileSetDropDown.visible;
		}
		public function set tileSetDropDownVisible(value:Boolean):void
		{
			_tileSetDropDown.visible = value;
			_addTileSetButton.visible = value;
			_removeTileSetButton.visible = value;
		}
		
		////////////////////
		// EVENT HANDLERS
		////////////////////
		
		private function onServerItemSelect(e:Event):void
		{
			// Dispatch server select event.
			dispatchEvent(new Event(SERVER_SELECT));
		}
		
		private function onRoomSelect(e:Event):void
		{
			// Dispatch a room select event.
			dispatchEvent(new Event(ROOM_SELECT));
		}
		
		private function onTileSetSelect(e:Event):void
		{
			// Dispatch a tile set select event.
			dispatchEvent(new Event(TILE_SET_SELECT));
			
			// Pass tile data to the tile map control.
			var tileSet:TileSet = selectedTileSet;
			_tileMapControl.setNewTileSpace(tileSet.cols, tileSet.rows, tileSet.orginX, tileSet.orginY, tileSet.byteArray);
		}
		
		private function onSaveClick(e:MouseEvent):void
		{
			// Dispatch a save click event.
			dispatchEvent(new Event(SAVE_CLICK));
		}
		
		private function onAddTileSetClick(e:MouseEvent):void
		{
			// Dispatch a add tile set click event.
			dispatchEvent(new Event(ADD_TILE_SET_CLICK));
		}
		
		private function onRemoveTileSetClick(e:MouseEvent):void
		{
			// Dispatch a add tile set click event.
			dispatchEvent(new Event(REMOVE_TILE_SET_CLICK));
		}
		
		private function onTileMapMouseCoordinates(e:Event):void
		{
			var mouseCoordinates:Point = _tileMapControl.mouseCoordinates;
			if (mouseCoordinates != null)
			{
				_mouseCoordinateField.text = '(' + mouseCoordinates.x + ', ' + mouseCoordinates.y + ')';
			}
			else
			{
				_mouseCoordinateField.text = '';
			}
		}
		
	}
}