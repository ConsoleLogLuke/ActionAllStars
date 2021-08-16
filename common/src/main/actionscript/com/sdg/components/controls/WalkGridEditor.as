package com.sdg.components.controls
{
	import com.sdg.collections.Array2;
	import com.sdg.components.events.InteractiveGridEvent;
	
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	
	import mx.core.FlexBitmap;
	
	public class WalkGridEditor extends InteractiveGrid
	{
		public var tileFillColor:uint = 0xFF557BD5;
		
		public var walkGridFlag:Boolean = true;
		public var spawnGridFlag:Boolean;
		public var triggerGridFlag:Boolean;
		public var tileAddedFlag:Boolean;
		public var pauseFlag:Boolean = false;
		
		private var _dataProvider:Array2;
		private var _dragData:Object;
		private var _tileFillBitmap:FlexBitmap;
		private var _tileFillRect:Rectangle = new Rectangle();
		
		[Bindable]
		public function get dataProvider():Array2
		{
			return _dataProvider;
		}
		
		public function set dataProvider(value:Array2):void
		{
			_dataProvider = value;
			
			if (_dataProvider)
			{
				columns = _dataProvider.width;
				rows = _dataProvider.height;
			}
			else
			{
				columns = rows = 10;
			}
			
			invalidateDisplayList();
		}
		
		public function WalkGridEditor()
		{
			addEventListener(InteractiveGridEvent.TILE_DOWN, tileDownHandler);
			addEventListener(InteractiveGridEvent.TILE_UP, tileUpHandler);
			addEventListener(InteractiveGridEvent.TILE_HOVER, tileHoverHandler);
		}
		
		override protected function createChildren():void
		{
			super.createChildren();
			
			if (!_tileFillBitmap)
			{
				_tileFillBitmap = new FlexBitmap();
				addChildAt(_tileFillBitmap, 1);
			}
		}
		
		override public function validateSize(recursive:Boolean = false):void
		{
			super.validateSize(recursive);
		}
		
		override protected function updateDisplayList(w:Number, h:Number):void
		{
			super.updateDisplayList(w, h);
			
			_tileFillBitmap.bitmapData = new BitmapData(columnWidth * columns, rowHeight * rows, true, 0);
			
			refreshTiles();
		}
		
		public function setTiles(x:uint, y:uint, w:uint, h:uint, data:Object):void
		{
			if (!_dataProvider) return;
			_dataProvider.setRect(x, y, w, h, data);
			drawTiles(x, y, w, h, data);
		}
		
		public function setAllTiles(data:Object):void
		{
			setTiles(0, 0, columns, rows, data);
		}
		
		protected function drawTile(x:uint, y:uint, data:Object):void
		{
			_tileFillBitmap.bitmapData.setPixel32(x, y, data ? tileFillColor : 0);
		}
		
		protected function drawTiles(x:uint, y:uint, w:uint, h:uint, data:Object):void
		{
			_tileFillRect.x = x;
			_tileFillRect.y = y;
			_tileFillRect.width = w * columnWidth;
			_tileFillRect.height = h * rowHeight;
			_tileFillBitmap.bitmapData.fillRect(_tileFillRect, data ? tileFillColor : 0);
		}
		
		protected function refreshTiles():void
		{
			if (!_dataProvider) return;
			
			var w:int = rows;
			var h:int = columns;
			
			for (var ix:int = 0; ix < w; ix++)
			{
				for (var iy:int = 0; iy < h; iy++)
				{
					drawTile(ix, iy, _dataProvider.get(ix, iy));
				}
			}
		}
		
		public function callRefreshTiles():void
		{
			refreshTiles();
		}
		
		protected function tileDownHandler(event:InteractiveGridEvent):void
		{
			if(!pauseFlag)
			{
				var data:Object = _dataProvider.get(event.columnIndex, event.rowIndex);
				if(!tileAddedFlag)
				{
					_dragData = data ? 0 : 1;
					setTiles(event.columnIndex, event.rowIndex, indicatorColumns, indicatorRows, _dragData);
				}
			}
		}
		
		protected function tileUpHandler(event:InteractiveGridEvent):void
		{
		}
		
		protected function tileHoverHandler(event:InteractiveGridEvent):void
		{
			if(!pauseFlag)
			{
				if(walkGridFlag)
				{
					if (event.buttonDown)
						setTiles(event.columnIndex, event.rowIndex, indicatorColumns, indicatorRows, _dragData);
				}
			}
		}
	}
}