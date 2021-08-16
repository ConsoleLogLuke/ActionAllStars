package com.sdg.store
{
	import com.boostworthy.animation.easing.Transitions;
	import com.boostworthy.animation.management.AnimationManager;
	import com.boostworthy.animation.rendering.RenderMethod;
	import com.sdg.mvc.ViewBase;
	import com.sdg.store.home.IStoreHomeView;
	import com.sdg.store.list.IStoreItemListView;
	import com.sdg.store.nav.IStoreNavView;
	import com.sdg.store.preview.IStoreAvatarPreviewView;
	import com.sdg.ui.GoodCloseButton;
	import com.sdg.ui.RoundCornerCloseButton;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Rectangle;

	public class StoreView extends ViewBase implements IStoreView
	{
		protected var _backing:Sprite;
		protected var _closeButton:GoodCloseButton;
		protected var _margin:Number;
		
		protected var _itemListView:IStoreItemListView;
		protected var _navView:IStoreNavView;
		protected var _avatarPreviewView:IStoreAvatarPreviewView;
		protected var _homeView:IStoreHomeView;
		protected var _background:DisplayObject;
		protected var _shopKeeper:DisplayObject;
		
		protected var _navArea:Rectangle;
		protected var _itemListArea:Rectangle;
		protected var _avatarPreviewArea:Rectangle;
		protected var _toolTip:ToolTip;
		protected var _isHomeView:Boolean;
		protected var _animationManager:AnimationManager;
		protected var _shopKeeperHidden:Boolean;
		
		public function StoreView()
		{
			super();
		}
		
		////////////////////
		// INSTANCE METHODS
		////////////////////
		
		override public function init(width:Number, height:Number):void
		{
			super.init(width, height);
			
			// Default values.
			_margin = 10;
			_isHomeView = true;
			_animationManager = new AnimationManager();
			_shopKeeperHidden = false;
			
			// Instatiate standard visual components of the store.
			_backing = new Sprite();
			_closeButton = new RoundCornerCloseButton('Close Store');
			
			// Set rectangles.
			_navArea = new Rectangle(10, 10, _width - 20, _height - 20);
			_itemListArea = new Rectangle(10, 10, _width - 20, _height - 20);
			_avatarPreviewArea = new Rectangle(10, 10, _width - 20, _height - 20);
			
			// Listen for close button interactions.
			_closeButton.addEventListener(MouseEvent.CLICK, onCloseClick);
			_closeButton.buttonMode = true;
			//_closeButton.useEmbededFonts = true;
			//_closeButton.textFormat = new TextFormat('EuroStyle', 12, 0xffffff);
			
			// Render view.
			render();
			
			// Add main visual components to display.
			addChild(_backing);
			addChild(_closeButton);
		}
		
		override public function destroy():void
		{
			super.destroy();
			
			// Remove all event listeners.
			_closeButton.removeEventListener(MouseEvent.CLICK, onCloseClick);
		}
		
		protected function updateRectangles():void
		{
			var top:Number = _closeButton.height + _margin;
			
			_navArea.x = _margin;
			_navArea.y = top;
			_navArea.width = (_width - (_margin * 4)) * 0.25;
			_navArea.height = _height - top - _margin;
			
			_itemListArea.x = _navArea.right + _margin;
			_itemListArea.y = top;
			_itemListArea.width = (_width - (_margin * 4)) * 0.5;
			_itemListArea.height = _height - top - _margin;
			
			_avatarPreviewArea.x = _itemListArea.right;
			_avatarPreviewArea.y = top + 30;
			_avatarPreviewArea.width = (_width - (_margin * 4)) * 0.25;
			_avatarPreviewArea.height = _height - top - _margin - 80;
		}
		
		public function goToBrowseView():void
		{
			_isHomeView = false;
			render();
		}
		
		public function goToHomeView():void
		{
			_isHomeView = true;
			render();
		}
		
		////////////////////
		// RENDER METHODS
		////////////////////
		
		override public function render():void
		{
			super.render();
			
			updateRectangles();
			
			renderBacking();
			
			// Position close button.
			_closeButton.x = _width - _closeButton.width - 10;
			_closeButton.y = _margin / 2;
			
			// Show/hide the home view.
			if (_homeView != null) _homeView.visible = _isHomeView;
			
			// Render item list view.
			renderItemListView();
			
			// Render nav view.
			renderNavView();
			
			// Render the avatar preview view.
			renderAvatarPreviewView();
		}
		
		protected function renderBacking():void
		{
			// Draw the backing.
			_backing.graphics.clear();
			_backing.graphics.beginFill(0x000000);
			_backing.graphics.drawRect(0, 0, _width, _height);
		}
		
		protected function renderItemListView():void
		{
			// Size and position the item list view.
			if (_itemListView == null) return;
			
			_itemListView.visible = !_isHomeView;
			
			_itemListView.width = _itemListArea.width;
			_itemListView.height = _itemListArea.height;
			_itemListView.x = _itemListArea.x;
			_itemListView.y = _itemListArea.y;
		}
		
		protected function renderNavView():void
		{
			// Size and position the nav view.
			
			if (_navView == null) return;
			
			_navView.width = _navArea.width;
			_navView.height = _navArea.height;
			_navView.x = _navArea.x;
			_navView.y = _navArea.y;
		}
		
		protected function renderAvatarPreviewView():void
		{
			// Size and position the nav view.
			
			if (_avatarPreviewView == null) return;
			
			_avatarPreviewView.visible = !_isHomeView;
			
			_avatarPreviewView.width = _avatarPreviewArea.width;
			_avatarPreviewView.height = _avatarPreviewArea.height;
			_avatarPreviewView.x = _avatarPreviewArea.x;
			_avatarPreviewView.y = _avatarPreviewArea.y;
		}
		
		protected function renderHomeView():void
		{
			// Size and position the home view.
			
			if (_homeView == null) return;
			
			_homeView.visible = _isHomeView;
			
			_homeView.x = _itemListArea.x;
			_homeView.y = _itemListArea.y;
		}
		
		public function hideShopKeeper():void
		{
			if (_shopKeeperHidden == true) return;
			_shopKeeperHidden = true;
			
			if (_shopKeeper != null)
			{
				_animationManager.move(_shopKeeper, _shopKeeper.x - _shopKeeper.width, _shopKeeper.y, 2000, Transitions.CUBIC_IN, RenderMethod.ENTER_FRAME);
			}
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		public function set navView(value:IStoreNavView):void
		{
			// Remove the current nav view.
			if (_navView != null)
			{
				removeChild(_navView.display);
				_navView.destroy();
			}
			
			// Set the new one.
			_navView = value;
			addChild(_navView.display);
			
			renderNavView();
		}
		
		public function set itemListView(value:IStoreItemListView):void
		{
			// Remove the current item list view.
			if (_itemListView != null)
			{
				removeChild(_itemListView.display);
				_itemListView.destroy();
			}
			
			// Set the new one.
			_itemListView = value;
			addChild(_itemListView.display);
			
			renderItemListView();
		}
		
		public function set avatarPreviewView(value:IStoreAvatarPreviewView):void
		{
			// Remove the current avatar preview view.
			if (_avatarPreviewView != null)
			{
				removeChild(_avatarPreviewView.display);
				_avatarPreviewView.destroy();
			}
			
			// Set the new one.
			_avatarPreviewView = value;
			addChild(_avatarPreviewView.display);
			
			renderAvatarPreviewView();
		}
		
		public function set homeView(value:IStoreHomeView):void
		{
			// Remove the current home view.
			if (_homeView != null)
			{
				removeChild(_homeView.display);
				_homeView.destroy();
			}
			
			// Set the new one.
			_homeView = value;
			addChild(_homeView.display);
			
			renderHomeView();
		}
		
		public function set toolTip(value:ToolTip):void
		{
			// Remove current tooltip.
			if (_toolTip != null)
			{
				removeChild(_toolTip);
			}
			
			// Set new one.
			_toolTip = value;
			_toolTip.mouseEnabled = false;
			_toolTip.filters = [new DropShadowFilter(4, 45, 0, 0.6, 12, 12)];
			addChild(_toolTip);
		}
		
		public function set background(value:DisplayObject):void
		{
			// Remove previous.
			if (_background != null)
			{
				removeChild(_background);
			}
			
			// Set new one.
			_background = value;
			_background.cacheAsBitmap = true;
			
			// Set alpha to 0 so we can fade it in.
			_background.alpha = 0;
			
			// Add just above the backing.
			var index:uint = getChildIndex(_backing);
			addChildAt(_background, index + 1);
			
			// Fade it in.
			// Fade alpha into 0.5 so it is transparent.
			_animationManager.alpha(_background, 0.5, 3000, Transitions.CUBIC_OUT, RenderMethod.ENTER_FRAME);
		}
		
		public function set shopKeeperDisplay(value:DisplayObject):void
		{
			// Remove previous.
			if (_shopKeeper != null)
			{
				removeChild(_shopKeeper);
			}
			
			// Set new one.
			_shopKeeper = value;
			addChild(_shopKeeper);
			
			// Position the shop keeper.
			_shopKeeper.y = 240;
		}
		
		////////////////////
		// EVENT HANDLERS
		////////////////////
		
		private function onCloseClick(e:MouseEvent):void
		{
			dispatchEvent(new StoreEvent(StoreEvent.CLOSE_CLICK));
		}
		
	}
}