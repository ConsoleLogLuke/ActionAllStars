package com.sdg.components.controls.store
{
	import com.sdg.store.nav.StoreNavEvent;
	import com.sdg.store.StoreConstants;	
	
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;

	public class StoreNavBorder extends Sprite
	{
		// BORDER ALIGNMENT CONSTANTS
		public static const NBALOGO_YSTART:uint = 117;
		public static const NBALOGO_STRETCH_OFFSET:uint = 190;
		public static const NBALOGO_BUTTON_START_X:uint = 9;
		public static const NBALOGO_BUTTON_START_Y:uint = 90;
		public static const MLBLOGO_YSTART:uint = 112;
		public static const MLBLOGO_STRETCH_OFFSET:uint = 184;
		public static const MLBLOGO_BUTTON_START_X:uint = 9;
		public static const MLBLOGO_BUTTON_START_Y:uint = 84;
		public static const AASLOGO_YSTART:uint = 127;
		public static const AASLOGO_STRETCH_OFFSET:uint = 200;
		public static const AASLOGO_BUTTON_START_X:uint = 9;
		public static const AASLOGO_BUTTON_START_Y:uint = 100;
		
		// CLICKABLE AREA CONSTANTS
		public static const NBAHOME1_X:uint = 22;
		public static const NBAHOME1_Y:uint = 1;
		public static const NBAHOME1_WIDTH:uint = 115;
		public static const NBAHOME1_HEIGHT:uint = 33;
		public static const NBAHOME2_X:uint = 22;
		public static const NBAHOME2_Y:uint = 34;
		public static const NBAHOME2_WIDTH:uint = 157;
		public static const NBAHOME2_HEIGHT:uint = 33;
		public static const MLBHOME1_X:uint = 0;
		public static const MLBHOME1_Y:uint = 0;
		public static const MLBHOME1_WIDTH:uint = 123;
		public static const MLBHOME1_HEIGHT:uint = 30;
		public static const MLBHOME2_X:uint = 10;
		public static const MLBHOME2_Y:uint = 30;
		public static const MLBHOME2_WIDTH:uint = 198;
		public static const MLBHOME2_HEIGHT:uint = 30;		
		public static const AASHOME1_X:uint = 0;
		public static const AASHOME1_Y:uint = 0;
		public static const AASHOME1_WIDTH:uint = 163;
		public static const AASHOME1_HEIGHT:uint = 50;
		public static const AASHOME2_X:uint = 72;
		public static const AASHOME2_Y:uint = 30;
		public static const AASHOME2_WIDTH:uint = 133;
		public static const AASHOME2_HEIGHT:uint = 43;		
		
		protected var _storeId:int;
		protected var _width:uint = 220;
		protected var _height:uint = 575;
		protected var _borderMiddleUrl:String;
		//protected var _borderReady:Boolean;
		protected var _borderTop:Sprite;
		protected var _borderMiddle:Sprite;
		protected var _borderBottom:Sprite;
		protected var _homeButton1:Sprite;
		protected var _homeButton2:Sprite;
		
		public function StoreNavBorder(width:uint,height:uint)
		{
			super();
			
			// Initialize Variables
			_width = width;
			_height = height;
			
			_borderTop = new Sprite();
		}
		
		public function rebuild(width:uint,height:uint):void
		{
			_width = width;
			_height = height;
			
			try
			{
				if (_borderTop)
					this.removeChild(_borderTop);
			} catch (error:ArgumentError) {
				// Do Nothing - it means item wasn't there
			}
			try
			{
				if (_borderMiddle)
					this.removeChild(_borderMiddle);
			} catch (error:ArgumentError) {
				// Do Nothing - it means item wasn't there
			}
			try
			{
				if (_borderBottom)
					this.removeChild(_borderBottom);
			} catch (error:ArgumentError) {
				// Do Nothing - it means item wasn't there
			}
			
			render();
		}
		
		public function setNavBorderSection(border:Sprite,location:String):void
		{
			if (location == "top")
			{
				_borderTop = border;
			}
			else if (location == "middle")
			{
				_borderMiddle = border;
			}
			else if (location == "bottom")
			{
				_borderBottom = border;
			}

			render();
		}
		
		
		public function setSize(width:uint,height:uint):void
		{
			_width = width;
			_height = height;
			
			render();
		}
		
		public function set borderMiddleUrl(value:String):void
		{
			_borderMiddleUrl = value;
		}
		
		protected function onClick(e:MouseEvent):void
		{
			var event:StoreNavEvent = new StoreNavEvent(StoreNavEvent.NAV_RESET,0,1,"",true);
			dispatchEvent(event);
		}
		
		//////////////
		// Renderer
		//////////////
		
		protected function preRender():void
		{
			graphics.lineStyle(5,0xFFFFFF);
			graphics.drawRect(0,0,_width,_height);
		}
		
		protected function render():void
		{
			//_titleLink.x = 0;
			//_titleLink.y = 0;
			//_titleLink.width = 200;
			//_titleLink.height = 70;
			//_titleLink.addEventListener(MouseEvent.CLICK,onClick);
			

			//Build the Border
			if (_borderTop && _borderMiddle && _borderBottom)
			{
				//remove templine
				graphics.clear();
				
				_borderTop.x = 2;
				_borderTop.y = 0;
				addChild(_borderTop);
				
				//trace("IS THE STORE ID VALID: "+this._storeId)
				// Stretch Middle to Correct Length
				var i:uint = 0;
				var xStart:uint = 2;
				var yStart:uint = 0;
				var stretchLength:int = 0;
				if (_storeId == StoreConstants.STORE_ID_NBA)
				{
					yStart = NBALOGO_YSTART;
					stretchLength = _height - NBALOGO_STRETCH_OFFSET;
				}
				else if (_storeId == StoreConstants.STORE_ID_MLB)
				{
					yStart = MLBLOGO_YSTART;
					stretchLength = _height - MLBLOGO_STRETCH_OFFSET;
				}
				else if (_storeId == StoreConstants.STORE_ID_VERTVILLAGE)
				{
					yStart = AASLOGO_YSTART;
					stretchLength = _height - AASLOGO_STRETCH_OFFSET;
				}
				else
				{
					yStart = AASLOGO_YSTART;
					stretchLength = _height - AASLOGO_STRETCH_OFFSET;
				}
				_borderMiddle.x = xStart;
				_borderMiddle.y = yStart;
				_borderMiddle.height = stretchLength;
				yStart +=stretchLength;
				
				addChild(_borderMiddle);
				//trace("_HEIGHT: "+_height);
				//trace("NUMBER OF SEGMENTS: "+numLinks);
				
				//for (i; i < numLinks; i++)
				//{
				//	addBorderLink(xStart,yStart);
				//	yStart += 4;
				//}
				_borderBottom.x = 0;
				_borderBottom.y = yStart;
				addChild(_borderBottom);
			}
			
			//Add Clickable Home Button
			_homeButton1 = new Sprite();
			_homeButton2 = new Sprite();
			_homeButton1.graphics.beginFill(0x00ff00,0);
			_homeButton2.graphics.beginFill(0x00ff00,0);
			
			trace("STORE_NAV.Store Id: "+_storeId);
			if (_storeId == StoreConstants.STORE_ID_MLB)
			{
				_homeButton1.graphics.drawRect(MLBHOME1_X,MLBHOME1_Y,MLBHOME1_WIDTH,MLBHOME1_HEIGHT);
				_homeButton1.graphics.drawRect(MLBHOME2_X,MLBHOME2_Y,MLBHOME2_WIDTH,MLBHOME2_HEIGHT);
			}
			else if (_storeId == StoreConstants.STORE_ID_NBA)
			{
				_homeButton1.graphics.drawRect(NBAHOME1_X,NBAHOME1_Y,NBAHOME1_WIDTH,NBAHOME1_HEIGHT);
				_homeButton2.graphics.drawRect(NBAHOME2_X,NBAHOME2_Y,NBAHOME2_WIDTH,NBAHOME2_HEIGHT);
			}
			else if (_storeId == StoreConstants.STORE_ID_RIVERWALK || _storeId == StoreConstants.STORE_ID_VERTVILLAGE)
			{
				
				_homeButton1.graphics.drawRect(AASHOME1_X,AASHOME1_Y,AASHOME1_WIDTH,AASHOME1_HEIGHT);
				_homeButton2.graphics.drawRect(AASHOME2_X,AASHOME2_Y,AASHOME2_WIDTH,AASHOME2_HEIGHT);
			}
			else
			{
				_homeButton1.graphics.drawRect(NBAHOME1_X,NBAHOME1_Y,NBAHOME1_WIDTH,NBAHOME1_HEIGHT);
				_homeButton2.graphics.drawRect(NBAHOME2_X,NBAHOME2_Y,NBAHOME2_WIDTH,NBAHOME2_HEIGHT);
			}
			
			_homeButton1.buttonMode = true;
			_homeButton2.buttonMode = true;
			addChild(_homeButton1);
			addChild(_homeButton2);
			_homeButton1.addEventListener(MouseEvent.CLICK,onClick);
			_homeButton2.addEventListener(MouseEvent.CLICK,onClick);
		}
		
		protected function addBorderLink(startX:uint,startY:uint):void
		{
			var request:URLRequest = new URLRequest(_borderMiddleUrl);
			
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadComplete);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
			loader.load(request);
			
			function onLoadComplete(e:Event):void
			{
				// Remove event listeners.
				loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoadComplete);
				loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
				
				// Pass the loaded background to the view.
				var segment:DisplayObject = loader.content;
				segment.x = startX;
				segment.y = startY;
				addChild(segment);
			}

			function onLoadError(e:IOErrorEvent):void
			{
				// Remove event listeners.
				loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoadComplete);
				loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
			}
		}
		
		protected function onViewClick(e:MouseEvent):void
		{
			var titleClicked:Boolean  = checkTitleBounds(e.localX,e.localY);
			if (titleClicked)
			{
				var event:StoreNavEvent = new StoreNavEvent(StoreNavEvent.NAV_RESET,0,1,"",true);
				dispatchEvent(event);
			}
		}
		
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
			else if (storeId == StoreConstants.STORE_ID_RIVERWALK || storeId == StoreConstants.STORE_ID_VERTVILLAGE)
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
				else if (storeId == StoreConstants.STORE_ID_RIVERWALK || storeId == StoreConstants.STORE_ID_VERTVILLAGE)
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
		
		////////////////////////
		// GETTERS AND SETTERS
		////////////////////////
		
		public function get borderTop():Sprite
		{
			return _borderTop;
		}
		
		public function set storeId(value:uint):void
		{
			_storeId = value;
		}
	}
}