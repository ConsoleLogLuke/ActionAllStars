package com.sdg.leaderboard.view
{
	import com.sdg.events.LeaderboardSelectEvent;
	import com.sdg.net.Environment;
	import com.sdg.view.HorizontalItemListWindow;
	
	import fl.motion.AdjustColor;
	
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.filters.ColorMatrixFilter;
	import flash.net.URLRequest;

	public class LeaderboardSelector extends Sprite
	{
		// CONSTANTS
		private var ARROW_WIDTH:uint = 27;
		private var BACKING_OFFSET:uint = 29;
		private var BACKING_WIDTH:uint = 750;
		private var BACKING_WIDTH_ADJUSTED:uint = 746;
		private var HEIGHT:uint = 78;
		
		protected var _icons:HorizontalItemListWindow;
		protected var _leftButton:DisplayObject;
		protected var _rightButton:DisplayObject;
		protected var _backing:DisplayObject;
		
		protected var _selectedIconIndex:uint = 0;
		
		protected var _activeLeftButton:Boolean = false;
		protected var _activeRightButton:Boolean = false;
		
		public function LeaderboardSelector()
		{
			super();
			
			this.addEventListener(Event.ENTER_FRAME,onEnterFrame);
			
			// Load Icons and position them
			this.loadUrl(Environment.getApplicationUrl() + "/test/gameSwf/gameId/74/gameFile/button_Left.swf",positionLeftArrow);
			this.loadUrl(Environment.getApplicationUrl() + "/test/gameSwf/gameId/74/gameFile/button_Right.swf",positionRightArrow);
			this.loadUrl(Environment.getApplicationUrl() + "/test/gameSwf/gameId/74/gameFile/leaderboard_gameSelection_bg.swf",positionBacking);
			
			_icons = new HorizontalItemListWindow(BACKING_WIDTH_ADJUSTED,HEIGHT,20);
			_icons.x = BACKING_OFFSET;
			_icons.y = 0;
			this.addChild(_icons);
			_icons.scrollSpeed = 10;
			_icons.scrollDeadZone = 5;
			
			this.stubIcons()
		}
		
		public function stubIcons():void
		{
			var spriteArray:Array = [];
			
			for (var i:uint = 0;i <= 10;i++)
			{
				var box:Sprite = new Sprite;
				box.graphics.beginFill(0x00cc00,1);
				box.graphics.drawRect(0,0,94,56);
				spriteArray[i] = box;
			}
			
			this.addListItems(spriteArray);
		}
		
		public function addListItems(value:Array):void
		{
			value.forEach(processIcon);
			
			function processIcon(d:DisplayObject,i:int,a:Array):void
			{
				LeaderboardSelector.setAsBlackAndWhite(d);
				d.addEventListener(MouseEvent.CLICK,onIconClick);
				// Add event listeners.
				d.addEventListener(MouseEvent.ROLL_OVER, onItemOver);
				d.addEventListener(MouseEvent.ROLL_OUT, onItemOut);
			}
			
			_icons.listItems = value;
			this.selectedIconIndex = 0;
		}
		
		public static function setAsBlackAndWhite(obj:DisplayObject):void
		{
			var adjustColor:AdjustColor = new AdjustColor();
			adjustColor.saturation = -100;
			adjustColor.contrast = 0;
			adjustColor.brightness = 0;
			adjustColor.hue = 0;
			var filter:ColorMatrixFilter = new ColorMatrixFilter(adjustColor.CalculateFinalFlatArray());
			
			obj.cacheAsBitmap = true;
			obj.filters = [filter];
		}
		
		public static function setAsColor(obj:DisplayObject):void
		{
			obj.filters = [];
		}
		
		private function loadUrl(url:String,func:Function):void
		{
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, func);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			loader.load(new URLRequest(url));
			
			function onIOError(e:IOErrorEvent):void
			{
				loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
			}
		}
		
		private function positionLeftArrow(e:Event):void
		{
				try
				{
					var li:LoaderInfo = e.target as LoaderInfo;
					_leftButton = DisplayObject(li.content as DisplayObject);
					_leftButton.x = 0;
					_leftButton.y = 0;
					this.addChild(_leftButton);
					_leftButton.addEventListener(MouseEvent.ROLL_OVER,onLeftRollover);
					_leftButton.addEventListener(MouseEvent.ROLL_OUT,onLeftRollout);
				}
				catch(e:Error)
				{
					trace(e.message);
				}
		}
		
		private function positionRightArrow(e:Event):void
		{
				try
				{
					var li:LoaderInfo = e.target as LoaderInfo;
					_rightButton = DisplayObject(li.content as DisplayObject);
					_rightButton.x = ARROW_WIDTH+BACKING_WIDTH;
					_rightButton.y = 0;
					this.addChild(_rightButton);
					_rightButton.addEventListener(MouseEvent.ROLL_OVER,onRightRollover);
					_rightButton.addEventListener(MouseEvent.ROLL_OUT,onRightRollout);
				}
				catch(e:Error)
				{
					trace(e.message);
				}
		}
		
		private function positionBacking(e:Event):void
		{
				try
				{
					var li:LoaderInfo = e.target as LoaderInfo;
					_backing = DisplayObject(li.content as DisplayObject);
					_backing.x = ARROW_WIDTH;
					_backing.y = 0;
					this.addChildAt(_backing,0);
				}
				catch(e:Error)
				{
					trace(e.message);
				}
		}
		
		////////////////////////
		// LISTENERS
		////////////////////////
		
		private function onLeftRollover(e:Event):void
		{
			_activeLeftButton = true;
		}
		
		private function onRightRollover(e:Event):void
		{
			_activeRightButton = true;
		}
		
		private function onLeftRollout(e:Event):void
		{
			_activeLeftButton = false;
		}
		
		private function onRightRollout(e:Event):void
		{
			_activeRightButton = false;
		}
		
		private function onEnterFrame(e:Event):void
		{
			if (_activeLeftButton)
			{
				_icons.scrollOneFrame(-2);
			}
			else if (_activeRightButton)
			{
				_icons.scrollOneFrame(2);
			}
		}
		
		private function onIconClick(e:MouseEvent):void
		{
			var index:int = _icons.listItems.indexOf(e.target);
			
			// Throw Leaderboard Selection Event
			var event:LeaderboardSelectEvent = new LeaderboardSelectEvent(LeaderboardSelectEvent.SELECTED, index);
			dispatchEvent(event);
			
			this.selectedIconIndex = index;
		}
		
		private function onItemOver(e:MouseEvent):void
		{
			var item:DisplayObject = e.currentTarget as DisplayObject;
			
			item.filters = [];
		}
		
		private function onItemOut(e:MouseEvent):void
		{
			var item:DisplayObject = e.currentTarget as DisplayObject;
			var itemIndex:int = _icons.listItems.indexOf(item);
			
			// Make the item grayscale.
			if (itemIndex != _selectedIconIndex)
			{
				LeaderboardSelector.setAsBlackAndWhite(item);
			}
		}
		
		///////////////////////////
		// GETTERS and SETTERS
		///////////////////////////
		
		public function get selectedIconIndex():uint
		{
			return _selectedIconIndex;
		}
		
		public function set selectedIconIndex(value:uint):void
		{
			// cancel previous icon coloring
			LeaderboardSelector.setAsBlackAndWhite(_icons.listItems[_selectedIconIndex]);
			
			_selectedIconIndex = value;
			
			//color new icon
			LeaderboardSelector.setAsColor(_icons.listItems[_selectedIconIndex]);
		}

		// TEMP FUNCTIONS
		private function drawLeftArrowBox():void
		{
			this.graphics.beginFill(0x00cc00,1);
			this.graphics.moveTo(0,0);
			this.graphics.lineTo(BACKING_OFFSET,0);
			this.graphics.lineTo(BACKING_OFFSET,HEIGHT);
			this.graphics.lineTo(0,HEIGHT);
			this.graphics.lineTo(0,0);
		}
		
		private function drawRightArrowBox():void
		{
			this.graphics.beginFill(0x00cc00,1);
			this.graphics.moveTo(BACKING_OFFSET+BACKING_WIDTH,0);
			this.graphics.lineTo(BACKING_OFFSET+BACKING_OFFSET+BACKING_WIDTH,0);
			this.graphics.lineTo(BACKING_OFFSET+BACKING_OFFSET+BACKING_WIDTH,HEIGHT);
			this.graphics.lineTo(BACKING_OFFSET+BACKING_WIDTH,HEIGHT);
			this.graphics.lineTo(BACKING_OFFSET+BACKING_WIDTH,0);
		}
		
	}
}