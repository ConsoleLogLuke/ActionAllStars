package com.sdg.store
{
	import com.adobe.cairngorm.control.CairngormEventDispatcher;
	import com.sdg.events.StoreCategoriesEvent;
	import com.sdg.events.StoreItemsEvent;
	import com.sdg.model.Avatar;
	import com.sdg.model.ModelLocator;
	import com.sdg.model.Store;
	import com.sdg.model.StoreCategory;
	import com.sdg.model.StoreItem;
	import com.sdg.model.StoreItemCollection;
	import com.sdg.net.RemoteSoundBank;
	import com.sdg.store.home.IStoreHomeView;
	import com.sdg.store.home.StoreHomeView;
	import com.sdg.store.list.IStoreItemListModel;
	import com.sdg.store.list.StoreItemListController;
	import com.sdg.store.list.StoreItemListModel;
	import com.sdg.store.list.StoreItemListView;
	import com.sdg.store.nav.IStoreNavModel;
	import com.sdg.store.nav.StoreNavController;
	import com.sdg.store.nav.StoreNavModel;
	import com.sdg.store.nav.StoreNavView;
	import com.sdg.store.preview.IStoreAvatarPreviewModel;
	import com.sdg.store.preview.StoreAvatarPreviewController;
	import com.sdg.store.preview.StoreAvatarPreviewModel;
	import com.sdg.store.preview.StoreAvatarPreviewView;
	import com.sdg.store.skin.FaceliftStoreSkin;
	import com.sdg.store.skin.IStoreSkin;
	import com.sdg.store.util.StoreUtil;
	
	import flash.events.EventDispatcher;
	import flash.text.TextFormat;
	
	public class StoreModel extends EventDispatcher implements IStoreModel
	{
		public static const ITEM_LIST_MODEL_CLASS:Class = StoreItemListModel;
		public static const ITEM_LIST_VIEW_CLASS:Class = StoreItemListView;
		public static const ITEM_LIST_CONTROLLER_CLASS:Class = StoreItemListController;
		public static const NAV_MODEL_CLASS:Class = StoreNavModel;
		public static const NAV_VIEW_CLASS:Class = StoreNavView;
		public static const NAV_CONTROLLER_CLASS:Class = StoreNavController;
		public static const AVATAR_PREVIEW_MODEL_CLASS:Class = StoreAvatarPreviewModel;
		public static const AVATAR_PREVIEW_VIEW_CLASS:Class = StoreAvatarPreviewView;
		public static const AVATAR_PREVIEW_CONTROLLER_CLASS:Class = StoreAvatarPreviewController;
		public static const DEFAULT_SKIN:Class = FaceliftStoreSkin;

		public var HOME_VIEW_CLASS:Class = StoreHomeView;
		public var STORE_CONTROLLER:Class = StoreController;
		
		protected const DEFAULT_WIDTH:Number = 925;
		protected const DEFAULT_HEIGHT:Number = 665;
		
		protected var _view:IStoreView;
		protected var _controller:IStoreController;
		
		protected var _itemListModel:IStoreItemListModel;
		protected var _navModel:IStoreNavModel;
		protected var _avatarPreviewModel:IStoreAvatarPreviewModel;
		
		protected var _items:StoreItemCollection;
		protected var _skin:IStoreSkin;
		protected var _toolTip:ToolTip;
		protected var _storeId:uint;
		protected var _categoryId:uint;
		protected var _remoteSoundBank:RemoteSoundBank;
		protected var _homeView:IStoreHomeView;
		
		public function StoreModel(storeId:uint)
		{
			_storeId = storeId;		
		}
		
		public function init():void
		{
			// Instantiate view and controller.
			_view = new StoreView();
			_controller = new STORE_CONTROLLER();
			
			// Instantiate and initialize item list model.
			_itemListModel = new ITEM_LIST_MODEL_CLASS();
			_itemListModel.init(new ITEM_LIST_VIEW_CLASS(), new ITEM_LIST_CONTROLLER_CLASS());
			
			// Instantiate and initialize item nav model.
			_navModel = new NAV_MODEL_CLASS();
			_navModel.init(new NAV_VIEW_CLASS(), new NAV_CONTROLLER_CLASS());
			
			// Instantiate and initialize item avatar preview model.
			_avatarPreviewModel = new AVATAR_PREVIEW_MODEL_CLASS();
			_avatarPreviewModel.init(new AVATAR_PREVIEW_VIEW_CLASS(), new AVATAR_PREVIEW_CONTROLLER_CLASS());
			
			// Pass StoreId to child navModel
			_navModel.storeId = _storeId;
			
			// Create the home view.
			_homeView = new HOME_VIEW_CLASS();
			_homeView.url = StoreUtil.GetStoreHomeViewUrl(_storeId);
			
			// Create remote sound bank.
			_remoteSoundBank = new RemoteSoundBank();
			
			// Create tool tip.
			_toolTip = new ToolTip();
			_toolTip.textFormat = new TextFormat('EuroStyle', 12, 0xffffff);
			_toolTip.useEmbededFonts = true;
			_toolTip.visible = false;
			
			// Apply default skin.
			_skin = new DEFAULT_SKIN();
			
			// Initialize the controller.
			_controller.init(this);
		}
		
		public function getAllStores():Object
		{
			return ModelLocator.getInstance().stores;
		}
		
		public function getAllStoreCategories(storeId:uint):Object
		{
			return ModelLocator.getInstance().stores[storeId] as StoreCategory;
		}
		
		public function getAllCategoryItems(storeId:uint, categoryId:uint):Object
		{
			var store:Store = ModelLocator.getInstance().stores[storeId] as Store;
			if (store == null) return null;
			var category:StoreCategory = store.getCategoryById(categoryId);
			if (category == null) return null;
			return category.items;
		}
		
		public function updateInventory():void
		{
			// Hard code store id.
			var storeId:uint = _storeId;
			var categoryId:uint;
			
			// Make sure there is an instance of store for this id.
			var store:Store = ModelLocator.getInstance().stores[storeId] as Store;
			if (store == null)
			{
				store = new Store('Action AllStars Store', storeId);
				ModelLocator.getInstance().stores[storeId] = store;
			}
			
			// Test items.
			CairngormEventDispatcher.getInstance().addEventListener(StoreCategoriesEvent.COMPLETE, onCategoriesComplete);
			CairngormEventDispatcher.getInstance().dispatchEvent(new StoreCategoriesEvent(-1, storeId));
			
			function onCategoriesComplete(e:StoreCategoriesEvent):void
			{
				// Remove listener.
				CairngormEventDispatcher.getInstance().removeEventListener(StoreCategoriesEvent.COMPLETE, onCategoriesComplete);
				
				// Pass the store to the nav model.
				navModel.store = store;
			}
			
			function onItemsComplete(e:StoreItemsEvent):void
			{
				// Remove event listeners.
				CairngormEventDispatcher.getInstance().removeEventListener(StoreItemsEvent.COMPLETE, onItemsComplete);
				
				// Get a reference to the category.
				var category:StoreCategory = store.getCategoryById(categoryId);
				
				// Create a store item collection.
				var i:uint = 0;
				var len:uint = category.items.length;
				var itemCollection:StoreItemCollection = new StoreItemCollection();
				for (i; i < len; i++)
				{
					var item:StoreItem = category.items.getItemAt(i) as StoreItem;
					if (item != null) itemCollection.push(item);
				}
				
				items = itemCollection;
			}
		}
		
		public function selectCategory(categoryId:uint):void
		{
			// Make sure this category is not already selected.
			if (categoryId == _categoryId) return;
			
			// Get store id.
			var storeId:uint = _storeId;
			
			// Make sure there is an instance of store for this id.
			var store:Store = ModelLocator.getInstance().stores[storeId] as Store;
			if (store == null)
			{
				store = new Store('Action AllStars Store', storeId);
				ModelLocator.getInstance().stores[storeId] = store;
			}
			
			// Get a reference to the current category.
			var currentCategory:StoreCategory = store.getCategoryById(_categoryId);
			
			// Get a reference to the category.
			var category:StoreCategory = store.getCategoryById(categoryId);
			if (category == null) return;
			
			// Make sure that the category we are trying to select is not a parent of the current category.
			if (currentCategory != null && category.childCategories.contains(currentCategory) == true) return;
			
			// Set category id.
			_categoryId = categoryId;
			
			// Update item set name.
			itemListModel.itemSetName = category.name;
			
			// Set item set image url.
			itemListModel.itemSetImageUrl = StoreUtil.GetCategoryThumbnailUrl(categoryId);
			
			// If this category has sub-categories, load those.
			// Otherwise load items.
			if (category.subCategoryCount > 0)
			{
				// Make sure the sub categories have not already been loaded.
				if (category.childCategories.length < category.subCategoryCount)
				{
					// Query for sub-categories.
					CairngormEventDispatcher.getInstance().addEventListener(StoreCategoriesEvent.COMPLETE, onCategoriesComplete);
					CairngormEventDispatcher.getInstance().dispatchEvent(new StoreCategoriesEvent(categoryId));
				}
				else
				{
					// Assume they have already been loaded.
					// Pass the store.
					navModel.store = store;
					
					// Select the first sub-category.
					var firstSubCategory:StoreCategory = category.childCategories.getItemAt(0) as StoreCategory;
					if (firstSubCategory != null) selectCategory(firstSubCategory.id);
				}
			}
			else if (category.items.length < 1)
			{
				// Query for items.
				CairngormEventDispatcher.getInstance().addEventListener(StoreItemsEvent.COMPLETE, onItemsComplete);
				CairngormEventDispatcher.getInstance().dispatchEvent(new StoreItemsEvent(storeId, categoryId, avatar.id));
			}
			else
			{
				// Pass items.
				passItems();
			}
			
			function passItems():void
			{
				// Create a store item collection.
				var i:uint = 0;
				var len:uint = category.items.length;
				var itemCollection:StoreItemCollection = new StoreItemCollection();
				for (i; i < len; i++)
				{
					var item:StoreItem = category.items.getItemAt(i) as StoreItem;
					if (item != null) itemCollection.push(item);
				}
				
				// ONLY PURPOSE OF THIS LINE IS TO CAUSE A NAV REFRESH
				navModel.store = store;
				
				items = itemCollection;
			}
			
			function onItemsComplete(e:StoreItemsEvent):void
			{
				// Remove event listeners.
				CairngormEventDispatcher.getInstance().removeEventListener(StoreItemsEvent.COMPLETE, onItemsComplete);
				
				// Pass items.
				passItems();
				
				// Pass the store.
				navModel.store = store;
			}
			
			function onCategoriesComplete(e:StoreCategoriesEvent):void
			{
				// Remove listener.
				CairngormEventDispatcher.getInstance().removeEventListener(StoreCategoriesEvent.COMPLETE, onCategoriesComplete);
				
				// Pass the store to the nav model.
				navModel.store = store;
				
				// Select the first sub-category.
				var firstSubCategory:StoreCategory = category.childCategories.getItemAt(0) as StoreCategory;
				if (firstSubCategory != null) selectCategory(firstSubCategory.id);
			}
		}
		
		protected function updateStoreCategories():void
		{
			var storeId:uint = _storeId;
			
			CairngormEventDispatcher.getInstance().addEventListener(StoreCategoriesEvent.COMPLETE, onCategoriesComplete);
			CairngormEventDispatcher.getInstance().dispatchEvent(new StoreCategoriesEvent(-1, storeId));
			
			function onCategoriesComplete(e:StoreCategoriesEvent):void
			{
				// Remove listener.
				CairngormEventDispatcher.getInstance().removeEventListener(StoreCategoriesEvent.COMPLETE, onCategoriesComplete);
			}
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////

		public function get view():IStoreView
		{
			return _view;
		}
		
		public function get controller():IStoreController
		{
			return _controller;
		}
		
		public function get itemListModel():IStoreItemListModel
		{
			return _itemListModel;
		}
		
		public function get navModel():IStoreNavModel
		{
			return _navModel;
		}
		
		public function get avatarPreviewModel():IStoreAvatarPreviewModel
		{
			return _avatarPreviewModel;
		}
		
		public function get defaultWidth():Number
		{
			return DEFAULT_WIDTH;
		}
		
		public function get defaultHeight():Number
		{
			return DEFAULT_HEIGHT;
		}
		
		public function get avatar():Avatar
		{
			return ModelLocator.getInstance().avatar;
		}
		
		public function get items():StoreItemCollection
		{
			return _items;
		}
		public function set items(value:StoreItemCollection):void
		{
			_items = value;
			
			// When the items change, reset the avatar preview clothing.
			_avatarPreviewModel.resetClothing();
			
			dispatchEvent(new StoreEvent(StoreEvent.ITEMS_UPDATE));
		}
		
		public function get skin():IStoreSkin
		{
			return _skin;
		}
		
		public function get toolTip():ToolTip
		{
			return _toolTip;
		}
		
		public function get remoteSoundBank():RemoteSoundBank
		{
			return _remoteSoundBank;
		}
		
		public function get coinSoundUrl():String
		{
			return StoreUtil.GetAssetPath() + 'register_open_01.mp3';
		}
		
		public function get storeId():uint
		{
			return _storeId;
		}
		
		public function get homeView():IStoreHomeView
		{
			return _homeView;
		}
		
		public function get categoryId():uint
		{
			return _categoryId;
		}
		
		public function set categoryId(value:uint):void
		{
			_categoryId = value;
		}
		
		public function get backgroundUrl():String
		{
			return StoreUtil.GetStoreBackgroundUrl(_storeId);
		}
		
		public function get shopKeeperUrl():String
		{
			return StoreUtil.GetShopKeeperUrl(_storeId);
		}
		
	}
}