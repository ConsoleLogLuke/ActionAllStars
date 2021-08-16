package com.sdg.store.catalog
{
	import com.sdg.components.controls.SdgAlertChrome;
	import com.sdg.components.dialog.SaveYourGameDialog;
	import com.sdg.components.dialog.TransactionDialog;
	import com.sdg.control.AASModuleLoader;
	import com.sdg.events.AvatarUpdateEvent;
	import com.sdg.events.LoaderQueEvent;
	import com.sdg.model.Avatar;
	import com.sdg.model.DisplayObjectCollection;
	import com.sdg.model.ModelLocator;
	import com.sdg.model.StoreItem;
	import com.sdg.model.StoreItemCollection;
	import com.sdg.mvc.ViewBase;
	import com.sdg.net.Environment;
	import com.sdg.net.LoaderQue;
	import com.sdg.net.QuickLoader;
	import com.sdg.net.RemoteSoundBank;
	import com.sdg.net.socket.SocketClient;
	import com.sdg.store.StoreConstants;
	import com.sdg.store.item.IStoreItemView;
	import com.sdg.store.item.StoreItemViewEvent;
	import com.sdg.store.util.StoreUtil;
	import com.sdg.ui.RoundCornerCloseButton;
	import com.sdg.utils.ItemUtil;
	import com.sdg.utils.MainUtil;
	import com.sdg.utils.StoreTrackingUtil;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.Timer;

	public class StoreCatalogView extends ViewBase implements IStoreCatalogView
	{
		protected var _assetPath:String;
		protected var _featuredPanelBackgroundUrl:String;
		protected var _storeSelectPanelBackgroundUrl:String;
		protected var _bestSellersPanelBackgroundUrl:String;
		protected var _lowerRightPanelBackgroundUrl:String;
		
		protected var _loaderQue:LoaderQue;
		protected var _backing:Sprite;
		protected var _featuredPanel:IStoreCatalogFeaturedPanel;
		protected var _storeSelectPanel:StoreCatalogStoreSelectView;
		protected var _itemListPanel:IStoreCatalogItemListView;
		protected var _lowerRightPanel:Sprite;
		protected var _closeButton:RoundCornerCloseButton;
		protected var _avatar:Avatar;
		protected var _addTokensBtn:QuickLoader;
		protected var _header:TextField;
		protected var _items:StoreItemCollection;
		protected var _bestSellerType:uint;
		protected var _remoteSoundBank:RemoteSoundBank;
		protected var _abstarctTokenButton:Object;
		
		public function StoreCatalogView(width:Number, height:Number)
		{
			super();
			
			// Defaults.
			_width = width;
			_height = height;
			_assetPath = StoreUtil.GetAssetPath();
			_featuredPanelBackgroundUrl = _assetPath + 'store_catalog_featured_panel.swf';
			_storeSelectPanelBackgroundUrl = _assetPath + 'store_catalog_store_select_panel.swf';
			_bestSellersPanelBackgroundUrl = _assetPath + 'store_catalog_best_sellers_panel.swf';
			_lowerRightPanelBackgroundUrl = _assetPath + 'store_catalog_lower_Right_panel.swf';
			_avatar = ModelLocator.getInstance().avatar;
			_bestSellerType = 3;
			_remoteSoundBank = new RemoteSoundBank();
			
			// Create loader que.
			_loaderQue = new LoaderQue(1, 3000, 1, true);
			
			// Create backing.
			_backing = new Sprite();
			_backing.graphics.beginFill(0);
			_backing.graphics.drawRect(0, 0, 100, 100);
			addChild(_backing);
			
			// Create store select panel.
			_storeSelectPanel = new StoreCatalogStoreSelectView(440, 80);
			_storeSelectPanel.addEventListener(StoreCatalogStoreSelectEvent.STORE_SELECT, onStoreSelect);
			addChild(_storeSelectPanel);
			
			// Create item list panel.
			_itemListPanel = new StoreCatalogItemListView();
			_itemListPanel.setMargin(40, 11, 20, 0);
			_itemListPanel.addEventListener(StoreItemViewEvent.BUY_CLICK, onItemListBuyClick);
			_itemListPanel.addEventListener(StoreCatalogItemListEvent.FILTER_WEEK_CLICK, onFilterWeekClick);
			_itemListPanel.addEventListener(StoreCatalogItemListEvent.FILTER_MONTH_CLICK, onFilterMonthClick);
			addChild(_itemListPanel.display);
			
			// Create lower right panel.
			_lowerRightPanel = new Sprite();
			addChild(_lowerRightPanel);
			
			// Create add tokens button.
			var addTokensButtonUrl:String = _assetPath + 'btn_addTokens_Total.swf';
			_addTokensBtn = new QuickLoader(addTokensButtonUrl, onTokenButtonComplete);
			_addTokensBtn.buttonMode = true;
			//_addTokensBtn.addEventListener(MouseEvent.CLICK, onAddTokensClick);
			_lowerRightPanel.addChild(_addTokensBtn);
			
			// Create featured panel.
			_featuredPanel = new StoreCatalogFeaturedPanel();
			addChild(_featuredPanel.display);
			
			// Create header.
			_header = new TextField();
			_header.defaultTextFormat = new TextFormat('EuroStyle', 30, 0xffffff, true, true);
			_header.autoSize = TextFieldAutoSize.LEFT;
			_header.text = 'CATALOG: Featured Items';
			_header.embedFonts = true;
			addChild(_header);
			
			// Create close button.
			_closeButton = new RoundCornerCloseButton('Close Catalog');
			_closeButton.x = _width - _closeButton.width - 10;
			_closeButton.y = 10;
			_closeButton.buttonMode = true;
			_closeButton.addEventListener(MouseEvent.CLICK, onCloseClick);
			addChild(_closeButton);
			
			// Load panel backgrounds.
			loadPanelBackground(_lowerRightPanel, _lowerRightPanelBackgroundUrl);
			
			// Load featured panel background.
			_loaderQue.addEventListener(LoaderQueEvent.COMPLETE, onFeaturedBackgroundComplete);
			_loaderQue.addEventListener(LoaderQueEvent.ERROR, onFeaturedBackgroundError);
			_loaderQue.addRequest(new URLRequest(_featuredPanelBackgroundUrl));
			
			// Load best seller list background.
			_loaderQue.addEventListener(LoaderQueEvent.COMPLETE, onBestSellerBackgroundComplete);
			_loaderQue.addEventListener(LoaderQueEvent.ERROR, onBestSellerBackgroundError);
			_loaderQue.addRequest(new URLRequest(_bestSellersPanelBackgroundUrl));
			
			// Listen for token update on the avatar.
			_avatar.addEventListener(AvatarUpdateEvent.TOKENS_UPDATE, onAvatarTokenUpdate);
			
			// Load featured displays.
			loadFeaturedDisplays();
			
			// Load best seller items.
			loadBestSellers(_bestSellerType);
			
			function onFeaturedBackgroundComplete(e:LoaderQueEvent):void
			{
				// Make sure the event is for the proper background.
				if (e.loader.contentLoaderInfo.url != _featuredPanelBackgroundUrl) return;
				
				// Remove event listeners.
				_loaderQue.removeEventListener(LoaderQueEvent.COMPLETE, onFeaturedBackgroundComplete);
				_loaderQue.removeEventListener(LoaderQueEvent.ERROR, onFeaturedBackgroundError);
				
				// Pass asset to featured panel.
				_featuredPanel.background = e.loader.content;
			}
			
			function onFeaturedBackgroundError(e:LoaderQueEvent):void
			{
				// Make sure the event is for the proper background.
				if (e.loader.contentLoaderInfo.url != _featuredPanelBackgroundUrl) return;
				
				// Remove event listeners.
				_loaderQue.removeEventListener(LoaderQueEvent.COMPLETE, onFeaturedBackgroundComplete);
				_loaderQue.removeEventListener(LoaderQueEvent.ERROR, onFeaturedBackgroundError);
			}
			
			function onBestSellerBackgroundComplete(e:LoaderQueEvent):void
			{
				// Make sure the event is for the proper background.
				if (e.loader.contentLoaderInfo.url != _bestSellersPanelBackgroundUrl) return;
				
				// Remove event listeners.
				_loaderQue.removeEventListener(LoaderQueEvent.COMPLETE, onBestSellerBackgroundComplete);
				_loaderQue.removeEventListener(LoaderQueEvent.ERROR, onBestSellerBackgroundError);
				
				// Pass asset to best sellers panel.
				_itemListPanel.background = e.loader.content;
			}
			
			function onBestSellerBackgroundError(e:LoaderQueEvent):void
			{
				// Make sure the event is for the proper background.
				if (e.loader.contentLoaderInfo.url != _bestSellersPanelBackgroundUrl) return;
				
				// Remove event listeners.
				_loaderQue.removeEventListener(LoaderQueEvent.COMPLETE, onBestSellerBackgroundComplete);
				_loaderQue.removeEventListener(LoaderQueEvent.ERROR, onBestSellerBackgroundError);
			}
			
			function onTokenButtonComplete():void
			{
				_abstarctTokenButton = Object(_addTokensBtn.content);
				_abstarctTokenButton.tokenValue = _avatar.currency;
				render();
			}
			
		}
		
		override public function destroy():void
		{
			// Remove all event listeners.
			_closeButton.removeEventListener(MouseEvent.CLICK, onCloseClick);
			_storeSelectPanel.removeEventListener(StoreCatalogStoreSelectEvent.STORE_SELECT, onStoreSelect);
			_itemListPanel.removeEventListener(StoreItemViewEvent.BUY_CLICK, onItemListBuyClick);
			_itemListPanel.removeEventListener(StoreCatalogItemListEvent.FILTER_WEEK_CLICK, onFilterWeekClick);
			_itemListPanel.removeEventListener(StoreCatalogItemListEvent.FILTER_MONTH_CLICK, onFilterMonthClick);
			_avatar.removeEventListener(AvatarUpdateEvent.TOKENS_UPDATE, onAvatarTokenUpdate);
			
			// Destroy loader que.
			_loaderQue.stop();
			_loaderQue.clear(true);
			
			// Destroy featured panel.
			_featuredPanel.destroy();
			
			// Destroy store select.
			_storeSelectPanel.destroy();
		}
		
		override public function render():void
		{
			// Size backing.
			_backing.width = _width;
			_backing.height = _height;
			
			// Position featured panel.
			_featuredPanel.y = 40;
			
			// Header.
			_header.x = 55;
			_header.y = 12;
			
			// Position team select panel.
			_storeSelectPanel.width = _featuredPanel.width - 100;
			_storeSelectPanel.height = _height - _featuredPanel.y - _featuredPanel.height;
			_storeSelectPanel.x = _featuredPanel.width / 2 - _storeSelectPanel.width / 2;
			_storeSelectPanel.y = _featuredPanel.y + _featuredPanel.height;
			
			// Position item list panel.
			_itemListPanel.width = _width - _featuredPanel.width;
			_itemListPanel.height = _featuredPanel.height - 80;
			_itemListPanel.x = _featuredPanel.x + _featuredPanel.width - 6;
			_itemListPanel.y = 40;
			
			// Position lower right panel.
			_lowerRightPanel.x = _itemListPanel.x;
			_lowerRightPanel.y = _itemListPanel.y + _itemListPanel.height;
			
			// Position add tokens button.
			_addTokensBtn.x = 20;
			_addTokensBtn.y = 10;
		}
		
		protected function loadPanelBackground(panelContainer:Sprite, backgroundUrl:String):void
		{
			_loaderQue.addEventListener(LoaderQueEvent.COMPLETE, onComplete);
			_loaderQue.addEventListener(LoaderQueEvent.ERROR, onError);
			
			_loaderQue.addRequest(new URLRequest(backgroundUrl));
			
			function onComplete(e:LoaderQueEvent):void
			{
				// Make sure the event is for the proper background.
				if (e.loader.contentLoaderInfo.url != backgroundUrl) return;
				
				// Remove event listeners.
				_loaderQue.removeEventListener(LoaderQueEvent.COMPLETE, onComplete);
				_loaderQue.removeEventListener(LoaderQueEvent.ERROR, onError);
				
				// Add the loaded image to the panel container.
				panelContainer.addChildAt(e.loader.content, 0);
				
				render();
			}
			
			function onError(e:LoaderQueEvent):void
			{
				// Make sure the event is for the proper background.
				if (e.loader.contentLoaderInfo.url != backgroundUrl) return;
				
				// Remove event listeners.
				_loaderQue.removeEventListener(LoaderQueEvent.COMPLETE, onComplete);
				_loaderQue.removeEventListener(LoaderQueEvent.ERROR, onError);
			}
		}
		
		protected function loadFeaturedDisplays():void
		{
			// For testing purposes,
			// Create a collection of display objects and pass them to the featured panel.
			var collection:DisplayObjectCollection = new DisplayObjectCollection();
			
			// Load a feed of featured display items.
			var url:String = Environment.getApplicationUrl() + '/test/dyn/pdaCatalog/get';
			var request:URLRequest = new URLRequest(url);
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, onComplete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onError);
			loader.load(request);
			
			_featuredPanel.featuredDisplaySet = collection;
			
			function onComplete(e:Event):void
			{
				// Remove event listeners.
				loader.removeEventListener(Event.COMPLETE, onComplete);
				loader.removeEventListener(IOErrorEvent.IO_ERROR, onError);
				
				// Get feed xml.
				var xml:XML = new XML(loader.data);
				
				// Load displays.
				loadDisplays(xml);
			}
			
			function onError(e:IOErrorEvent):void
			{
				// Remove event listeners.
				loader.removeEventListener(Event.COMPLETE, onComplete);
				loader.removeEventListener(IOErrorEvent.IO_ERROR, onError);
			}
			
			function loadDisplays(feedXML:XML):void
			{
				var i:uint = 0;
				var loaderQue:LoaderQue = new LoaderQue(1, 3000, 1, false);
				var requestLen:uint = 0;
				var completeRequests:uint = 0;
				loaderQue.addEventListener(LoaderQueEvent.COMPLETE, onComplete);
				while (feedXML.PDACatalog[i] != null)
				{
					var displayXML:XML = feedXML.PDACatalog[i] as XML;
					if (displayXML == null) continue;
					
					var id:uint = (displayXML.page != null) ? displayXML.page : 0;
					var url:String = (displayXML.url != null) ? displayXML.url : null;
					url = Environment.getAssetUrl() + url;
					if (url == null) continue;
					
					requestLen++;
					loaderQue.addRequest(new URLRequest(url));
					
					i++;
				}
				
				// Start the loader que.
				loaderQue.start();
				
				function onComplete(e:LoaderQueEvent):void
				{
					// Increment completed requests.
					completeRequests++;
					
					// Listen for purchase events on the display.
					e.loader.content.addEventListener('buy item', onFeaturedDisplayBuy);
					
					// Add the display to the collection.
					collection.push(e.loader.content);
					
					if (completeRequests > requestLen - 1)
					{
						loaderQue.removeEventListener(LoaderQueEvent.COMPLETE, onComplete);
						_featuredPanel.featuredDisplaySet = collection;
					}
				}
			}
		}
		
		protected function loadBestSellers(listType:uint = 4):void
		{
			// Load the best seller feed.
			var url:String = Environment.getApplicationUrl() + '/test/dyn/topTenItems/get?avatarId=' + _avatar.id + '&topTenTypeId=' + listType;
			var request:URLRequest = new URLRequest(url);
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, onComplete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onError);
			loader.load(request);
			
			function onComplete(e:Event):void
			{
				// Remove event listeners.
				loader.removeEventListener(Event.COMPLETE, onComplete);
				loader.removeEventListener(IOErrorEvent.IO_ERROR, onError);
				
				// Get feed as XML.
				var xml:XML = new XML(loader.data)
				
				// Parse best sellers.
				var items:StoreItemCollection = parseBestSellersFeed(xml);
				
				// Keep track of items.
				_items = items;
				
				// Pass items to item list.
				_itemListPanel.items = _items;
			}
			
			function onError(e:IOErrorEvent):void
			{
				// Remove event listeners.
				loader.removeEventListener(Event.COMPLETE, onComplete);
				loader.removeEventListener(IOErrorEvent.IO_ERROR, onError);
			}
		}
		
		protected function parseBestSellersFeed(xml:XML):StoreItemCollection
		{
			// Take an xml feed and parse out store items.
			var i:uint = 0;
			var items:StoreItemCollection = new StoreItemCollection();
			while (xml.inWorldtopTen[i] != null)
			{
				var bestSellerXML:XML = xml.inWorldtopTen[i] as XML;
				if (bestSellerXML == null) continue;
				
				var id:int = (bestSellerXML.inWorldTopTenId != null) ? bestSellerXML.inWorldTopTenId : -1;
				var count:int = (bestSellerXML.inWorldTopTenId != null) ? bestSellerXML.inWorldTopTenId : -1;
				
				var item:StoreItem = StoreItem.StoreItemFromXML(bestSellerXML, StoreConstants.STORE_ID_TOPTEN);
				items.push(item);
				
				i++;
			}
			
			return items;
		}
		
		protected function buyItem(item:StoreItem, confirmPopup:Boolean = true):void
		{
			StoreUtil.BuyItem(ModelLocator.getInstance().avatar, StoreConstants.STORE_ID_CATALOG, item, onPurchaseComplete);
			
			function onPurchaseComplete(params:Object = null):void
			{
				// Get store item from params.
				var storeItem:StoreItem = params.storeItem;
				
				// Play purchase sound.
				playPurchaseSound(storeItem.price);
				SocketClient.getInstance().sendPluginMessage("avatar_handler", "uiEvent", { uiEvent:"<uiEvent><uiId>3</uiId><avUp>1</avUp></uiEvent>" });
				if(confirmPopup)SdgAlertChrome.show("Check your Inventory to use your new gear!", "ITEM PURCHASED!");
			}
			
		}
		
		protected function playPurchaseSound(price:uint):void
		{
			// Play a coin sound for every 100 tokens of price.
			var len:uint = Math.round(price / 1000);
			var delay:uint = 200;
			var soundUrl:String = _assetPath + 'register_open_01.mp3';
			var timer:Timer = new Timer(delay);
			timer.addEventListener(TimerEvent.TIMER, onTimerInterval);
			
			// Play the initial sound.
			_remoteSoundBank.playSound(soundUrl);
			
			// Start successive sounds.
			timer.start();
			
			function onTimerInterval(e:TimerEvent):void
			{
				if (timer.currentCount < len)
				{
					// Play the sound.
					_remoteSoundBank.playSound(soundUrl);
				}
				else
				{
					// Stop playing sounds.
					timer.removeEventListener(TimerEvent.TIMER, onTimerInterval);
					timer.reset();
				}
			}
		}
		
		////////////////////
		// EVENT HANDLERS
		////////////////////
		
		private function onCloseClick(e:MouseEvent):void
		{
			dispatchEvent(new StoreCatalogEvent(StoreCatalogEvent.CLOSE_CLICK));
		}
		
