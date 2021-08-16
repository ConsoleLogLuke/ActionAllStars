package com.sdg.view
{
	import com.sdg.components.controls.ScrollBar;
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

	public class ItemListWindow extends Sprite
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
		protected var _useMask:Boolean;
		protected var _widthHeightRatio:Number;
		protected var _isScrollBarVisible:Boolean;
		protected var _vScrollBarMarginTop:Number;
		protected var _vScrollBarMarginBottom:Number;
		
		public function ItemListWindow(width:Number, height:Number, columns:uint = 3, maxRows:uint = 100, spacing:Number = 20, scrollBarWidth:Number = 20)
		{
			super();
			
			_width = width;
			_height = height;
			_columns = columns;
			_maxRows = maxRows;
			_scrollBarWidth = scrollBarWidth;
			_spacing = spacing;
			_widthHeightRatio = 1;
			_isScrollBarVisible = true;
			_vScrollBarMarginTop = 0;
			_vScrollBarMarginBottom = 0;
			
			var itemWidth:Number = (_width - _scrollBarWidth) / _columns;
			var itemHeight:Number = itemWidth;
			
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
			_vScrollBar.scrollWheelTarget = this;
			addChild(_vScrollBar);
			
			// Create window controller.
			_windowController = new ScrollWindowController();
			_windowController.content = _grid;
			_windowController.vScrollBar = _vScrollBar;
			_windowController.addEventListener(ScrollEvent.SCROLL, onScroll);
			
			// Create a grid mask.
			_gridMask = new Sprite();
			addChild(_gridMask);
			
			// Use mask by default.
			useMask = true;
			
			render();
		}
		
		public function destroy():void
		{
			_windowController.removeEventListener(ScrollEvent.SCROLL, onScroll);
			_windowController.destroy();
			
			_grid.destroy();
		}
		
		public function render():void
		{
			graphics.clear();
			//graphics.lineStyle(1, 0xffffff);
			graphics.beginFill(0xffffff, 0);
			graphics.drawRect(0, 0, _width, _height);
			
			// Update window rectangle.
			_windowController.windowRect = new Rectangle(0, 0, _width, _height);
			
			// Update scroll bar size.
			var totalScrollBarMargin:Number = -_vScrollBarMarginTop - _vScrollBarMarginBottom;
			_vScrollBar.height = _height + totalScrollBarMargin;
			_vScrollBar.x = _width - _scrollBarWidth;
			_vScrollBar.y = _vScrollBarMarginTop;
			
			var scrollBarWidth:Number = (_isScrollBarVisible) ? _scrollBarWidth : 0;
			
			// Update grid unti size.
			var itemWidth:Number = (_width - scrollBarWidth - ((_columns + 1) * _spacing)) / _columns;
			var itemHeight:Number = itemWidth / _widthHeightRatio;
			_grid.setUnitSize(itemWidth, itemHeight);
			
			// Update grid visibility.
			updateGridVisibility();
			
			// Draw grid mask.
			_gridMask.graphics.clear();
			_gridMask.graphics.beginFill(0x00ff00);
			_gridMask.graphics.drawRect(0, 0, _width, _height);
		}
		
		protected function updateGridVisibility():void
		{
			// Update the visible area of the grid.
			var area:Rectangle = new Rectangle(0, -_grid.y, _width - _scrollBarWidth, _height);
			_grid.visibleArea = area;
		}
		
		public function setVerticalScrollBarMargin(top:Number, bottom:Number):void
		{
			_vScrollBarMarginTop = top;
			_vScrollBarMarginBottom = bottom;
			
			render();
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
			
			render();
		}
		
		public function get useMask():Boolean
		{
			return _useMask;
		}
		public function set useMask(value:Boolean):void
		{
			_useMask = value;
			if (_useMask == true)
			{
				_grid.mask = _gridMask;
				_gridMask.visible = true;
			}
			else
			{
				_gridMask.visible = false;
				_grid.mask = null;
			}
		}
		
		public function get scrollValueY():Number
		{
			return _vScrollBar.scrollPosition;
		}
		public function set scrollValueY(value:Number):void
		{
			_vScrollBar.scrollPosition = value;
		}
		
		public function get widthHeightRatio():Number
		{
			return _widthHeightRatio;
		}
		public function set widthHeightRatio(value:Number):void
		{
			_widthHeightRatio = value;
			render();
		}
		
		public function get isScrollBarVisible():Boolean
		{
			return _isScrollBarVisible;
		}
		public function set isScrollBarVisible(value:Boolean):void
		{
			if (value == _isScrollBarVisible) return;
			_isScrollBarVisible = value;
			_vScrollBar.visible = _isScrollBarVisible;
			render();
		}
		
		public function get vScrollBar():ScrollBar
		{
			return _vScrollBar;
		}
		
		////////////////////
		// EVENT HANDLERS
		////////////////////
		
		private function onScroll(e:ScrollEvent):void
		{
			// On scroll update the visible area of the grid.
			updateGridVisibility();
			
			// Propegate the event.
			var event:ScrollEvent = new ScrollEvent(e.type);
			event.scrollPosition = e.scrollPosition;
			dispatchEvent(event);
		}
		
	}
}