package com.sdg.view.list
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	
	public class CircleListView extends Sprite
	{
		protected var _interval:Number;
		protected var _radius:Number;
		protected var _items:Array;
		protected var _start:Number;
		protected var _end:Number;
		protected var _span:Number;
		protected var _len:int;
		
		private var _guide:Sprite;
		private var _itemLayer:Sprite;
		
		public function CircleListView(radius:Number)
		{
			_radius = radius;
			_items = [];
			_start = Math.PI / 2;
			_end = _start;
			_len = 0;
			_span = _end - _start;
			_interval = _span / (_len + 1);
			
			_guide = new Sprite();
			_itemLayer = new Sprite();
			
			super();
			
			addChild(_guide);
			addChild(_itemLayer);
		}
		
		////////////////////
		// PUBLIC FUNCTIONS
		////////////////////
		
		public function addItem(item:DisplayObject):void
		{
			// Make sure the item is not already in the list.
			if (_items.indexOf(item) > -1) return;
			
			// Add the item to the list and re-render.
			_items.push(item);
			_len++;
			calculateInterval();
			_itemLayer.addChild(item);
			render();
		}
		
		public function removeItem(item:DisplayObject):void
		{
			var index:int = _items.indexOf(item);
			
			if (index > -1)
			{
				_items.splice(index, 1);
				_len--;
				calculateInterval();
				_itemLayer.removeChild(item);
				render();
			}
		}
		
		public function removeItemAt(index:int):void
		{
			var item:DisplayObject = _items[index] as DisplayObject;
			
			if (item)
			{
				_items.splice(index, 1);
				_len--;
				calculateInterval();
				_itemLayer.removeChild(item);
				render();
			}
		}
		
		public function getItemIndex(item:DisplayObject):int
		{
			return _items.indexOf(item);
		}
		
		public function destroy():void
		{
			// Handle cleanup.
			removeChild(_guide);
			
			for each (var item:DisplayObject in _items)
			{
				_itemLayer.removeChild(item);
			}
			
			_items = null;
			_guide = null;
		}
		
		////////////////////
		// PROTECTED FUNCTIONS
		////////////////////
		
		protected function render():void
		{
			// Position each item along the arc of a circle.
			var i:int = 0;
			var len:int = _len;
			for (i; i < len; i++)
			{
				renderButtonAtIndex(i);
			}
			
			// Re-draw guide.
			_guide.graphics.clear();
			_guide.graphics.beginFill(0, 0);
			_guide.graphics.drawCircle(0, 0, _radius);
		}
		
		protected function renderButtonAtIndex(index:int):void
		{
			var item:DisplayObject = _items[index];
			var rad:Number = calculateRadiansAtIndex(index);
			item.x = getItemXInCircle(rad);
			item.y = getItemYInCircle(rad);
		}
		
		protected function calculateRadiansAtIndex(index:int):Number
		{
			return _start + _interval * (index + 1);
		}
		
		protected function getItemXInCircle(radians:Number):Number
		{
			// Determine an "x" coordinate with given angle(radians) and circle radius.
			return Math.cos(radians) * _radius;
		}
		
		protected function getItemYInCircle(radians:Number):Number
		{
			// Determine a "y" coordinate with given angle(radians) and circle radius.
			return Math.sin(radians) * _radius;
		}
		
		protected function calculate():void
		{
			// Calculate span and radius.
			calculateSpan();
			calculateInterval();
		}
		
		protected function calculateSpan():void
		{
			// The span is the distance between the start and the end.
			// Where within the circle, the buttons start and end.
			_span = _end - _start;
		}
		
		protected function calculateInterval():void
		{
			// The interval is the distance between the items (in radians).
			_interval = _span / (_len + 1);
		}
		
		////////////////////
		// PRIVATE FUNCTIONS
		////////////////////
		
		
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		public function get start():Number
		{
			return _start;
		}
		public function set start(value:Number):void
		{
			if (value == _start) return;
			_start = value;
			calculate();
			render();
		}
		
		public function get end():Number
		{
			return _end;
		}
		public function set end(value:Number):void
		{
			if (value == _end) return;
			_end = value;
			calculate();
			render();
		}
		
		public function get radius():Number
		{
			return _radius;
		}
		public function set radius(value:Number):void
		{
			if (value == _radius) return;
			_radius = value;
			render();
		}
		
	}
}