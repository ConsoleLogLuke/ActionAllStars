package com.sdg.store.nav
{
	import com.sdg.components.controls.store.StoreNavBorder;
	import com.sdg.mvc.ViewBase;
	import com.sdg.store.StoreConstants;
	import com.sdg.store.ToolTip;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.filters.DropShadowFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class StoreNavView extends ViewBase implements IStoreNavView
	{
		public static const GRADIENT_COLOR_1:uint = 0x4180b6;
		public static const GRADIENT_COLOR_2:uint = 0x034282;
		public static const GRADIENT_BLACK:uint = 0x03060a;		

		//protected var _title:TextField;
		protected var _navBorder:StoreNavBorder;
		protected var _buttonList:Array = new Array;
		protected var _navToolTip:ToolTip;
		protected var _buttonContainer:Sprite;

		// Component Locations
		protected var _buttonOffset:Number;
		
		public function StoreNavView()
		{
			super();
		}
		
		override public function init(width:Number, height:Number):void
		{
			super.init(width, height);
			
			//_title = new TextField();
			_navBorder = new StoreNavBorder(200,575);
			//this.addEventListener(StoreNavEvent.NAV_RESET onNavReset,true);
			//_navBorder.borderTop.addEventListener(MouseEvent.CLICK,onViewClick,true);
			//addEventListener(StoreNavEvent.CATEGORY_SELECT, onCategorySelect);
			//_navBorder.setSize(180,400);
			_buttonOffset = 5;
			
			//addChild(_title);
			addChild(_navBorder);
			//makeButtons(width);
			
			// Button container.
			_buttonContainer = new Sprite();
			addChild(_buttonContainer);
			
			render();
		}
		
		public function setBorderMiddleUrl(url:String):void
		{
			_navBorder.borderMiddleUrl = url;
		}
		
		public function setBorderDimensions(width:uint,height:uint):void
		{
			_navBorder.rebuild(width,height);
		}
		
		public function updateNavBorder(borderImage:DisplayObject,location:String):void
		{
			var s:Sprite = new Sprite();
			s = borderImage as Sprite;
			_navBorder.setNavBorderSection(s,location);
		}
		
		public function setBorderStoreId(value:uint):void
		{
			_navBorder.storeId = value;
		}
		
		//public function updateMovieBorder(movie:MovieClip):void
		//{
		//	_navBorder.borderMovieClip = movie;
		//}

		//private function createTemporaryTitle():void
		//{
		//	_title.text = "STORE";
		//	_title.setTextFormat(new TextFormat('EuroStyle',30,0xFFFFFF,true,true));
		//}
		
		//protected function onViewClick(e:MouseEvent):void
		//{
		//	var titleClicked:Boolean  = checkTitleBounds(e.localX,e.localY);
		//	if (titleClicked)
		//	{
		//		var event:StoreNavEvent = new StoreNavEvent(StoreNavEvent.NAV_RESET);
		//		dispatchEvent(event);
		//	}
		//}

		protected function checkTitleBounds(x:int,y:int,storeId:int = -1):Boolean
		{
			var firstBoundsX:int = 0;
			var firstBoundsY:int = 0;
			var firstBoundsWidth:uint = 1;
			var firstBoundsHeight:uint = 1;
			
			if (storeId == StoreConstants.STORE_ID_MLB)
			{
				firstBoundsX = 0;
				firstBoundsY = 0;
				firstBoundsWidth = 1;
				firstBoundsHeight = 1;
			}
			else if (storeId == StoreConstants.STORE_ID_NBA)
			{
				firstBoundsX = 0;
				firstBoundsY = 0;
				firstBoundsWidth = 1;
				firstBoundsHeight = 1;
			}
			else if (storeId == StoreConstants.STORE_ID_RIVERWALK)
			{
				firstBoundsX = 0;
				firstBoundsY = 0;
				firstBoundsWidth = 1;
				firstBoundsHeight = 1; 1;
			}
			else
			{
				firstBoundsX = 7;
				firstBoundsY = 0;
				firstBoundsWidth = 190;
				firstBoundsHeight = 80;
			}
			
			// Check Point
			var firstBounds:Rectangle = new Rectangle(firstBoundsX,firstBoundsY,firstBoundsWidth,firstBoundsHeight);
			var withinFirstBounds:Boolean = firstBounds.containsPoint(new Point(x,y));
			
			if (!withinFirstBounds)
			{
				var secondBoundsX:int = 0;
				var secondBoundsY:int = 0;
				var secondBoundsWidth:uint = 1;
				var secondBoundsHeight:uint = 1;
			
				if (storeId == StoreConstants.STORE_ID_MLB)
				{
					secondBoundsX = 0;
					secondBoundsY = 0;
					secondBoundsWidth = 1;
					secondBoundsHeight = 1;
				}
				else if (storeId == StoreConstants.STORE_ID_NBA)
				{
					secondBoundsX = 0;
					secondBoundsY = 0;
					secondBoundsWidth = 1;
					secondBoundsHeight = 1;
				}
				else if (storeId == StoreConstants.STORE_ID_RIVERWALK)
				{
					secondBoundsX = 0;
					secondBoundsY = 0;
					secondBoundsWidth = 1;
					secondBoundsHeight = 1;
				}
				else
				{
					secondBoundsX = 7;
					secondBoundsY = 0;
					secondBoundsWidth = 190;
					secondBoundsHeight = 80;
				}
			
				// Check Point
				var secondBounds:Rectangle = new Rectangle(secondBoundsX,secondBoundsY,secondBoundsWidth,secondBoundsHeight);
				var withinSecondBounds:Boolean = secondBounds.containsPoint(new Point(x,y));
			
				return withinSecondBounds;
			}
			
			return withinFirstBounds;
		}
		
		//////////////////////
		// RENDERERS
		//////////////////////
		
		override public function render():void
		{
			super.render();
			
			var i:uint = 0;
			var len:uint = _buttonList.length;
			for (i; i < len; i++)
			{
				var button:Sprite = _buttonList[i] as Sprite;
				_buttonContainer.addChild(button);
			}
		}
		
		/////////////////////////
		// GETTERS / SETTERS
		/////////////////////////
		public function get buttonList():Array
		{
			return _buttonList;
		}
		public function set buttonList(value:Array):void
		{
			//remove current buttons before resetting list
			this.removeButtons();
			
			// Reset List
			_buttonList = value;
			// Render New List
			render();
		}
		
		public function set navToolTip(value:ToolTip):void
		{
			// Remove current tooltip.
			if (_navToolTip != null)
			{
				removeChild(_navToolTip);
			}
			
			// Set new one.
			_navToolTip = value;
			_navToolTip.filters = [new DropShadowFilter(4, 45, 0, 0.6, 12, 12)];
			addChild(_navToolTip);
		}
		
		protected function removeButtons():void
		{
			// Remove all buttons
			for each (var b:Sprite in this.buttonList)
			{
				_buttonContainer.removeChild(b);
			}
		}
	}
}