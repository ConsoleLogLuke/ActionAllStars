package com.sdg.tileeditor
{
	import com.sdg.sim.map.TileMap;
	import com.sdg.view.FluidView;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.system.System;
	import flash.utils.ByteArray;

	public class TileMapControl extends FluidView
	{
		public static const MOUSE_COORDINATES:String = 'new mouse coordinates';
		
		protected var _orginOffset:Point;
		protected var _orginScreenOffset:Point;
		protected var _tileSize:Number;
		protected var _tileMap:Sprite;
		protected var _cols:uint;
		protected var _rows:uint;
		protected var _isoAngle:Number;
		protected var _buffer:ByteArray;
		protected var _isWriting:Boolean;
		protected var _writeValue:Boolean;
		protected var _template:DisplayObject;
		protected var _mask:Sprite;
		protected var _maskedContent:Sprite;
		protected var _drawLayer:Sprite;
		protected var _tiles:Array;
		protected var _tileOverAlpha:Number;
		protected var _tileSelectedAlpha:Number;
		protected var _mouseCoordinates:Point;
		
		public function TileMapControl(width:Number, height:Number, cols:uint, rows:uint)
		{
			super(width, height);
			
			_orginOffset = new Point(0, 0);
			_orginScreenOffset = new Point(_width / 2, _height / 2);
			_tileSize = TileMap.TILE_SIZE;
			_cols = cols;
			_rows = rows;
			_isoAngle = 45;
			_buffer = new ByteArray();
			_isWriting = false;
			_writeValue = false;
			_tiles = [];
			_tileOverAlpha = 0.4;
			_tileSelectedAlpha = 0.8;
			
			_mask = new Sprite();
			addChild(_mask);
			
			_maskedContent = new Sprite();
			_maskedContent.mask = _mask;
			addChild(_maskedContent);
			
			_tileMap = new Sprite();
			_maskedContent.addChild(_tileMap);
			
			_drawLayer = new Sprite();
			addChild(_drawLayer);
			
			render();
			
			addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		}
		
		override protected function render():void
		{
			super.render();
			
			var matrix:Matrix = new Matrix();
			matrix.rotate(Math.PI / 4);
			matrix.scale(1, (_isoAngle / 90));
			
			_tileMap.transform.matrix = matrix;
			_tileMap.x = _orginScreenOffset.x;
			_tileMap.y = _orginScreenOffset.y;
			
			_drawLayer.graphics.clear();
			_drawLayer.graphics.lineStyle(1, 0);
			_drawLayer.graphics.drawRect(0, 0, _width, _height);
			
			_mask.graphics.clear();
			_mask.graphics.beginFill(0x00ff00);
			_mask.graphics.drawRect(0, 0, _width, _height);
		}
		
		protected function drawTileMap():void
		{
			var i:uint = 0;
			var xLen:uint = _cols;
			var yLen:uint = _rows;
			var len:uint = xLen * yLen;
			var offX:Number = -_orginOffset.x;
			var offY:Number = -_orginOffset.y;
			var xPos:uint;
			var yPos:uint;
			for (i; i < len; i++)
			{
				xPos = (i - (Math.floor(i / xLen) * xLen)) + offX;
				yPos = Math.floor(i / xLen) + offY;
				
				var tile:TileEditorTile = new TileEditorTile(_tileSize, _tileSize, new Point(xPos, yPos));
				tile.x = (_tileSize) * (i - (Math.floor(i / xLen) * xLen)) + offX * _tileSize;
				tile.y = Math.floor(i / xLen) * (_tileSize) + offY * _tileSize;
				tile.fillColor = 0x1969b3;
				tile.fillAlpha = (_buffer[i]) ? _tileSelectedAlpha : 0;
				tile.lineAlpha = 0.2;
				tile.cacheAsBitmap = true;
				tile.addEventListener(MouseEvent.ROLL_OVER, onTileOver);
				tile.addEventListener(MouseEvent.MOUSE_DOWN, onTileDown);
				
				_tileMap.addChild(tile);
				
				_tiles.push(tile);
			}
			
			render();
		}
		
		public function clearTileMap(resetBuffer:Boolean = false):void
		{
			// Remove old map from display.
			_maskedContent.removeChild(_tileMap);
			_tileMap = null;
			
			// Remove event listeners from tiles.
			var i:uint = 0;
			var len:uint = _tiles.length;
			for (i; i < len; i++)
			{
				var tile:TileEditorTile = _tiles[i] as TileEditorTile;
				tile.removeEventListener(MouseEvent.ROLL_OVER, onTileOver);
				tile.removeEventListener(MouseEvent.MOUSE_DOWN, onTileDown);
			}
			
			// Clear tile array.
			_tiles = [];
			
			// Force garabge collection.
			System.gc();
			
			// Create new tile map.
			_tileMap = new Sprite();
			_maskedContent.addChild(_tileMap);
			
			// Clear the buffer.
			if (resetBuffer == true) _buffer = new ByteArray();
		}
		
		protected function makeTile():Sprite
		{
			var tile:Sprite = new Sprite();
			tile.graphics.lineStyle(1, 0, 1);
			tile.graphics.drawRect(0, 0, _tileSize, _tileSize);
			
			return tile;
		}
		
		protected function writeToBuffer(x:int, y:int, value:Boolean):void
		{
			x += _orginOffset.x;
			y += _orginOffset.y;
			var index:uint = _cols * y + x;
			
			_buffer[index] = value;
		}
		
		protected function readFromBuffer(x:uint, y:uint):Boolean
		{
			x += _orginOffset.x;
			y += _orginOffset.y;
			var index:uint = _cols * y + x;
			
			return _buffer[index];
		}
		
		protected function traceBuffer():void
		{
			var i:uint = 0;
			var len:uint = _buffer.length;
			var stream:String = '';
			for (i; i < len; i++)
			{
				stream += (_buffer[i]) ? '1' : '0';
			}
			
			trace(stream);
		}
		
		public function setNewTileSpace(cols:uint, rows:uint, orginX:uint, orginY:uint, byteArray:ByteArray):void
		{
			_cols = cols;
			_rows = rows;
			_orginOffset = new Point(orginX, orginY);
			_buffer = byteArray;
			
			// Reset the tile map.
			resetTileMap();
		}
		
		public function resetTileMap(resetBuffer:Boolean = false):void
		{
			// Clear current map.
			clearTileMap(resetBuffer);
			
			// Re-draw the map.
			drawTileMap();
		}
		
		public function removeTemplate():void
		{
			// Remove template.
			if (_template)
			{
				_maskedContent.removeChild(_template);
				_template = null;
			}
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		public function get template():DisplayObject
		{
			return _template;
		}
		public function set template(value:DisplayObject):void
		{
			if (value == _template) return;
			
			// Remove previous.
			if (_template)
			{
				_maskedContent.removeChild(_template);
			}
			
			// Set new.
			_template = value;
			_maskedContent.addChildAt(_template, 0);
		}
		
		public function get orginOffset():Point
		{
			return _orginOffset;
		}
		public function set orginOffset(value:Point):void
		{
			_orginOffset = value;
			render();
		}
		
		public function get orginScreenOffset():Point
		{
			return _orginScreenOffset;
		}
		public function set orginScreenOffset(value:Point):void
		{
			_orginScreenOffset = value;
			render();
		}
		
		public function get isoAngle():Number
		{
			return _isoAngle;
		}
		public function set isoAngle(value:Number):void
		{
			if (value == _isoAngle) return;
			_isoAngle = value;
			render();
		}
		
		public function get mouseCoordinates():Point
		{
			return _mouseCoordinates;
		}
		
		////////////////////
		// EVENT HANDLERS
		////////////////////
		
		private function onTileOver(e:MouseEvent):void
		{
			// Get reference to tile.
			var tile:TileEditorTile = e.currentTarget as TileEditorTile;
			var x:int = tile.mapCoords.x;
			var y:int = tile.mapCoords.y;
			
			// Set mouse corrdinates.
			_mouseCoordinates = new Point(x, y);
			dispatchEvent(new Event(MOUSE_COORDINATES));
			
			// Check if tile writing is on.
			if (_isWriting)
			{
				// Write to buffer.
				writeToBuffer(x, y, _writeValue);
				
				// Color the tile.
				tile.fillAlpha = (_writeValue) ? _tileSelectedAlpha : 0;
			}
			else
			{
				// Chnage tile alpha.
				tile.fillAlpha = _tileOverAlpha;
			
				// Listen for mouse events.
				tile.addEventListener(MouseEvent.ROLL_OUT, onRollOut);
			}
			
			function onRollOut(e:MouseEvent):void
			{
				// Remove event listener.
				tile.removeEventListener(MouseEvent.ROLL_OUT, onRollOut);
				
				// Remove mouse corrdinates.
				_mouseCoordinates = null;
				dispatchEvent(new Event(MOUSE_COORDINATES));
				
				// Get tile value.
				var tileValue:Boolean = readFromBuffer(x, y);
				
				// Color the tile.
				tile.fillAlpha = (tileValue) ? _tileSelectedAlpha : 0;
			}
		}
		
		private function onTileDown(e:MouseEvent):void
		{
			// Get reference to tile.
			var tile:TileEditorTile = e.currentTarget as TileEditorTile;
			
			// Get value for tile.
			var x:uint = tile.mapCoords.x;
			var y:uint = tile.mapCoords.y;
			var tileValue:Boolean = readFromBuffer(x, y);
			
			// Set write value to opposite the tile value.
			_writeValue = !tileValue;
			
			// Write to buffer in this location.
			writeToBuffer(x, y, _writeValue);
			
			// Color the tile.
			tile.fillAlpha = (_writeValue) ? _tileSelectedAlpha : 0;
		}
		
		private function onMouseDown(e:MouseEvent):void
		{
			addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			
			_isWriting = true;
			
			function onMouseUp(e:MouseEvent):void
			{
				_isWriting = false;
				_writeValue = false;
			}
		}
		
	}
}