//		private function onAddTokensClick(e:MouseEvent):void
//		{
//			// Show the token transaction dialog.
//			if (_avatar.membershipStatus == 3)
//				MainUtil.showDialog(SaveYourGameDialog);
//			else
//				MainUtil.showDialog(TransactionDialog);
//		}
		
		private function onStoreSelect(e:StoreCatalogStoreSelectEvent):void
		{
			// Determine which store was selected.
			var storeId:uint = e.storeId;
			
			StoreTrackingUtil.trackCatalogStoreClick(storeId, true);
			
			// Open store.
			AASModuleLoader.openStoreModule({storeId:storeId}, 'StoreModule', 'Store', true);
		}
		
		private function onItemListBuyClick(e:StoreItemViewEvent):void
		{
			// Get a reference to the item view.
			var itemView:IStoreItemView = e.target as IStoreItemView;
			if (itemView == null) return;
			
			// Get item id.
			var itemId:uint = itemView.itemId;
			
			// Get reference to store item.
			var item:StoreItem = _items.getFromId(itemId);
			if (item == null) return;
			
			// Buy the item.
			buyItem(item, true);
		}
		
		private function onFeaturedDisplayBuy(e:Event):void
		{
			// Try to get an item id.
			var params:Object = e as Object;
			var itemId:int = (params.itemId != null) ? params.itemId : -1;
			if (itemId < 0) return;
			
			// Load attributes of the item.
			var url:String = ItemUtil.GetItemAttributesUrl(itemId);
			var request:URLRequest = new URLRequest(url);
			var urlLoader:URLLoader = new URLLoader();
			urlLoader.addEventListener(Event.COMPLETE, onComplete);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onError);
			urlLoader.load(request);
			
			function onComplete(e:Event):void
			{
				// Remove event listeners.
				urlLoader.removeEventListener(Event.COMPLETE, onComplete);
				urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, onError);
				
				// Get store item from loaded data.
				var itemXML:XML = new XML(urlLoader.data);
				var item:StoreItem = StoreItem.StoreItemFromXML(itemXML,StoreConstants.STORE_ID_CATALOG);
				if (item == null) return;
				
				// Buy the item.
				buyItem(item);
			}
			
			function onError(e:IOErrorEvent):void
			{
				// Remove event listeners.
				urlLoader.removeEventListener(Event.COMPLETE, onComplete);
				urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, onError);
			}
		}
		
		private function onFilterWeekClick(e:StoreCatalogItemListEvent):void
		{
			if (_bestSellerType == 3) return;
			_bestSellerType = 3;
			loadBestSellers(_bestSellerType);
		}
		
		private function onFilterMonthClick(e:StoreCatalogItemListEvent):void
		{
			if (_bestSellerType == 4) return;
			_bestSellerType = 4;
			loadBestSellers(_bestSellerType);
		}
		
		private function onAvatarTokenUpdate(e:AvatarUpdateEvent):void
		{
			_abstarctTokenButton.tokenValue = _avatar.currency;
		}
		
	}
}