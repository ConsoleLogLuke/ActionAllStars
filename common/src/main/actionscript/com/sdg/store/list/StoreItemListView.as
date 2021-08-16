package com.sdg.store.list
{
	import com.boostworthy.animation.easing.Transitions;
	import com.boostworthy.animation.management.AnimationManager;
	import com.boostworthy.animation.rendering.RenderMethod;
	import com.boostworthy.events.AnimationEvent;
	import com.sdg.events.ScrollEvent;
	import com.sdg.graphics.RayBurst;
	import com.sdg.mvc.ViewBase;
	import com.sdg.store.item.IStoreItemView;
	import com.sdg.store.item.StoreItemViewCollection;
	import com.sdg.store.skin.ScrollBarBacking;
	import com.sdg.store.skin.ScrollBarGrabber;
	import com.sdg.store.skin.ScrollButtonDown;
	import com.sdg.store.skin.ScrollButtonUp;
	import com.sdg.ui.RoundCornerCloseButton;
	import com.sdg.view.ItemListWindow;
	import com.teso.ui.DropDown;
	
	import flash.display.DisplayObject;
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	public class StoreItemListView extends ViewBase implements IStoreItemListView
	{
		protected const NEW_ITEM_VIEWS:String = 'new item views';
		
		protected var _itemWindow:ItemListWindow;
		protected var _background:DisplayObject;
		protected var _windowBackground:DisplayObject;
		protected var _windowMask:Sprite;
		protected var _rayBurstContainer:Sprite;
		protected var _windowBorder:Sprite;
		protected var _winObjsCtnr:Sprite;
		protected var _windowHeader:Sprite;
		protected var _title:TextField;
		protected var _itemSetImage:DisplayObject;
		protected var _sortDropDown:DropDown;
		protected var _currentDetailView:IStoreItemView;
		protected var _windowBacking:Sprite;
		
		protected var _animationManager:AnimationManager;
		
		protected var _itemViews:StoreItemViewCollection;
		
		public function StoreItemListView()
		{
			super();
		}
		
		////////////////////
		// INSTANCE METHODS
		////////////////////
		
		override public function init(width:Number, height:Number):void
		{
			super.init(width, height);
			
			// Create background.
			_background = new Sprite();
			addChild(_background);
			
			// Create window mask.
			_windowMask = new Sprite();
			addChild(_windowMask);
			
			// Window background.
			_windowBacking = new Sprite();
			addChild(_windowBacking);
			
			// Create windowed objects container.
			_winObjsCtnr = new Sprite();
			_winObjsCtnr.mask = _windowMask;
			addChild(_winObjsCtnr);
			
			// Create ray burst container.
			_rayBurstContainer = new Sprite();
			_winObjsCtnr.addChild(_rayBurstContainer);
			
			// Create a test item window.
			_itemWindow = new ItemListWindow(_width, _height, 4, 100, 20, 26);
			_itemWindow.widthHeightRatio = 0.5;
			_itemWindow.useMask = false;
			_winObjsCtnr.addChild(_itemWindow);
			
			// Create scroll bar elements.
			_itemWindow.vScrollBar.scrollButton1 = new ScrollButtonUp(0xffffff);
			_itemWindow.vScrollBar.scrollButton2 = new ScrollButtonDown(0xffffff);
			_itemWindow.vScrollBar.scrollBarBacking = new ScrollBarBacking(0x222222, 0.2);
			_itemWindow.vScrollBar.scrollBarGrabber = new ScrollBarGrabber(0xffffff);
			
			// Adjust scroll bar margins.
			_itemWindow.setVerticalScrollBarMargin(0, 10);
			
			// Window header.
			_windowHeader = new Sprite();
			_windowHeader.filters = [new DropShadowFilter(2, 45, 0, 1, 8, 8)];
			_winObjsCtnr.addChild(_windowHeader);
			
			// Window border.
			_windowBorder = new Sprite();
			addChild(_windowBorder);
			
			// Item set image.
			var s:Sprite = new Sprite();
			s.graphics.beginFill(0xffffff);
			s.graphics.drawRect(0, 0, 100, 100);
			_itemSetImage = s;
			_windowHeader.addChild(_itemSetImage);
			
			// Title.
			_title = new TextField();
			_title.defaultTextFormat = new TextFormat('EuroStyle', 14, 0xffffff);
			_title.autoSize = TextFieldAutoSize.LEFT;
			_title.filters = [new DropShadowFilter(2, 45, 0, 0.8, 4, 4)];
			_title.embedFonts = true;
			_title.selectable = false;
			_windowHeader.addChild(_title);
			
			// Create sort dropdown.
			var dropSortArray:Array = new Array();
			dropSortArray.push( {title:"Default", name:StoreItemListSort.DEFAULT} );
			dropSortArray.push( {title:"Price", name:StoreItemListSort.PRICE} );
			dropSortArray.push( {title:"Type", name:StoreItemListSort.ITEM_TYPE} );
			dropSortArray.push( {title:"Level", name:StoreItemListSort.LEVEL} );
			var dropFmat:TextFormat = new TextFormat('EuroStyle', 12, 0xffffff);
			_sortDropDown = new DropDown(120, 23, " Sort By:", dropFmat, 0x285890, dropSortArray, "down", onSortSelect, true);
			_windowHeader.addChild(_sortDropDown);
			
			// Animation manager.
			_animationManager = new AnimationManager();
			
			render();
		}
		
		////////////////////
		// PUBLIC FUNCTIONS
		////////////////////
		
		override public function destroy():void
		{
			super.destroy();
			
			// Do all cleanup work.
			if (_currentDetailView != null) _currentDetailView.destroy();
			
			// Dispose animation manager.
			_animationManager.dispose();
			_animationManager = null;
		}
		
		override public function render():void
		{
			super.render();
			
			_background.width = _width;
			_background.height = _height;
			
			// Draw window mask.
			_windowMask.graphics.clear();
			_windowMask.graphics.beginFill(0x00ff00);
			drawWindowShape(_windowMask.graphics);
			
			// Draw window backing.
			var gradMatrix:Matrix = new Matrix();
			gradMatrix.createGradientBox(_windowMask.width, _windowMask.height, Math.PI / 2);
			_windowBacking.graphics.clear();
			_windowBacking.graphics.beginGradientFill(GradientType.LINEAR, [0x87bff5, 0x27419e], [1, 1], [1, 255], gradMatrix);
			drawWindowShape(_windowBacking.graphics);
			
			// Draw window border.
			_windowBorder.graphics.clear();
			_windowBorder.graphics.lineStyle(2, 0xdddddd);
			drawWindowShape(_windowBorder.graphics);
			
			// Get window mask bounds.
			var windowBounds:Rectangle = _windowMask.getBounds(this);
			
			// Render window background.
			if (_windowBackground != null)
			{
				_windowBackground.x = windowBounds.x;
				_windowBackground.y = windowBounds.y;
				_windowBackground.width = windowBounds.width;
				_windowBackground.height = windowBounds.height;
			}
			
			// Draw window header.
			var headerHeight:Number = 55;
			_windowHeader.graphics.clear();
			var gM:Matrix = new Matrix();
			gM.createGradientBox(windowBounds.width, headerHeight, Math.PI / 2);
			_windowHeader.graphics.beginGradientFill(GradientType.LINEAR, [0x0e2d47, 0x0a1724], [1, 1], [1, 255], gM);
			_windowHeader.graphics.drawRect(0, 0, windowBounds.width, headerHeight);
			_windowHeader.x = windowBounds.x;
			_windowHeader.y = windowBounds.y;
			
			// Size and position item set image.
			var itmImgScale:Number = (headerHeight - 10) / _itemSetImage.height;
			_itemSetImage.width *= itmImgScale;
			_itemSetImage.height *= itmImgScale;
			_itemSetImage.x = 30;
			_itemSetImage.y = 5;
			
			// Position header.
			_title.x = _itemSetImage.x + _itemSetImage.width + 10;
			_title.y = 5;
			
			// Position drop down.
			_sortDropDown.x = _title.x;
			_sortDropDown.y = _title.y + _title.height;
			
			_itemWindow.width = windowBounds.width;
			_itemWindow.height = windowBounds.height - headerHeight;
			_itemWindow.x = windowBounds.x;
			_itemWindow.y = windowBounds.y + headerHeight;
		}
		
		public function showDetailView(itemView:IStoreItemView):void
		{
			// Get bounds of window area.
			var windowBounds:Rectangle = _windowMask.getBounds(this);
			
			_currentDetailView = itemView;
			
			var container:Sprite = new Sprite();
			container.graphics.beginFill(0x121e34, 0.95);
			container.graphics.drawRect(0, 0, windowBounds.width, windowBounds.height);
			container.x = windowBounds.x;
			container.y = windowBounds.y;
			container.addChild(itemView.display);
			
			itemView.width = windowBounds.width - 40;
			itemView.height = windowBounds.height - 40;
			itemView.x = windowBounds.width / 2 - itemView.width / 2;
			itemView.y = windowBounds.height / 2 - itemView.height / 2;
			
			var closeBtn:Sprite = new RoundCornerCloseButton('Close Detail');
			closeBtn.x = container.width - closeBtn.width - 10;
			closeBtn.y = 10;
			closeBtn.buttonMode = true;
			closeBtn.addEventListener(MouseEvent.CLICK, onCloseClick);
			container.addChild(closeBtn);
			
			addEventListener(NEW_ITEM_VIEWS, onNewItemViews);
			
			_winObjsCtnr.addChild(container);
			
			function onCloseClick(e:MouseEvent):void
			{
				close();
			}
			
			function onNewItemViews(e:Event):void
			{
				close();
			}
			
			function close():void
			{
				// Remove event listeners.
				closeBtn.removeEventListener(MouseEvent.CLICK, onCloseClick);
				removeEventListener(NEW_ITEM_VIEWS, onNewItemViews);
				
				// Remove detail view.
				_winObjsCtnr.removeChild(container);
				
				// Handle clean up.
				_currentDetailView = null;
				itemView.destroy();
				
				// Dispatch event.
				dispatchEvent(new Event(StoreItemListEvent.REMOVED_DETAIL_VIEW));
			}
		}
		
		////////////////////
		// PROTECTED FUNCTIONS
		////////////////////
		
		protected function addItemListeners(items:StoreItemViewCollection):void
		{
			var i:uint = 0;
			var len:uint = items.length;
			for (i; i < len; i++)
			{
				var item:IStoreItemView = items.getAt(i);
				item.addEventListener(MouseEvent.ROLL_OVER, onItemOver);
			}
		}
		
		protected function removeItemListeners(items:StoreItemViewCollection):void
		{
			var i:uint = 0;
			var len:uint = items.length;
			for (i; i < len; i++)
			{
				var item:IStoreItemView = items.getAt(i);
				item.removeEventListener(MouseEvent.ROLL_OVER, onItemOver);
			}
		}
		
		protected function drawWindowShape(graphics:Graphics):void
		{
			graphics.moveTo(36, 31);
			graphics.lineTo(409, 31);
			graphics.curveTo(429, 31, 429, 51);
			graphics.lineTo(429, 582);
			graphics.lineTo(408, 598);
			graphics.lineTo(35, 598);
			graphics.curveTo(15, 598, 15, 578);
			graphics.lineTo(15, 46);
			graphics.lineTo(36, 31);
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		public function set itemViews(value:StoreItemViewCollection):void
		{
			// Clean up previous objects.
			if (_itemViews != null)
			{
				removeItemListeners(_itemViews);
			}
			
			// Set new items.
			_itemViews = value;
			addItemListeners(_itemViews);
			
			// Pass display objects to the item window.
			_itemWindow.items = _itemViews.toDisplayObjectCollection();
			
			// Reset scroll value.
			_itemWindow.scrollValueY = 0;
			
			// Dispatch event that says there are new item views.
			dispatchEvent(new Event(NEW_ITEM_VIEWS));
		}
		
		public function set background(value:DisplayObject):void
		{
			// Remove existing background.
			if (_background != null)
			{
				removeChild(_background);
			}
			
			// Set new one.
			_background = value;
			addChildAt(_background, 0);
			
			// Try to disable the backgrounds mouse functionality.
			var spriteBack:Sprite = _background as Sprite;
			if (spriteBack != null) spriteBack.mouseEnabled = spriteBack.mouseChildren = false;
			
			render();
		}
		
		public function set windowBackground(value:DisplayObject):void
		{
			// Remove existing background.
			if (_windowBackground != null)
			{
				_winObjsCtnr.removeChild(_windowBackground);
			}
			
			// Set new one.
			_windowBackground = value;
			_winObjsCtnr.addChildAt(_windowBackground, 0);
			
			// Try to disable the backgrounds mouse functionality.
			var spriteBack:Sprite = _windowBackground as Sprite;
			if (spriteBack != null) spriteBack.mouseEnabled = spriteBack.mouseChildren = false;
			
			render();
		}
		
		public function set itemSetName(value:String):void
		{
			_title.text = value;
		}
		
		public function set itemSetImage(value:DisplayObject):void
		{
			// Remove previous.
			if (_itemSetImage != null)
			{
				_windowHeader.removeChild(_itemSetImage);
			}
			
			// Set new one.
			_itemSetImage = value;
			_windowHeader.addChild(_itemSetImage);
			
			render();
		}
		
		public function set sortType(value:String):void
		{
			_sortDropDown.selectOptionByName(value);
		}
		
		////////////////////
		// EVENT HANDLERS
		////////////////////
		
		private function onItemOver(e:MouseEvent):void
		{
			// Create a ray burst behind the rolled over item.
			
			// Get a reference to the item.
			var item:IStoreItemView = e.currentTarget as IStoreItemView;
			if (item == null) return;
			
			// Determine bounds of the item.
			var bounds:Rectangle = item.thumbnail.getBounds(this);
			
			// Listen for item window scroll events.
			_itemWindow.addEventListener(ScrollEvent.SCROLL, onScroll);
			
			// Listen for roll out.
			item.addEventListener(MouseEvent.ROLL_OUT, onItemOut);
			
			// Create the ray burst.
			var ray:RayBurst = new RayBurst(bounds.width, 8, 0x00ff00);
			_rayBurstContainer.addChild(ray);
			var orb:Sprite = new Sprite();
			var orbSize:Number = bounds.width * 1.6;
			var gradMatrix:Matrix = new Matrix();
			gradMatrix.createGradientBox(orbSize, orbSize, 0, -orbSize / 2, -orbSize / 2);
			orb.graphics.beginGradientFill(GradientType.RADIAL, [0xffffff, 0xffffff], [0.8, 0], [1, 255], gradMatrix);
			orb.graphics.drawCircle(0, 0, orbSize / 2);
			orb.alpha = 0;
			orb.mask = ray;
			_rayBurstContainer.addChild(orb);
			
			// Position the effect elements.
			positionEffect();
			
			// Fade in orb.
			_animationManager.alpha(orb, 1, 500, Transitions.CUBIC_OUT, RenderMethod.ENTER_FRAME);
			
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			
			function onItemOut(e:MouseEvent):void
			{
				// Remove event listeners.
				item.removeEventListener(MouseEvent.ROLL_OUT, onItemOut);
				_itemWindow.removeEventListener(ScrollEvent.SCROLL, onScroll);
				
				// Fade out orb.
				_animationManager.addEventListener(AnimationEvent.FINISH, onAnimFinish);
				_animationManager.alpha(orb, 0, 500, Transitions.CUBIC_OUT, RenderMethod.ENTER_FRAME);
			}
			
			function onEnterFrame(e:Event):void
			{
				ray.rotation += 0.6;
			}
			
			function onAnimFinish(e:AnimationEvent):void
			{
				// If the orb finished fading out, remove it.
				if (e.animTarget == orb && orb.alpha == 0)
				{
					// Remove event listeners.
					_animationManager.removeEventListener(AnimationEvent.FINISH, onAnimFinish);
					removeEventListener(Event.ENTER_FRAME, onEnterFrame);
					
					// Remove ray burst.
					_rayBurstContainer.removeChild(ray);
					_rayBurstContainer.removeChild(orb);
				}
			}
			
			function positionEffect():void
			{
				// Determine bounds of the item.
				bounds = item.thumbnail.getBounds(display);
				
				// Position effect elements.
				ray.x = bounds.x + bounds.width / 2;
				ray.y = bounds.y + bounds.height / 2;
				orb.x = bounds.x + bounds.width / 2;
				orb.y = bounds.y + bounds.height / 2;
			}
			
			function onScroll(e:ScrollEvent):void
			{
				positionEffect();
			}
		}
		
		private function onSortSelect(e:Event):void
		{
			var sortName:String = e.currentTarget.name;
			var event:StoreItemListSortEvent = new StoreItemListSortEvent(StoreItemListSortEvent.SORT_SELECT, sortName);
			dispatchEvent(event);
		}
		
	}
}