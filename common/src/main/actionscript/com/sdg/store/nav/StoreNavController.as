package com.sdg.store.nav
{
	import com.sdg.components.controls.store.StoreNavBorder;
	import com.sdg.model.DisplayObjectCollection;
	import com.sdg.model.StoreCategory;
	import com.sdg.net.Environment;
	import com.sdg.store.StoreConstants;
	import com.sdg.store.icon.StoreNavIcon;
	import com.sdg.store.util.StoreUtil;
	import com.sdg.view.ItemListWindow;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Point;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import mx.collections.ArrayCollection;

	public class StoreNavController extends EventDispatcher implements IStoreNavController
	{
		protected var _model:IStoreNavModel;
		protected var _subCategoryWindow:ItemListWindow;
		
		public function StoreNavController(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		public function init(model:IStoreNavModel):void
		{
			// Set reference to the model.
			_model = model;
			
			// Initialize the view.
			_model.view.init(_model.defaultWidth, _model.defaultHeight);
			
			// Listen to self for events
			addEventListener(StoreNavEvent.NAV_UPDATE, onNavUpdate);
			addEventListener(StoreNavEvent.CATEGORY_SELECT, onCategorySelect);	
			
			// Listen to model for events.
			_model.addEventListener(StoreNavEvent.NAV_UPDATE, onNavUpdate);
			_model.addEventListener(StoreNavEvent.NEW_BORDER_URL, onNewNavBorderUrl);
			
			// Listen to View for events.
			_model.view.addEventListener(StoreNavEvent.NAV_RESET, onNavReset);
		}
		
		protected function onCategorySelect(e:StoreNavEvent):void
		{

			if (e.tier == 1)
			{
				// Update the current category with the new category id
				_model.currentCategory = e.categoryId;
			}
			else if (e.tier == 2)
			{
				// Update the current category with its current value
				_model.currentCategory = _model.currentCategory;
			}
		}
		
		protected function onNewNavBorderUrl(categoryId:int):void
		{
			loadNavBorderSection(categoryId,"top");
			loadNavBorderSection(categoryId,"middle");
			loadNavBorderSection(categoryId,"bottom");
		}
		
		protected function loadNavBorderSection(categoryId:int,location:String):void
		{
			// Get Border URL
			var url:String = "";
			if (location == "top")
			{
				url = _model.navBorderTopUrl;
			}
			else if (location == "middle")
			{
				url = _model.navBorderMiddleUrl;
			}
			else if (location == "bottom")
			{
				url = _model.navBorderBottomUrl;
			}
			var request:URLRequest = new URLRequest(url);
			
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
				_model.view.updateNavBorder(loader.content,location);
			}

			function onLoadError(e:IOErrorEvent):void
			{
				// Remove event listeners.
				loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoadComplete);
				loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
			}
		}
		
		public function testloadMovieClip():void
		{
			var clip:MovieClip = new MovieClip();
			
			// Load the movieclip
			var url:String = Environment.getAssetUrl() + '/test/gameSwf/gameId/70/gameFile/navShape.swf';
			var request:URLRequest = new URLRequest(url); 
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
				clip.addChild(loader.content);
			}

			function onLoadError(e:IOErrorEvent):void
			{
				// Remove event listeners.
				loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoadComplete);
				loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
			}
		}
		
		private function onNavReset(e:StoreNavEvent):void
		{
			// Completely Reset Current Category
			_model.resetCurrentCategory();

			//List of buttons to pass to the view
			var bList:Array = new Array();
			
			var isFirst:Boolean = false;
			var isLast:Boolean = false;
			
			//Parse the store data to determine buttons
			//For Each Main Category, create a set of sub-category objects
			//Send each of these sets one at a time to the model
			var nextButtonLoc:Point = new Point(0,0);
			if (_model.storeId == StoreConstants.STORE_ID_NBA)
			{
				nextButtonLoc = new Point(StoreNavBorder.NBALOGO_BUTTON_START_X,StoreNavBorder.NBALOGO_BUTTON_START_Y);
			}
			else if (_model.storeId == StoreConstants.STORE_ID_MLB)
			{
				nextButtonLoc = new Point(StoreNavBorder.MLBLOGO_BUTTON_START_X,StoreNavBorder.MLBLOGO_BUTTON_START_Y);
			}
			else if (_model.storeId == StoreConstants.STORE_ID_VERTVILLAGE)
			{
				nextButtonLoc = new Point(StoreNavBorder.AASLOGO_BUTTON_START_X,StoreNavBorder.AASLOGO_BUTTON_START_Y);
			}
			else
			{
				nextButtonLoc = new Point(StoreNavBorder.AASLOGO_BUTTON_START_X,StoreNavBorder.AASLOGO_BUTTON_START_Y);
			}
			
			_model.storeName = _model.store.name;
			var tier1buttons:ArrayCollection = _model.store.rootCategories;
			var i:uint = 0;
			var len:uint = tier1buttons.length
			for (i; i < len; i++)
			{
				var cat:StoreCategory = tier1buttons.getItemAt(i) as StoreCategory;
				
				//Check for first and last button
				if (i == 0)
				{
					isFirst = true;
				}
				else if (i == (len - 1))
				{
					isLast = true;
				}
				
				// Create Button
				var button:Sprite = buildNavObject(nextButtonLoc, 190,40,cat.id,cat.name,isFirst,isLast);
				bList.push(button);
				
				isFirst = false;
				isLast = false;
				
				// increment Point Object
				nextButtonLoc = new Point(nextButtonLoc.x,nextButtonLoc.y+40);
			}
				
			//Set Size of Nav Border
			_model.view.setBorderDimensions(200,nextButtonLoc.y+40)
			
			// Give finished buttons to view for rendering
			_model.view.buttonList = bList;
		}
		
		private function onNavUpdate(e:StoreNavEvent):void
		{
			//List of buttons to pass to the view
			var bList:Array = new Array();
			
			var isFirst:Boolean = false;
			var isLast:Boolean = false;
			
			//Parse the store data to determine buttons
			//For Each Main Category, create a set of sub-category objects
			//Send each of these sets one at a time to the model
			var nextButtonLoc:Point = new Point(0,0);
			if (_model.storeId == StoreConstants.STORE_ID_NBA)
			{
				nextButtonLoc = new Point(StoreNavBorder.NBALOGO_BUTTON_START_X,StoreNavBorder.NBALOGO_BUTTON_START_Y);
			}
			else if (_model.storeId == StoreConstants.STORE_ID_MLB)
			{
				nextButtonLoc = new Point(StoreNavBorder.MLBLOGO_BUTTON_START_X,StoreNavBorder.MLBLOGO_BUTTON_START_Y);
			}
			else if (_model.storeId == StoreConstants.STORE_ID_VERTVILLAGE)
			{
				nextButtonLoc = new Point(StoreNavBorder.AASLOGO_BUTTON_START_X,StoreNavBorder.AASLOGO_BUTTON_START_Y);
			}
			else
			{
				nextButtonLoc = new Point(StoreNavBorder.AASLOGO_BUTTON_START_X,StoreNavBorder.AASLOGO_BUTTON_START_Y);
			}
			
			
			_model.storeName = _model.store.name;
			var tier1buttons:ArrayCollection = _model.store.rootCategories;
			var i:uint = 0;
			var len:uint = tier1buttons.length
			for (i; i < len; i++)
			{
				var cat:StoreCategory = tier1buttons.getItemAt(i) as StoreCategory;
				
				//Check for first and last button
				if (i == 0)
				{
					isFirst = true;
				}
				else if (i == (len - 1))
				{
					isLast = true;
				}
				
				// Create Button
				
				trace("DEBUG - From StoreNavController, StoreNavBar is passed: "+cat.name);
				
				var button:Sprite = buildNavObject(nextButtonLoc, 190,40,cat.id,cat.name,isFirst,isLast);
				bList.push(button);
				
				isFirst = false;
				isLast = false;
				
				// increment Point Object
				nextButtonLoc = new Point(nextButtonLoc.x,nextButtonLoc.y+40);
				
				// Check if the player has selected a category
				if (_model.currentCategory != -1)
				{
					// If the player has, check if this is it
					if (cat.id == _model.currentCategory)
					{
						// drill down into category for the store
						var subCats:ArrayCollection = cat.childCategories;
						
						if (subCats.length > 0)
						{

							// Create NavObject to place categories into
							var catIcons:ItemListWindow = new ItemListWindow(190,300,3,100,5);
							catIcons.isScrollBarVisible = false;
							catIcons.x = nextButtonLoc.x;
							catIcons.y = nextButtonLoc.y;
							
							subCategoryWindow = catIcons;
						
							var icons:DisplayObjectCollection = new DisplayObjectCollection;
							var y:uint = 0;
							var len2:uint = subCats.length;
							for (y; y < len2; y++)
							{
								var category:StoreCategory = subCats.getItemAt(y) as StoreCategory;

								var newIcon:StoreNavIcon = new StoreNavIcon(category.id,category.name);
								addLoadingIcon(newIcon);
								loadBitmap(newIcon,category);
								newIcon.addEventListener(MouseEvent.CLICK,onIconClick,true);
								newIcon.addEventListener(MouseEvent.ROLL_OVER, onIconRollover);

								icons.push(newIcon);
							}
												
							catIcons.items = icons;
						
							bList.push(catIcons);
						
							// increment Point Object
							nextButtonLoc = new Point(nextButtonLoc.x,nextButtonLoc.y+300);
						}
					}
				}
			}
			
			function onIconRollover(e:MouseEvent):void
			{
				// Play Sound
				_model.remoteSoundBank.playSound(_model.rolloverSoundUrl);
				
				// Get a reference to the icon.
				var icon:StoreNavIcon = e.currentTarget as StoreNavIcon;

				if (icon == null) return;
					
				// Get original scale.
				var originalScaleX:Number = icon.scaleX;
				var originalScaleY:Number = icon.scaleY;
				
				// Get Original x,y Coordinates
				var originalXPoint:Number = icon.x;
				var originalYPoint:Number = icon.y;
					
				// Get Original Width, Height
				var originalWidth:Number = icon.width;
				var originalHeight:Number = icon.height;
					
				// Change the scale of the icon.
				icon.scaleX = 1.3;
				icon.scaleY = 1.3;
				
				// Determine Change of Width and Height
				var deltaWidth:Number = 0.3 * originalWidth;
				var deltaHeight:Number = 0.3 * originalHeight;
				
				icon.x -= (deltaWidth / 2);
				icon.y -= (deltaHeight / 2);
				
				// Throw An Event for Tooltip
				var overEvent:StoreNavEvent = new StoreNavEvent(StoreNavEvent.ROLL_OVER, 0,1,icon.iconName);
				dispatchEvent(overEvent);
					
				// Listen for mouse out.
				icon.addEventListener(MouseEvent.ROLL_OUT, onRollOut);
					
				function onRollOut(e:MouseEvent):void
				{
					// Remove event listener.
					icon.removeEventListener(MouseEvent.ROLL_OUT, onRollOut);
						
					// Return to original scale.
					icon.scaleX = originalScaleX;
					icon.scaleY = originalScaleY;
					
					// Return to Original Coordinates
					icon.x = originalXPoint;
					icon.y = originalYPoint;
					
					// Throw a roll_out event to the controller
					var outEvent:StoreNavEvent = new StoreNavEvent(StoreNavEvent.ROLL_OUT);
					dispatchEvent(outEvent);
				}
			}
			
			//Set Size of Nav Border
			_model.view.setBorderDimensions(200,nextButtonLoc.y+40)
			
			// Give finished buttons to view for rendering
			_model.view.buttonList = bList;
			
			function onIconClick(e:MouseEvent):void
			{
				// Play Sound
				_model.remoteSoundBank.playSound(_model.selectSoundUrl);
				
				var event:StoreNavEvent = new StoreNavEvent(StoreNavEvent.CATEGORY_SELECT,e.currentTarget.id, 2, "",true);
				dispatchEvent(event);
			}
		}
		
		private function buildNavObject(startPoint:Point,width:Number,height:Number,tier1CategoryId:int=0,tier1Category:String=null,first:Boolean = false,last:Boolean = false):Sprite
		{
			var uppercaseCategory:String = tier1Category.toUpperCase();
			//var button:StoreNavBar = new StoreNavBar(width,height,uppercaseCategory);
			//var offStyle:BoxStyle = new BoxStyle(new GradientFillStyle(GradientType.LINEAR, [0x4180b6, 0x03060a], [1, 1], [1, 255], Math.PI / 2), 0, 0, 0, 0);
			//var overStyle:BoxStyle = new BoxStyle(new GradientFillStyle(GradientType.LINEAR, [0x034282, 0x03060a], [1, 1], [1, 255], Math.PI / 2), 0, 0, 0, 0);
			//var buttonStyle:ButtonSyle = new ButtonSyle(offStyle, overStyle, overStyle);
			//var button:BasicButton;
			//if (first)
			//{
			//	button = new StoreNavButtonTop(uppercaseCategory, width, height, buttonStyle);
			//}
			//else if (last)
			//{
			//	button = new StoreNavButtonBottom(uppercaseCategory, width, height, buttonStyle);
			//}
			//else
			//{
			//	button = new BasicButton(uppercaseCategory, width, height, buttonStyle);
			//	button.alignX = AlignType.LEFT;
			//	button.label.autoSize = TextFieldAutoSize.LEFT;
			//	button.paddingLeft = 10;				
			//}
			//button.x = startPoint.x;
			//button.y = startPoint.y;
			//button.labelFormat = new TextFormat('EuroStyle', 20, 0xFFFFFF, true, true);
			//button.label.filters = [new DropShadowFilter(2, 45, 0, 1, 4, 4)];
			//button.embedFonts = true;
			//button.addEventListener(MouseEvent.CLICK,onClick);
			//button.addEventListener(MouseEvent.MOUSE_OVER,onMouseOver);
			//button.buttonMode = true;

			//return button;
			
			var storeButton:StoreNavButton = new StoreNavButton(uppercaseCategory,width,height);
			storeButton.x = startPoint.x;
			storeButton.y = startPoint.y;
			storeButton.labelFormat = new TextFormat('EuroStyle', 20, 0xFFFFFF, true, true);
			storeButton.label.filters = [new DropShadowFilter(2, 45, 0, 1, 4, 4)];
			storeButton.embedFonts = true;
			storeButton.addEventListener(MouseEvent.CLICK,onClick);
			storeButton.addEventListener(MouseEvent.MOUSE_OVER,onMouseOver);
			return storeButton;

			function onClick(e:MouseEvent):void
			{
				// Play Sound
				_model.remoteSoundBank.playSound(_model.selectSoundUrl);
				
				var event:StoreNavEvent = new StoreNavEvent(StoreNavEvent.CATEGORY_SELECT,tier1CategoryId, 1, "",true);
				dispatchEvent(event);
			}
			
			function onMouseOver(e:MouseEvent):void
			{
				// Play Sound
				_model.remoteSoundBank.playSound(_model.rolloverSoundUrl);
			}
		}
		
		protected function loadBitmap(icon:StoreNavIcon,cat:StoreCategory):void
		{
			var url:String = StoreUtil.GetCategoryThumbnailUrl(cat.id);
			//var url:String = 'http://dev/test/inventoryThumbnail?itemId=2685';
			var request:URLRequest = new URLRequest(url);
			//var request:URLRequest = new URLRequest("http://mdr-qa01/test/static/categoryThumbSwf?categoryId=2066");
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
			loader.load(request);
			
			function onComplete(e:Event):void
			{
				// Get a reference to the loader info.
				var loaderInfo:LoaderInfo = e.currentTarget as LoaderInfo;

				// Remove event listeners.
				loaderInfo.removeEventListener(Event.COMPLETE, onComplete);
				loaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onError);
				
				// Get a reference to the loaded url.
				var url:String = loaderInfo.url;
				
				// Get a reference to the item display.
				if (icon == null) return;

				var content:DisplayObject = loaderInfo.content;
				var contentRatio:int = content.width / content.height;
				var scaleDown:int = icon.width - content.width;
				var adjustment:int = icon.width / content.width;

				var newW:Number = content.width;
				var newH:Number = content.height;
				var scale:Number;
				if (content.width > content.height)
				{
					scale = icon.width / content.width;
					newW = content.width * scale;
					newH = content.height * scale;
				}
				else
				{
					scale = icon.height / content.height;
					newW = content.width * scale;
					newH = content.height * scale;
				}

				content.width = newW;
				content.height = newH;

				icon.image = content;
			}
			
			function onError(e:IOErrorEvent):void
			{
				// Get a reference to the loader info.
				var loaderInfo:LoaderInfo = e.currentTarget as LoaderInfo;
				
				// Remove event listeners.
				loaderInfo.removeEventListener(Event.COMPLETE, onComplete);
				loaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onError);
			}
		}
		
		protected function loadTestBitmap(icon:StoreNavIcon,bitmapURL:String):void
		{
			var url:String = bitmapURL;
			//var url:String = 'http://dev/test/inventoryThumbnail?itemId=2685';
			var request:URLRequest = new URLRequest(url);
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
			loader.load(request);
			
			function onComplete(e:Event):void
			{
				// Get a reference to the loader info.
				var loaderInfo:LoaderInfo = e.currentTarget as LoaderInfo;

				// Remove event listeners.
				loaderInfo.removeEventListener(Event.COMPLETE, onComplete);
				loaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onError);
				
				// Get a reference to the loaded url.
				var url:String = loaderInfo.url;
				
				// Get a reference to the item display.
				if (icon == null) return;
				
				// Create a bitmap copy of the loaded content.
				// Use bitmap smoothing.
				// Set the thumbnail as the bitmap copy.
				var content:DisplayObject = loaderInfo.content;
				var bitmapData:BitmapData = new BitmapData(content.width, content.height, true, 0xffffff);
				bitmapData.draw(content);
				var bitmap:Bitmap = new Bitmap(bitmapData, 'auto', true);
				
				// Set the thumbnail as the loaded content.
				icon.image = bitmap;
			}
			
			function onError(e:IOErrorEvent):void
			{
				// Get a reference to the loader info.
				var loaderInfo:LoaderInfo = e.currentTarget as LoaderInfo;
				
				// Remove event listeners.
				loaderInfo.removeEventListener(Event.COMPLETE, onComplete);
				loaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onError);
			}
		}
		
		protected function makeTextSprite(category:StoreCategory):Sprite
		{
			var output:Sprite = new Sprite();
			var textLabel:TextField = new TextField();
			textLabel.text = category.name;

			output.graphics.drawRect(0,0,10,10);
			output.buttonMode = true;
			output.addChild(textLabel);
			output.addEventListener(MouseEvent.CLICK,onClick);
			
			return output;
			
			function onClick(e:MouseEvent):void
			{
				var event:StoreNavEvent = new StoreNavEvent(StoreNavEvent.SUB_CATEGORY_SELECT,category.id);
				dispatchEvent(event);
			}
		}
		
		protected function addLoadingIcon(icon:StoreNavIcon):void
		{
			// Create a loading indicator as a placeholder for the item thumbnail.
			//var loadIndicator:DisplayObject = new StarLoadingIndicator();
			var loadIndicator:DisplayObject = new SpinningLoadingIndicator();

			// Hard-Code an offset
			loadIndicator.x = 14;
			loadIndicator.y = 10;

			icon.image = loadIndicator;
		}
		
		protected function set subCategoryWindow(value:ItemListWindow):void
		{
			// Remove listeners from previous.
			if (_subCategoryWindow != null)
			{
				_subCategoryWindow.removeEventListener(MouseEvent.ROLL_OVER, onSubCategoryWindowOver);
			}
			
			// Set new one.
			_subCategoryWindow = value;
			
			// Add listeners to new one.
			_subCategoryWindow.addEventListener(MouseEvent.ROLL_OVER, onSubCategoryWindowOver);
		}
		
		////////////////////
		// EVENT HANDLERS
		////////////////////
		
		private function onSubCategoryWindowOver(e:MouseEvent):void
		{
			trace("OnSubCategoryWindowOver called");
			
			var value:Number = 0;
			
			// Listen for mouse out and mouse move.
			_subCategoryWindow.addEventListener(MouseEvent.ROLL_OUT, onMouseOut);
			_subCategoryWindow.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			_subCategoryWindow.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			
			function onMouseOut(e:MouseEvent):void
			{
				// Remove listeners.
				_subCategoryWindow.removeEventListener(MouseEvent.ROLL_OUT, onMouseOut);
				_subCategoryWindow.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
				_subCategoryWindow.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			}
			
			function onMouseMove(e:MouseEvent):void
			{
				var mY:Number = _subCategoryWindow.mouseY;
				var wH:Number = _subCategoryWindow.height;
				var centerDis:Number = mY - (wH / 2);
				var dir:Number = (centerDis < 0) ? -1 : 1;
				centerDis = Math.abs(centerDis);
				centerDis = Math.max(0, centerDis - wH / 6);
				
				value = centerDis / wH * dir;
				
				//value = mY / wH - 0.5;
			}
			
			function onEnterFrame(e:Event):void
			{
				_subCategoryWindow.scrollValueY += (value / 30);
			}
		}
		
	}
}