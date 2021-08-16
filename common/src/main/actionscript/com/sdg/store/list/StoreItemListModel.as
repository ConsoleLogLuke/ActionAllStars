package com.sdg.store.list
{
	import com.sdg.model.StoreItem;
	import com.sdg.model.StoreItemCollection;
	import com.sdg.store.StoreEvent;
	import com.sdg.store.item.StoreItemEvent;
	
	import flash.events.EventDispatcher;

	public class StoreItemListModel extends EventDispatcher implements IStoreItemListModel
	{
		protected const DEFAULT_WIDTH:Number = 200;
		protected const DEFAULT_HEIGHT:Number = 200;
		
		protected var _view:IStoreItemListView;
		protected var _controller:IStoreItemListController;
		
		protected var _items:StoreItemCollection;
		protected var _backgroundUrl:String;
		protected var _windowBackgroundUrl:String;
		protected var _itemSetName:String;
		protected var _userLevel:uint;
		protected var _userSubLevel:uint;
		protected var _itemSetImageUrl:String;
		protected var _userTokens:int;
		
		public function StoreItemListModel()
		{
			super();
		}
		
		public function init(view:IStoreItemListView, controller:IStoreItemListController):void
		{
			// Set reference to view and controller.
			_view = view;
			_controller = controller;
			
			// Defaults.
			_userLevel = 0;
			_userSubLevel = 0;
			_userTokens = 0;
			
			// Initialize the controller.
			_controller.init(this);
		}
		
		public function updateItemQuantity(storeItem:StoreItem):void
		{
			// Grab the item from the item list and update the quantity.
			dispatchEvent(new StoreItemEvent(StoreItemEvent.QUANTITY_UPDATE, storeItem));
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		public function get itemCollection():StoreItemCollection
		{
			return _items;
		}
		public function set itemCollection(value:StoreItemCollection):void
		{
			if (value == _items) return;
			_items = value;
			dispatchEvent(new StoreEvent(StoreEvent.ITEMS_UPDATE));
		}
		
		public function get view():IStoreItemListView
		{
			return _view;
		}
		
		public function get controller():IStoreItemListController
		{
			return _controller;
		}
		
		public function get defaultWidth():Number
		{
			return DEFAULT_WIDTH;
		}
		
		public function get defaultHeight():Number
		{
			return DEFAULT_HEIGHT;
		}
		
		public function get backgroundUrl():String
		{
			return _backgroundUrl;
		}
		public function set backgroundUrl(value:String):void
		{
			if (value == _backgroundUrl) return;
			_backgroundUrl = value;
			dispatchEvent(new StoreItemListEvent(StoreItemListEvent.NEW_BACKGROUND_URL));
		}
		
		public function get windowBackgroundUrl():String
		{
			return _windowBackgroundUrl;
		}
		public function set windowBackgroundUrl(value:String):void
		{
			if (value == _windowBackgroundUrl) return;
			_windowBackgroundUrl = value;
			dispatchEvent(new StoreItemListEvent(StoreItemListEvent.NEW_WINDOW_BACKGROUND_URL));
		}
		
		public function get itemSetName():String
		{
			return _itemSetName;
		}
		public function set itemSetName(value:String):void
		{
			if (value == _itemSetName) return;
			_itemSetName = value;
			dispatchEvent(new StoreItemListEvent(StoreItemListEvent.NEW_ITEM_SET_NAME));
		}
		
		public function get userLevel():uint
		{
			return _userLevel;
		}
		public function set userLevel(value:uint):void
		{
			_userLevel = value;
		}
		
		public function get userSubLevel():uint
		{
			return _userSubLevel;
		}
		public function set userSubLevel(value:uint):void
		{
			if (value == _userSubLevel) return;
			_userSubLevel = value;
			dispatchEvent(new StoreItemListEvent(StoreItemListEvent.UPDATED_USER_LEVEL));
		}
		
		public function get itemSetImageUrl():String
		{
			return _itemSetImageUrl;
		}
		public function set itemSetImageUrl(value:String):void
		{
			if (value == _itemSetImageUrl) return;
			_itemSetImageUrl = value;
			dispatchEvent(new StoreItemListEvent(StoreItemListEvent.NEW_ITEM_SET_IMAGE_URL));
		}
		
		public function get userTokens():int
		{
			return _userTokens;
		}
		public function set userTokens(value:int):void
		{
			if (value == _userTokens) return;
			_userTokens = value;
			dispatchEvent(new StoreItemListEvent(StoreItemListEvent.UPDATED_USER_TOKENS));
		}
		
	}
}