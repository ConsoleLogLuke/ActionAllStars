package com.sdg.view
{
	import com.sdg.components.controls.VerticalScrollBar;
	import com.sdg.control.ScrollWindowController;
	import com.sdg.display.Grid;
	import com.sdg.events.ScrollEvent;
	import com.sdg.model.DisplayObjectCollection;
	import com.sdg.view.pda.ArrowButtonDown;
	import com.sdg.view.pda.ArrowButtonUp;
	import com.sdg.view.pda.ScrollBacking;
	import com.sdg.view.pda.ScrollBarGrabber;
	
	import flash.display.Sprite;
	import flash.geom.Rectangle;

	public class CategoryListWindow extends Sprite
	{
		protected var _width:Number;
		protected var _height:Number;
		protected var _grid:Grid;
		protected var _columns:uint;
		protected var _maxRows:uint;
		protected var _items:DisplayObjectCollection;
		protected var _windowController:ScrollWindowController;
		protected var _vScrollBar:VerticalScrollBar;
		protected var _scrollBarWidth:Number;
		protected var _gridMask:Sprite;
		protected var _spacing:Number;
		
		
		public function CategoryListWindow(width:Number, height:Number, columns:uint = 3, maxRows:uint = 12)
		{
			super();
			
			_width = width;
			_height = height;
			_columns = columns;
			_maxRows = maxRows;
			_spacing = 20;
			
			var itemWidth:Number = (_width - _scrollBarWidth) / _columns;
			var itemHeight:Number = itemWidth;
			
			// Temporary
			_scrollBarWidth = 20;
			
			// Create Grid of Category Icons
			// Create item grid.
			_grid = new Grid(_columns, _maxRows, itemWidth, itemHeight);
			_grid.spacingX = _spacing;
			_grid.spacingY = _spacing;
			addChild(_grid);
			
			// Create a new vertical scroll bar.
			_vScrollBar = new VerticalScrollBar();
			_vScrollBar.scrollButton1 = new ArrowButtonUp();
			_vScrollBar.scrollButton2 = new ArrowButtonDown();
			_vScrollBar.scrollBarBacking = new ScrollBacking();
			_vScrollBar.scrollBarGrabber = new ScrollBarGrabber();
			_vScrollBar.width = _scrollBarWidth;
			_vScrollBar.height = _height;
			_vScrollBar.x = _width - _scrollBarWidth;
			addChild(_vScrollBar);
			
			// Create window controller.
			_windowController = new ScrollWindowController();
			_windowController.content = _grid;
			_windowController.vScrollBar = _vScrollBar;
			_windowController.addEventListener(ScrollEvent.SCROLL, onScroll);
			
			// Create a grid mask.
			_gridMask = new Sprite();
			_grid.mask = _gridMask;
			addChild(_gridMask);
			
			render();
		}
		
		protected function render():void
		{
			graphics.clear();
			graphics.lineStyle(1, 0xffffff);
			graphics.drawRect(0, 0, _width, _height);
			
			// Update window rectangle.
			_windowController.windowRect = new Rectangle(0, 0, _width, _height);
			
			// Update scroll bar size.
			_vScrollBar.height = _height;
			_vScrollBar.x = _width - _scrollBarWidth;
			
			// Update grid unti size.
			var itemWidth:Number = (_width - _scrollBarWidth - ((_columns + 1) * _spacing)) / _columns;
			var itemHeight:Number = itemWidth * 1.5;
			_grid.setUnitSize(itemWidth, itemHeight);
			
			// Update grid visibility.
			updateGridVisibility();
			
			// Draw grid mask.
			_gridMask.graphics.clear();
			_gridMask.graphics.beginFill(0xffffff);
			_gridMask.graphics.drawRect(0, 0, _width, _height);
		}
		
		protected function updateGridVisibility():void
		{
			// Update the visible area of the grid.
			var area:Rectangle = new Rectangle(0, -_grid.y, _width - _scrollBarWidth, _height);
			_grid.visibleArea = area;
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		override public function get width():Number
		{
			return _width;
		}
		override public function set width(value:Number):void
		{
			if (value == _width) return;
			_width = value;
			render();
		}
		
		override public function get height():Number
		{
			return _height;
		}
		override public function set height(value:Number):void
		{
			if (value == _height) return;
			_height = value;
			render();
		}
		
		public function set items(value:DisplayObjectCollection):void
		{
			_items = value;
			
			// Clear and re-populate the grid.
			_grid.removeAll();
			_grid.addMultipleObjects(_items, true);
		}
		
		////////////////////
		// EVENT HANDLERS
		////////////////////
		
		private function onScroll(e:ScrollEvent):void
		{
			// On scroll update the visible area of the grid.
			updateGridVisibility();
		}
		
	}
} 