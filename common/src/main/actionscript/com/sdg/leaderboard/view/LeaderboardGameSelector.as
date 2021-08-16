package com.sdg.leaderboard.view
{
	import com.good.goodgraphics.GoodArrow;
	import com.good.goodgraphics.GoodRect;
	import com.good.goodui.FluidView;
	
	import fl.motion.AdjustColor;
	
	import flash.display.DisplayObject;
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.DropShadowFilter;
	import flash.geom.Matrix;

	public class LeaderboardGameSelector extends FluidView
	{
		public static const ITEM_SELECT:String = 'item select';
		
		protected var _back:Sprite;
		protected var _container:Sprite;
		protected var _mask:Sprite;
		protected var _leftBtn:GoodRect;
		protected var _rightBtn:GoodRect;
		protected var _maskedContent:Sprite;
		protected var _lArrow:GoodArrow;
		protected var _rArrow:GoodArrow;
		protected var _greyFilter:ColorMatrixFilter;
		protected var _shadow:DropShadowFilter;
		
		protected var _items:Array;
		protected var _scrollValue:Number;
		protected var _scrollSpeed:Number;
		protected var _selectedIndex:uint;
		protected var _startIndex:uint;
		
		public function LeaderboardGameSelector(width:Number, height:Number, startIndexIn:uint = 0)
		{
			_items = [];
			_scrollValue = 0;
			_scrollSpeed = 10;
			_shadow = new DropShadowFilter(1, 45, 0, 1, 6, 6);
			_selectedIndex = 0;

			_startIndex = startIndexIn;

			
			var adjustColor:AdjustColor = new AdjustColor();
			adjustColor.saturation = -100;
			adjustColor.contrast = 0;
			adjustColor.brightness = 0;
			adjustColor.hue = 0;
			_greyFilter = new ColorMatrixFilter(adjustColor.CalculateFinalFlatArray());
			
			_back = new Sprite();
			
			_mask = new Sprite();
			
			_container = new Sprite();
			
			_leftBtn = new GoodRect(30, height, 0, 0x121818);
			_lArrow = new GoodArrow(12, 20, 0xcccccc);
			_lArrow.x = 15;
			_lArrow.y = height / 2;
			_lArrow.rotation = 180;
			_leftBtn.filters = [_shadow];
			_leftBtn.addChild(_lArrow);
			
			_rightBtn = new GoodRect(30, height, 0, 0x121818);
			_rArrow = new GoodArrow(12, 20, 0xcccccc);
			_rArrow.x = 15;
			_rArrow.y = height / 2;
			_rightBtn.filters = [_shadow];
			_rightBtn.addChild(_rArrow);
			
			_maskedContent = new Sprite();
			_maskedContent.mask = _mask;
			
			addChild(_back);
			addChild(_mask);
			addChild(_maskedContent);
			_maskedContent.addChild(_container);
			_maskedContent.addChild(_leftBtn);
			_maskedContent.addChild(_rightBtn);
			
			super(width, height);
			
			render();
			
			addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			addEventListener(MouseEvent.ROLL_OUT, onRollOut);
		}
		
		////////////////////
		// PUBLIC METHODS
		////////////////////
		
		public function destroy():void
		{
			removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			removeEventListener(MouseEvent.ROLL_OUT, onRollOut);
		}
		
		////////////////////
		// PROTECTED METHODS
		////////////////////
		
		override protected function render():void
		{
			super.render();
			
			_back.graphics.clear();
			var gradMatrix:Matrix = new Matrix();
			gradMatrix.createGradientBox(_width, _height, Math.PI / 2);
			_back.graphics.beginGradientFill(GradientType.LINEAR, [0x3a4147, 0x16181a], [1, 1], [1, 255], gradMatrix);
			_back.graphics.lineStyle(2, 0);
			_back.graphics.drawRoundRect(0, 0, _width, _height, 10, 10);
			
			_mask.graphics.clear();
			_mask.graphics.beginFill(0x00ff00);
			_mask.graphics.drawRoundRect(0, 0, _width, _height, 10, 10);
			
			_leftBtn.height = _height;
			
			_rightBtn.height = _height;
			_rightBtn.x = _width - _rightBtn.width;
			
			_lArrow.y = _height / 2;
			_rArrow.y = _height / 2;
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		public function get items():Array
		{
			return _items;
		}
		public function set items(value:Array):void
		{
			// Remove previous items.
			for each (var oldItem:DisplayObject in _items)
			{
				oldItem.removeEventListener(MouseEvent.ROLL_OVER, onItemOver);
				oldItem.removeEventListener(MouseEvent.ROLL_OUT, onRollOut);
				oldItem.removeEventListener(MouseEvent.CLICK, onItemClick);
				_container.removeChild(oldItem);
			}
			
			// Add new items.
			_items = value;
			var lastItemX:Number = 0;
			var lastItemWidth:Number = 0;
			var space:Number = 10;
			var margin:Number = 10;
			for each (var newItem:Sprite in _items)
			{
				if(newItem.width > 0)
				{
					// Scale item.
					var scale:Number = (_height - margin * 2) / newItem.height;
					newItem.width *= scale;
					newItem.height *= scale;
					
					// Position item.
					newItem.x = lastItemX + lastItemWidth + space;
					newItem.y = margin;
					_container.addChild(newItem);
					
					// Store values for next loop.
					lastItemX = newItem.x;
					lastItemWidth = newItem.width;
					space = 10;
					
					// Make the item grayscale.
					newItem.filters = [_greyFilter];
					
					// Add event listeners.
					newItem.addEventListener(MouseEvent.ROLL_OVER, onItemOver);
					newItem.addEventListener(MouseEvent.ROLL_OUT, onItemOut);
					newItem.addEventListener(MouseEvent.CLICK, onItemClick);
					newItem.buttonMode = true;
				}
			}
			
			// Re-position container.
			_container.x = _leftBtn.width;
			
			// Set selected index to 0.
			if (_startIndex > 0)
			{
				selectedIndex = _startIndex;
				_startIndex = 0;	
			}
			else
			{
				selectedIndex = 0;
			}
		}
		
		public function get selectedIndex():uint
		{
			return _selectedIndex;
		}
		public function set selectedIndex(value:uint):void
		{
			// Get reference to previously selected item.
			var oldItem:DisplayObject =  _items[_selectedIndex];
			
			// Make the previously selected item greyscale.
			if (oldItem != null) oldItem.filters = [_greyFilter];
			
			// Set selected index.
			_selectedIndex = value;
			
			// Get reference to new selected item.
			var item:DisplayObject = _items[_selectedIndex];
			
			// Make the item full color.
			item.filters = [];
			
			// Dispatch an item selected event.
			dispatchEvent(new Event(ITEM_SELECT));
		}
		
		////////////////////
		// EVENT HANDLERS
		////////////////////
		
		private function onMouseMove(e:MouseEvent):void
		{
			var mX:Number = mouseX;
			var hW:Number = _width / 2;
			var scrollValue:Number = (mX - hW) / hW;
			_scrollValue = scrollValue;
		}
		
		private function onEnterFrame(e:Event):void
		{
			var max:Number = _leftBtn.width;
			var min:Number = -_container.width + (_width - _rightBtn.width) - 20;
			var newX:Number = _container.x + (-_scrollValue * _scrollSpeed);
			newX = Math.max(min, newX);
			newX = Math.min(max, newX);
			_container.x = newX;
		}
		
		private function onRollOut(e:MouseEvent):void
		{
			_scrollValue = 0;
		}
		
		private function onItemOver(e:MouseEvent):void
		{
			// Get reference to item.
			var item:DisplayObject = e.currentTarget as DisplayObject;
			
			item.filters = [];
		}
		
		private function onItemOut(e:MouseEvent):void
		{
			// Get reference to item.
			var item:DisplayObject = e.currentTarget as DisplayObject;
			
			// Get item index.
			var index:uint = _items.indexOf(item);
			
			// If it's not the selected item, make the item grayscale.
			if (index != _selectedIndex) item.filters = [_greyFilter];
		}
		
		private function onItemClick(e:MouseEvent):void
		{
			// Get item index.
			var index:uint = _items.indexOf(e.currentTarget);
			
			// Set selected index.
			selectedIndex = index;
		}
		
	}
}