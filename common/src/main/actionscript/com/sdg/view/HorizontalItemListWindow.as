package com.sdg.view
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	

	public class HorizontalItemListWindow extends Sprite
	{
		protected var _width:Number;
		protected var _height:Number;
		protected var _columns:uint;
		protected var _containerMask:Sprite;
		protected var _spacing:Number;
		protected var _widthHeightRatio:Number;
		protected var _scrollDeadZone:Number = 0;
		
		// Moving Items
		protected var _listItems:Array;
		protected var _itemsContainer:Sprite;
		protected var _visibleArea:Sprite;
		protected var _mouseMovementArea:Sprite;
		protected var _rightScrollArea:Sprite;
		
		protected var _scrollValue:Number = 0;
		protected var _scrollSpeed:Number = 0;
		protected var _maxX:Number = 0;
		protected var _minX:Number = 0;
		
		protected var _listItemOffsetY:int = -1;  // initialized with invalid value
		
		public function HorizontalItemListWindow(width:uint, height:uint, spacing:Number = 20)
		{
			super();
			
			_width = width;
			_height = height;
			_spacing = spacing;
			
			_listItems = [];
			_itemsContainer = new Sprite();
			this.addChild(_itemsContainer);
			
			_containerMask = new Sprite();
			_containerMask.graphics.beginFill(0x000000,0);
			_containerMask.graphics.drawRect(0,0,_width,_height);
			this.addChild(_containerMask);
			_itemsContainer.mask = _containerMask;
			_itemsContainer.visible = true;
			
			_mouseMovementArea = new Sprite();
			_mouseMovementArea.graphics.beginFill(0x000000,0);
			_mouseMovementArea.graphics.drawRect(0,0,_width,_height);
			this.addChildAt(_mouseMovementArea,0);
			
			this.addEventListener(MouseEvent.MOUSE_MOVE,onMouseMovement);
			this.addEventListener(Event.ENTER_FRAME,onEnterFrame);
			this.addEventListener(MouseEvent.ROLL_OVER,onMouseRollover);
			this.addEventListener(MouseEvent.ROLL_OUT,onMouseRollout);
		}
		
		public function render():void
		{
			var positionX:uint = 0;
			var positionY:uint = 0;
			
			for each (var icon:Sprite in _listItems)
			{
				if (_listItemOffsetY == -1)
				{
					// Invalid value, set with Icon
					_listItemOffsetY = (this.height - icon.height) / 2;
					positionY = _listItemOffsetY;
				}
				
				icon.x = positionX + _spacing;
				icon.y = positionY;
				_itemsContainer.addChild(icon);
				positionX = positionX + icon.width + _spacing;
			}
		}

		// External scroll controller
		public function scrollOneFrame(multiplier:Number):void
		{
			var newX:Number = _itemsContainer.x - _scrollSpeed*multiplier;	
			newX = Math.min(_maxX,newX);
			newX = Math.max(_minX,newX);
			
			_itemsContainer.x = newX;
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		public function get listItems():Array
		{
			return _listItems;
		}
		
		public function set listItems(value:Array):void
		{
			// Clear and re-populate the grid.
			_listItems = value;
			
			render();
		}
		
		override public function get width():Number
		{
			return _width;
		}
		override public function set width(value:Number):void
		{}
		
		override public function get height():Number
		{
			return _height;
		}
		override public function set height(value:Number):void
		{}

		public function get containerMask():Sprite
		{
			return _containerMask;
		}
		
		public function get scrollSpeed():Number
		{
			return _scrollSpeed;
		}
		
		public function set scrollSpeed(value:Number):void
		{
			_scrollSpeed = value;
		}
		
		public function get scrollDeadZone():Number
		{
			return _scrollDeadZone;
		}
		
		public function set scrollDeadZone(value:Number):void
		{
			_scrollDeadZone = value;
		}

		//////////////////////
		// UTILITY FUNCTIONS
		//////////////////////
		
		private function drawVisibleBorder(w:int,h:int):void
		{
			this.graphics.lineStyle(2,0x00cc00,1);
			this.graphics.moveTo(0,0);
			this.graphics.lineTo(w,0);
			this.graphics.lineTo(w,h);
			this.graphics.lineTo(0,h);
			this.graphics.lineTo(0,0);	
		}

		////////////////////
		// EVENT HANDLERS
		////////////////////
		
		private function onMouseRollover(e:MouseEvent):void
		{
			//reset scrolling
			this._scrollValue = 0;
		}
		
		private function onMouseMovement(e:MouseEvent):void
		{
			var mx:Number = this.mouseX;

			mx = mx - _width/2;
			mx = mx / (_width/2);
			
			this._scrollValue = mx;
		}
		
		private function onMouseRollout(e:MouseEvent):void
		{
			//shut down scrolling
			this._scrollValue = 0;
		}

		private function onEnterFrame(e:Event):void
		{
			_maxX = 0;
			_minX = - _itemsContainer.width - _spacing*2 + this._width;
			
			var deltaX:Number = _scrollValue * _scrollSpeed;

			// Create a dead zone 
			if (Math.abs(deltaX) < _scrollDeadZone)
			{
				deltaX = 0;
			}
			
			var newX:Number = _itemsContainer.x - deltaX;	
			newX = Math.min(_maxX,newX);
			newX = Math.max(_minX,newX);
			
			_itemsContainer.x = newX;
		}

	}
}