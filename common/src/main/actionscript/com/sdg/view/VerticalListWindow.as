package com.sdg.view
{
	import com.sdg.components.controls.VerticalScrollBar;
	import com.sdg.events.ScrollEvent;
	import com.sdg.model.IInitable;
	import com.sdg.view.pda.ArrowButtonDown;
	import com.sdg.view.pda.ArrowButtonUp;
	import com.sdg.view.pda.ScrollBacking;
	import com.sdg.view.pda.ScrollBarGrabber;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	
	public class VerticalListWindow extends FluidView
	{
		protected var _maxVisible:uint;
		protected var _topMargin:Number;
		protected var _rightMargin:Number;
		protected var _bottomMargin:Number;
		protected var _leftMargin:Number;
		protected var _spacing:Number;
		protected var _vScrollBar:VerticalScrollBar;
		protected var _items:Array;
		protected var _itemLayer:Sprite;
		protected var _scrollPos:uint;
		protected var _itemW:Number;
		protected var _itemH:Number;
		
		public function VerticalListWindow(width:Number, height:Number, maxVisible:uint, topMargin:Number, rightMargin:Number, bottomMargin:Number, leftMargin:Number, spacing:Number)
		{
			_maxVisible = maxVisible;
			_topMargin = topMargin;
			_rightMargin = rightMargin;
			_bottomMargin = bottomMargin;
			_leftMargin = leftMargin;
			_spacing = spacing;
			_items = [];
			_scrollPos = 0;
			_itemLayer = new Sprite();
			
			_vScrollBar = new VerticalScrollBar();
			_vScrollBar.windowSize = _maxVisible;
			_vScrollBar.scrollButton1 = new ArrowButtonUp();
			_vScrollBar.scrollButton2 = new ArrowButtonDown();
			_vScrollBar.scrollBarBacking = new ScrollBacking();
			_vScrollBar.scrollBarGrabber = new ScrollBarGrabber();
			_vScrollBar.scrollWheelTarget = this;
			_vScrollBar.addEventListener(ScrollEvent.SCROLL, onScroll);
			
			super(width, height);
			
			// Add displays.
			addChild(_itemLayer);
			addChild(_vScrollBar);
			
			render();
		}
		
		////////////////////
		// PUBLIC METHODS
		////////////////////
		
		public function destroy():void
		{
			// Remove event listeners.
			_vScrollBar.removeEventListener(ScrollEvent.SCROLL, onScroll);
			
			// Remove displays.
			removeChild(_itemLayer);
			removeChild(_vScrollBar);
			
			// Call destroy on children.
			_vScrollBar.destroy();
			
			// Destroy references to help with garbage collection.
			_vScrollBar = null;
			_itemLayer = null;
			_items = null;
		}
		
		public function addItem(item:DisplayObject):void
		{
			// Add the item to the array.
			var itemCount:uint = _items.push(item);
			// Update the content size for the scroll bar.
			_vScrollBar.contentSize = itemCount;
			// Determine if the item should be visible, based on the
			// items position within the list and the current scroll.
			var itemIsVisible:Boolean = (itemCount > _maxVisible + _scrollPos || itemCount <= _scrollPos) ? false : true;
			item.visible = itemIsVisible;
			// If it's a visible item,
			// size and position it.
			if (itemIsVisible == true)
			{
				// Size the item.
				item.width = _itemW;
				item.height = _itemH;
				// Position the item.
				item.x = _leftMargin;
				item.y = (_itemH + _spacing) * (itemCount - 1);
				
				// Attempt to call init on the item.
				var initableItem:IInitable = item as IInitable;
				if (initableItem != null) initableItem.init();
			}
			// Add the item to display.
			_itemLayer.addChild(item);
		}
		
		public function setSize(width:Number, height:Number):void
		{
			if (width == _width && height == _height) return;
			_width = width;
			_height = height;
			render();
		}
		
		////////////////////
		// PROTECTED METHODS
		////////////////////
		
		override protected function render():void
		{
			super.render();
			
			_vScrollBar.height = _height;
			_vScrollBar.x = _width - _vScrollBar.width;
			
			// The width is defined by the width of the list window
			// minus the margins.
			_itemW = _width - _leftMargin - _rightMargin - _vScrollBar.width;
			// The height is defined by the height of the list window,
			// devided by the max number of items that can be visible
			// within the window at a given time. Margins and spacing
			// must be taken into account.
			_itemH = (_height - _topMargin - _bottomMargin - (_spacing * (_maxVisible - 1))) / _maxVisible;
			
			renderVisibleItems();
		}
		
		protected function renderVisibleItems():void
		{
			// Loop through visible items and
			// change their size.
			var itemWidth:Number = _itemW;
			var itemHeight:Number = _itemH;
			var i:uint = _scrollPos;
			var len:uint = i + _maxVisible;
			var itemCount:uint = _items.length;
			for (i; i < len && i < itemCount; i++)
			{
				var item:DisplayObject = _items[i];
				item.width = itemWidth;
				item.height = itemHeight;
				item.y = (itemHeight + _spacing) * (i);
			}
		}
		
		protected function renderItems():void
		{
			var i:uint = 0;
			var len:uint = _items.length;
			var itemWidth:Number = _itemW;
			var itemHeight:Number = _itemH;
			for (i; i < len; i++)
			{
				var item:DisplayObject = _items[i];
				var itemIsVisible:Boolean = (i + 1 > _maxVisible + _scrollPos || i < _scrollPos) ? false : true;
				item.visible = itemIsVisible;
				
				// If it's a visible item,
				// size and position it.
				if (itemIsVisible != true) continue;
				item.width = itemWidth;
				item.height = itemHeight;
				item.y = (itemHeight + _spacing) * (i);
				
				// Attempt to call init on the item.
				var initableItem:IInitable = item as IInitable;
				if (initableItem != null) initableItem.init();
			}
		}
		
		////////////////////
		// EVENT HANDLERS
		////////////////////
		
		private function onScroll(e:ScrollEvent):void
		{
			// Update scroll position.
			var newScrollPos:uint = Math.round(e.scrollPosition * _vScrollBar.contentSize);
			if (newScrollPos == _scrollPos) return;
			_scrollPos = newScrollPos;
			
			renderItems();
			
			// Position the item layer.
			_itemLayer.y = _topMargin - (_scrollPos * (_itemH + _spacing));
		}
		
	}
}