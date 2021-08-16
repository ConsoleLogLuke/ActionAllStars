package com.sdg.gameMenus
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class ItemScroll extends Sprite
	{
		protected const PADDING:Number = 10;
		protected const GAP:Number = 3;
		
		protected var _width:Number;
		protected var _height:Number;
		protected var _leftArrow:ArrowButton;
		protected var _rightArrow:ArrowButton;
		protected var _itemsArray:Array;
		protected var _itemsList:Sprite;
		protected var _windowSize:Number;
		protected var _totalItemWidth:Number;
		protected var _selectedIndex:int;
		
		public function ItemScroll(width:Number, height:Number, arrowButtonSize:Number = 40, arrowWidth:Number = 12, arrowHeight:Number = 20)
		{
			super();
			_width = width;
			_height = height;
			_totalItemWidth = 0;
			
			_leftArrow = new ArrowButton(ArrowButton.LEFT, arrowButtonSize, arrowButtonSize, arrowWidth, arrowHeight);
			_leftArrow.x = PADDING;
			_leftArrow.y = _height/2 - _leftArrow.height/2;
			addChild(_leftArrow);
			
			_rightArrow = new ArrowButton(ArrowButton.RIGHT, arrowButtonSize, arrowButtonSize, arrowWidth, arrowHeight);
			_rightArrow.x = _width - PADDING - _rightArrow.width;
			_rightArrow.y = _height/2 - _rightArrow.height/2;
			addChild(_rightArrow);
			
			_leftArrow.addEventListener(MouseEvent.CLICK, onLeftClick);
			_rightArrow.addEventListener(MouseEvent.CLICK, onRightClick);
			
			_windowSize = _width - _leftArrow.width - _rightArrow.width - 2*PADDING - 2*GAP;
			
			var windowContainer:Sprite = new Sprite();
			
			_itemsList = new Sprite();
			windowContainer.addChild(_itemsList);
			
			var mask:Sprite = new Sprite();
			mask.graphics.beginFill(0x000000);
			mask.graphics.drawRect(0, 0, _windowSize, _height);
			windowContainer.addChild(mask);
			
			windowContainer.mask = mask;
			
			windowContainer.x = _width/2 - windowContainer.width/2;
			addChild(windowContainer);			
			
			_itemsArray = new Array();
		}
		
		protected function onLeftClick(event:MouseEvent):void
		{
			selectedIndex = _selectedIndex - 1;
		}
		
		protected function onRightClick(event:MouseEvent):void
		{
			selectedIndex = _selectedIndex + 1;
		}
		
		public function destroy():void
		{
			_leftArrow.removeEventListener(MouseEvent.CLICK, onLeftClick);
			_rightArrow.removeEventListener(MouseEvent.CLICK, onRightClick);
		}
		
		public function addScrollItem(item:IScrollObject):void
		{
			item.x = _totalItemWidth;
			item.y = _height/2 - item.height/2;
			_itemsArray.push(item);
			_itemsList.addChild(item as DisplayObject);
			_totalItemWidth += item.width;
		}
		
		public function removeAllItems():void
		{
			for each (var item:IScrollObject in _itemsArray)
				_itemsList.removeChild(item as DisplayObject);
			
			_itemsArray = new Array();
		}
		
		public function set selectedIndex(index:int):void
		{
			if (index < 0) return;
			if (index > _itemsArray.length - 1) return;
			
			var item:IScrollObject;
			
			item = _itemsArray[_selectedIndex];
			item.selected = false;
			
			item = _itemsArray[index];
			item.selected = true;
			
			_itemsList.x = _windowSize/2 - (item.x + item.width/2);
			
			_selectedIndex = index;
			
			dispatchEvent(new Event("selectedIndexChanged"));
			
			if (index == 0)
				_leftArrow.enabled = false;
			else
				_leftArrow.enabled = true;
			
			if (index == _itemsArray.length - 1)
				_rightArrow.enabled = false;
			else
				_rightArrow.enabled = true;
		}
		
		public function get selectedItem():IScrollObject
		{
			return _itemsArray[_selectedIndex];
		}
		
		public function get windowSize():Number
		{
			return _windowSize;
		}
		
		override public function get width():Number
		{
			return _width;
		}
		
		override public function get height():Number
		{
			return _height;
		}
	}
}