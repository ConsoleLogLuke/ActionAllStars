package com.sdg.store.list
{
	import com.sdg.events.LoaderQueEvent;
	import com.sdg.model.StoreItem;
	import com.sdg.model.StoreItemCollection;
	import com.sdg.net.LoaderQue;
	import com.sdg.store.StoreEvent;
	import com.sdg.store.catalog.BestSellerItemView;
	import com.sdg.store.item.IStoreItemView;
	import com.sdg.store.item.StoreItemDetailView;
	import com.sdg.store.item.StoreItemEvent;
	import com.sdg.store.item.StoreItemView;
	import com.sdg.store.item.StoreItemViewCollection;
	import com.sdg.store.item.StoreItemViewEvent;
	import com.sdg.store.util.StoreUtil;
	import com.sdg.utils.ItemUtil;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.filters.DropShadowFilter;
	import flash.net.URLRequest;

	public class StoreItemListController extends EventDispatcher implements IStoreItemListController
	{
		protected var _model:IStoreItemListModel;
		
		protected var _itemViews:StoreItemViewCollection;
		protected var _thumbnailLoaderQue:LoaderQue;
		protected var _itemSortType:String;
		
		public function StoreItemListController(target:IEventDispatcher=null)
		{
			super(target);
			new BestSellerItemView();
		}
		
		public function init(model:IStoreItemListModel):void
		{
			// Set reference to model.
			_model = model;
			
			// Initialize the view.
			_model.view.init(_model.defaultWidth, _model.defaultHeight);
			
			// Create default objects.
			_itemViews = new StoreItemViewCollection();
			
			// Create a thumbnail loader que.
			// Used for loading all item thumbnails.
			_thumbnailLoaderQue = new LoaderQue(4, 3000, 2, true);
			
			// Listen to model for events.
			_model.addEventListener(StoreEvent.ITEMS_UPDATE, onItemsUpdate);
			_model.addEventListener(StoreItemEvent.QUANTITY_UPDATE, onItemQuantityUpdate);
			_model.addEventListener(StoreItemListEvent.NEW_BACKGROUND_URL, onNewBackgroundUrl);
			_model.addEventListener(StoreItemListEvent.NEW_WINDOW_BACKGROUND_URL, onNewWindowBackgroundUrl);
			_model.addEventListener(StoreItemListEvent.NEW_ITEM_SET_NAME, onNewItemSetName);
			_model.addEventListener(StoreItemListEvent.NEW_ITEM_SET_IMAGE_URL, onNewItemSetImageUrl);
			_model.addEventListener(StoreItemListEvent.UPDATED_USER_TOKENS, onUpdatedUserTokens);
			_model.addEventListener(StoreItemListEvent.UPDATED_USER_LEVEL, onUpdatedUserLevel);
			
			// Listen to view for events.
			_model.view.addEventListener(StoreItemListSortEvent.SORT_SELECT, onSortSelect);
		}
		
		public function destroy():void
		{
			// Remove event listeners.
			_model.removeEventListener(StoreEvent.ITEMS_UPDATE, onItemsUpdate);
			_model.removeEventListener(StoreItemEvent.QUANTITY_UPDATE, onItemQuantityUpdate);
			_model.removeEventListener(StoreItemListEvent.NEW_BACKGROUND_URL, onNewBackgroundUrl);
			_model.removeEventListener(StoreItemListEvent.NEW_WINDOW_BACKGROUND_URL, onNewWindowBackgroundUrl);
			_model.removeEventListener(StoreItemListEvent.NEW_ITEM_SET_NAME, onNewItemSetName);
			_model.removeEventListener(StoreItemListEvent.NEW_ITEM_SET_IMAGE_URL, onNewItemSetImageUrl);
			_model.view.removeEventListener(StoreItemListSortEvent.SORT_SELECT, onSortSelect);
			_model.removeEventListener(StoreItemListEvent.UPDATED_USER_TOKENS, onUpdatedUserTokens);
			_model.removeEventListener(StoreItemListEvent.UPDATED_USER_LEVEL, onUpdatedUserLevel);
			
			// Clear the thumbnail loader que.
			_thumbnailLoaderQue.stop();
			_thumbnailLoaderQue.clear();
			
			// Destroy view.
			_model.view.destroy();
		}
		
		////////////////////
		// PRIVATE METHODS
		////////////////////
		
		private function defaultCompare(a:IStoreItemView, b:IStoreItemView):int
		{
			if (a.listOrderId < b.listOrderId)
			{
				return -1;
			}
			else if (a.listOrderId > b.listOrderId)
			{
				return 1;
			}
			else
			{
				return idCompare(a, b);
			}
		}
		
		private function priceCompare(a:IStoreItemView, b:IStoreItemView):int
		{
			if (a.numTokens > b.numTokens)
			{
				return -1;
			}
			else if (a.numTokens < b.numTokens)
			{
				return 1;
			}
			else
			{
				return defaultCompare(a, b);
			}
		}
		
		private function levelCompare(a:IStoreItemView, b:IStoreItemView):int
		{
			if (a.levelRequirement > b.levelRequirement)
			{
				return -1;
			}
			else if (a.levelRequirement < b.levelRequirement)
			{
				return 1;
			}
			else
			{
				return defaultCompare(a, b);
			}
		}
		
		private function typeCompare(a:IStoreItemView, b:IStoreItemView):int
		{
			if (a.itemTypeId > b.itemTypeId)
			{
				return -1;
			}
			else if (a.itemTypeId < b.itemTypeId)
			{
				return 1;
			}
			else
			{
				return defaultCompare(a, b);
			}
		}
		
		private function idCompare(a:IStoreItemView, b:IStoreItemView):int
		{
			if (a.itemId < b.itemId)
			{
				return -1;
			}
			else if (a.itemId > b.itemId)
			{
				return 1;
			}
			else
			{
				return 0;
			}
		}
		
		////////////////////
		// EVENT HANDLERS
		////////////////////
		
		private function onItemsUpdate(e:StoreEvent):void
		{
			// Get a reference to the items.
			var items:StoreItemCollection = _model.itemCollection;
			
			// Perform cleanup on current item displays.
			var i:uint = 0;
			var len:uint = _itemViews.length
			for (i; i < len; i++)
			{
				var itemDisplay:IStoreItemView = _itemViews.getAt(i);
				itemDisplay.removeEventListener(StoreItemViewEvent.THUMBNAIL_CLICK, onThumbnailClick);
				itemDisplay.removeEventListener(StoreItemViewEvent.THUMBNAIL_OVER, onThumbnailOver);
				itemDisplay.removeEventListener(StoreItemViewEvent.THUMBNAIL_OUT, onThumbnailOut);
				itemDisplay.removeEventListener(StoreItemViewEvent.MAGNIFY_CLICK, onMognifyClick);
				itemDisplay.removeEventListener(StoreItemViewEvent.BUY_CLICK, onBuyClick);
				itemDisplay.destroy();
			}
			
			// Remove current item views.
			_itemViews.empty();
			
			// Make sure if there are any thumbnails being loaded from the previous item set,
			// That they are stopped.
			_thumbnailLoaderQue.stop();
			_thumbnailLoaderQue.clear();
			// Start it up again for the new requests that are about to be added.
			_thumbnailLoaderQue.start();
			
			// Reset sort type.
			_itemSortType = '';
			
			// Listen for events on the thumbnail loader que.
			_thumbnailLoaderQue.addEventListener(LoaderQueEvent.COMPLETE, onThumbnailLoadComplete);
			_thumbnailLoaderQue.addEventListener(LoaderQueEvent.ERROR, onThumbnailLoadError);
			
			// Create display objects to pass to the item list view.
			i = 0;
			len = items.length;
			_itemViews = new StoreItemViewCollection();
			var itemDisplays:Array = [];
			for (i; i < len; i++)
			{
				var item:StoreItem = items.getAt(i);
				
				// Create a loading indicator as a placeholder for the item thumbnail.
				var display:Sprite = new Sprite();
				display.graphics.beginFill(0xffffff, 0);
				display.graphics.drawRect(0, 0, 80, 80);
				var loadIndicator:DisplayObject = new SpinningLoadingIndicator();
				loadIndicator.x = display.width / 2 - loadIndicator.width / 2;
				loadIndicator.y = display.height / 2 - loadIndicator.height / 2;
				display.addChild(loadIndicator);
				
				var storeItemDisplay:IStoreItemView = new StoreItemView();
				storeItemDisplay.init(100, 150);
				storeItemDisplay.itemId = item.id;
				storeItemDisplay.thumbnail = display;
				storeItemDisplay.itemName = item.name;
				storeItemDisplay.numTokens = item.price;
				storeItemDisplay.levelRequirement = item.levelRequirement;
				storeItemDisplay.isLocked = (_model.userSubLevel < item.levelRequirement) ? true : false;
				storeItemDisplay.itemTypeId = item.itemTypeId;
				storeItemDisplay.isAffordable = (_model.userTokens >= item.price);
				Sprite(storeItemDisplay.display).buttonMode = true;
				storeItemDisplay.purchasedAmount = item.qtyOwned;
				storeItemDisplay.listOrderId = i;
				storeItemDisplay.addEventListener(StoreItemViewEvent.THUMBNAIL_CLICK, onThumbnailClick);
				storeItemDisplay.addEventListener(StoreItemViewEvent.THUMBNAIL_OVER, onThumbnailOver);
				storeItemDisplay.addEventListener(StoreItemViewEvent.THUMBNAIL_OUT, onThumbnailOut);
				storeItemDisplay.addEventListener(StoreItemViewEvent.MAGNIFY_CLICK, onMognifyClick);
				storeItemDisplay.addEventListener(StoreItemViewEvent.BUY_CLICK, onBuyClick);
				
				_itemViews.push(storeItemDisplay);
				
				// Load the item preview.
				var url:String = ItemUtil.GetSmallThumbnailUrl(item.id);
				var request:URLRequest = new URLRequest(url);
				itemDisplays[url] = storeItemDisplay;
				_thumbnailLoaderQue.addRequest(request);
			}
			
			// Pass views.
			_model.view.itemViews = _itemViews;
			
			// Default sorting by type.
			_model.view.sortType = StoreItemListSort.DEFAULT;
			
			function onThumbnailLoadComplete(e:LoaderQueEvent):void
			{
				// Get a reference to the loader.
				var loader:Loader = e.loader;
				
				// Get a reference to the loaded url.
				var url:String = loader.contentLoaderInfo.url;
				
				// Get a reference to the item display.
				var itemDisplay:StoreItemView = itemDisplays[url] as StoreItemView;
				if (itemDisplay == null) return;
				
				// Create a bitmap copy of the loaded content.
				// Use bitmap smoothing.
				// Set the thumbnail as the bitmap copy.
				var content:DisplayObject = loader.content;
				var bitmapData:BitmapData = new BitmapData(content.width, content.height, true, 0xffffff);
				bitmapData.draw(content);
				var bitmap:Bitmap = new Bitmap(bitmapData, 'auto', true);
				
				// Set the thumbnail as the loaded content.
				itemDisplay.thumbnail = bitmap;
			}
			
			function onThumbnailLoadError(e:LoaderQueEvent):void
			{
				// Get a reference to the loader.
				var loader:Loader = e.loader;
				
				// Get a reference to the loaded url.
				var url:String = loader.contentLoaderInfo.url;
			}
			
			function onThumbnailClick(e:StoreItemViewEvent):void
			{
				// Get reference to the store item view.
				var storeItemDisplay:IStoreItemView = e.currentTarget as IStoreItemView;
				if (storeItemDisplay == null) return;
				
				// Get a reference to the store item.
				var item:StoreItem = getItem(storeItemDisplay);
				if (item == null) return;
				
				// Show the detail view.
				showDetailView(item);
				
				// Dispatch a store item event.
				var event:StoreItemEvent = new StoreItemEvent(StoreItemEvent.SELECT, item);
				dispatchEvent(event);
			}
			
			function onThumbnailOver(e:StoreItemViewEvent):void
			{
				// Get reference to the store item view.
				var storeItemDisplay:IStoreItemView = e.currentTarget as IStoreItemView;
				if (storeItemDisplay == null) return;
				
				// Get a reference to the store item.
				var item:StoreItem = getItem(storeItemDisplay);
				if (item == null) return;
				
				// Dispatch a store item event.
				var event:StoreItemEvent = new StoreItemEvent(StoreItemEvent.ROLL_OVER, item);
				dispatchEvent(event);
			}
			
			function onThumbnailOut(e:StoreItemViewEvent):void
			{
				// Get reference to the store item view.
				var storeItemDisplay:IStoreItemView = e.currentTarget as IStoreItemView;
				if (storeItemDisplay == null) return;
				
				// Get a reference to the store item.
				var item:StoreItem = getItem(storeItemDisplay);
				if (item == null) return;
				
				// Dispatch a store item event.
				var event:StoreItemEvent = new StoreItemEvent(StoreItemEvent.ROLL_OUT, item);
				dispatchEvent(event);
			}
			
			function onMognifyClick(e:StoreItemViewEvent):void
			{
				// Show the expanded view for the item.
				
				// Get a reference to the store item view.
				var storeItemDisplay:IStoreItemView = e.currentTarget as IStoreItemView;
				if (storeItemDisplay == null) return;
				
				// Get a reference to the store item.
				var item:StoreItem = getItem(storeItemDisplay);
				if (item == null) return;
				
				// Show the detail view.
				showDetailView(item);
			}
			
			function onBuyClick(e:StoreItemViewEvent):void
			{
				// Get a reference to the store item view.
				var storeItemDisplay:IStoreItemView = e.currentTarget as IStoreItemView;
				if (storeItemDisplay == null) return;
				
				// Get a reference to the store item.
				var item:StoreItem = getItem(storeItemDisplay);
				if (item == null) return;
				
				// Dispatch a buy event.
				dispatchEvent(new StoreItemEvent(StoreItemEvent.BUY, item));
			}
			
			function getItem(itemView:IStoreItemView):StoreItem
			{
				var itemId:uint = itemView.itemId;
				var item:StoreItem = _model.itemCollection.getFromId(itemId);
				return item;
			}
			
			function showDetailView(item:StoreItem):void
			{
				// Create a loading indicator as a placeholder for the item thumbnail.
				var defaultThumb:Sprite = new Sprite();
				defaultThumb.graphics.beginFill(0xffffff, 0);
				defaultThumb.graphics.drawRect(0, 0, 160, 160);
				var loadIndicator:DisplayObject = new SpinningLoadingIndicator();
				loadIndicator.x = defaultThumb.width / 2 - loadIndicator.width / 2;
				loadIndicator.y = defaultThumb.height / 2 - loadIndicator.height / 2;
				defaultThumb.addChild(loadIndicator);
				
				// Detail view.
				var view:IStoreItemView = new StoreItemDetailView();
				view.init(_model.view.width, _model.view.height);
				view.itemName = item.name;
				view.levelRequirement = item.levelRequirement;
				view.numTokens = item.price;
				view.homeTurfValue = item.homeTurfValue;
				view.isLocked = (_model.userSubLevel < item.levelRequirement) ? true : false;
				view.thumbnail = defaultThumb;
				StoreItemDetailView(view).itemDescription = item.description;
				view.display.filters = [new DropShadowFilter(4, 45, 0, 0.5, 8, 8)];
				view.addEventListener(StoreItemViewEvent.BUY_CLICK, onBuyClick);
				
				// Listen for detail view to be removed.
				_model.view.addEventListener(StoreItemListEvent.REMOVED_DETAIL_VIEW, onDetailViewRemoved);
				
				_model.view.showDetailView(view);
				
				// Load category icon
				var categoryLoader:Loader = new Loader();
				categoryLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onCategoryComplete);
				categoryLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onCategoryError);
				categoryLoader.load(new URLRequest(StoreUtil.GetCategoryThumbnailUrl(item.parentCategory.id)));
				
				// Load large item thumbnail.
				var url:String = ItemUtil.GetLargeThumbnailUrl(item.id);
				var request:URLRequest = new URLRequest(url);
				var loader:Loader = new Loader();
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
				loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
				loader.load(request);
				
				function onCategoryComplete(e:Event):void
				{
					categoryLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onCategoryComplete);
					categoryLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onCategoryError);
					
					var content:DisplayObject = categoryLoader.content;
					StoreItemDetailView(view).categoryIcon = content;
				}
				
				function onCategoryError(e:IOErrorEvent):void
				{
					categoryLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onCategoryComplete);
					categoryLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onCategoryError);
				}
				
				function onComplete(e:Event):void
				{
					// Remove event listeners.
					loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onComplete);
					loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onError);
					
					// Create a bitmap copy of the loaded content.
					// Use bitmap smoothing.
					// Set the thumbnail as the bitmap copy.
					var content:DisplayObject = loader.content;
					var bitmapData:BitmapData = new BitmapData(content.width, content.height, true, 0xffffff);
					bitmapData.draw(content);
					var bitmap:Bitmap = new Bitmap(bitmapData, 'auto', true);
					
					// Pass in image to detail view.
					view.thumbnail = bitmap;
				}
				
				function onError(e:IOErrorEvent):void
				{
					// Remove event listeners.
					loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onComplete);
					loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onError);
				}
				
				function onBuyClick(e:StoreItemViewEvent):void
				{
					// Dispatch a buy event.
					dispatchEvent(new StoreItemEvent(StoreItemEvent.BUY, item));
				}
				
				function onDetailViewRemoved(e:Event):void
				{
					dispatchEvent(new StoreItemEvent(StoreItemEvent.DESELECT, item));
				}
			}
		}
		
		private function onNewBackgroundUrl(e:StoreItemListEvent):void
		{
			// Load the new background.
			var url:String = _model.backgroundUrl;
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
				_model.view.background = loader.content;
			}
			
			function onLoadError(e:IOErrorEvent):void
			{
				// Remove event listeners.
				loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoadComplete);
				loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
			}
		}
		
		private function onNewWindowBackgroundUrl(e:StoreItemListEvent):void
		{
			// Load the new background.
			var url:String = _model.windowBackgroundUrl;
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
				_model.view.windowBackground = loader.content;
			}
			
			function onLoadError(e:IOErrorEvent):void
			{
				// Remove event listeners.
				loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoadComplete);
				loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
			}
		}
		
		private function onNewItemSetName(e:StoreItemListEvent):void
		{
			// Pass the name to the view.
			_model.view.itemSetName = _model.itemSetName;
		}
		
		private function onNewItemSetImageUrl(e:StoreItemListEvent):void
		{
			// Load the image and pass it to the view.
			var url:String = _model.itemSetImageUrl;
			var request:URLRequest = new URLRequest(url);
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
			loader.load(request);
			
			function onComplete(e:Event):void
			{
				// Remove event listeners.
				loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onComplete);
				loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onError);
				
				// Pass image to view.
				_model.view.itemSetImage = loader.content;
			}
			
			function onError(e:IOErrorEvent):void
			{
				// Remove event listeners.
				loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onComplete);
				loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onError);
			}
		}
		
		private function onSortSelect(e:StoreItemListSortEvent):void
		{
			// Determine the type of sort that was selected and handle it.
			// Take the current item views,
			// Re-order them,
			// Pass them to the view.
			
			// Get reference to item views.
			var itemViews:StoreItemViewCollection = _itemViews;
			
			// Get sort type.
			var sortType:String = e.sortName;
			
			// Determine which type of sorting to apply.
			switch (sortType)
			{
				case _itemSortType :
					itemViews.reverse();
					break;
				case StoreItemListSort.DEFAULT :
					itemViews.sort(defaultCompare);
					break;
				case StoreItemListSort.PRICE :
					itemViews.sort(priceCompare);
					break;
				case StoreItemListSort.LEVEL :
					itemViews.sort(levelCompare);
					break;
				case StoreItemListSort.ITEM_TYPE :
					itemViews.sort(typeCompare);
					break
			}
			
			// Set new value.
			_itemSortType = sortType;
			
			// Pass the item views back to the view.
			_model.view.itemViews = itemViews;
			
		}
		
		private function onItemQuantityUpdate(e:StoreItemEvent):void
		{
			// Update quantity on item view.
			// Get reference to store item.
			var storeItem:StoreItem = e.item;
			if (storeItem == null) return;
			// Get reference to item view.
			var itemView:IStoreItemView = _itemViews.getFromItemId(storeItem.itemId);
			if (itemView == null) return;
			// Update quantity.
			itemView.purchasedAmount = storeItem.qtyOwned;
		}
		
		private function onUpdatedUserTokens(e:StoreItemListEvent):void
		{
			// Update item views.
			var i:int = 0;
			var len:int = _itemViews.length;
			for (i; i < len; i++)
			{
				var storeItemView:IStoreItemView = _itemViews.getAt(i);
				storeItemView.isAffordable = (_model.userTokens >= storeItemView.numTokens);
			}
		}
		
		private function onUpdatedUserLevel(e:StoreItemListEvent):void
		{
			// Update item views.
			var i:int = 0;
			var len:int = _itemViews.length;
			for (i; i < len; i++)
			{
				var storeItemView:IStoreItemView = _itemViews.getAt(i);
				storeItemView.isLocked = (_model.userSubLevel < storeItemView.levelRequirement) ? true : false;
			}
		}
		
	}
}