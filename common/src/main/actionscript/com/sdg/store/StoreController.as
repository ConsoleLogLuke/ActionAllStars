package com.sdg.store
{
	import com.adobe.cairngorm.control.CairngormEventDispatcher;
	import com.sdg.components.controls.SdgAlertChrome;
	import com.sdg.components.dialog.SaveYourGameDialog;
	import com.sdg.components.dialog.TransactionDialog;
	import com.sdg.events.AvatarApparelSaveEvent;
	import com.sdg.events.AvatarUpdateEvent;
	import com.sdg.events.InventoryListEvent;
	import com.sdg.model.InventoryItem;
	import com.sdg.model.ItemType;
	import com.sdg.model.StoreItem;
	import com.sdg.net.QuickLoader;
	import com.sdg.net.socket.SocketClient;
	import com.sdg.store.item.StoreItemEvent;
	import com.sdg.store.nav.StoreNavEvent;
	import com.sdg.store.preview.StoreAvatarPreviewEvent;
	import com.sdg.store.skin.IStoreSkin;
	import com.sdg.store.util.StoreUtil;
	import com.sdg.utils.ItemUtil;
	import com.sdg.utils.MainUtil;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Timer;

	public class StoreController extends EventDispatcher implements IStoreController
	{
		protected var _model:IStoreModel;
		
		public function StoreController(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		public function init(model:IStoreModel):void
		{
			// Store reference to the model.
			_model = model;
			
			// Initialize the view.
			_model.view.init(_model.defaultWidth, _model.defaultHeight);
			
			// Pass the item list view to the main view.
			_model.view.itemListView = _model.itemListModel.view;
			
			// Pass the nav view to the main view.
			_model.view.navView = _model.navModel.view;
			
			// Pass the avatar preview view to the main view.
			_model.view.avatarPreviewView = _model.avatarPreviewModel.view;
			
			// Pass the home view to the main view.
			_model.view.homeView = _model.homeView;
			
			// Pass the tooltip to the main view.
			_model.view.toolTip = _model.toolTip;
			
			// Listen to the model for events.
			_model.addEventListener(StoreEvent.ITEMS_UPDATE, onItemsUpdate);
			
			// Listen to item list controller for events.
			_model.itemListModel.controller.addEventListener(StoreItemEvent.SELECT, onItemSelect);
			_model.itemListModel.controller.addEventListener(StoreItemEvent.ROLL_OVER, onItemRollOver);
			_model.itemListModel.controller.addEventListener(StoreItemEvent.ROLL_OUT, onItemRollOut);
			_model.itemListModel.controller.addEventListener(StoreItemEvent.BUY, onItemBuy);
			_model.itemListModel.controller.addEventListener(StoreItemEvent.DESELECT, onItemDeselect);
			
			// Listen to the nav controller for events.
			_model.navModel.controller.addEventListener(StoreNavEvent.CATEGORY_SELECT, onCategorySelect);
			_model.navModel.controller.addEventListener(StoreNavEvent.ROLL_OVER, onNavIconRollOver);
			_model.navModel.controller.addEventListener(StoreNavEvent.ROLL_OUT, onNavIconRollOut);
			
			// Listen to the nav view for events.
			_model.navModel.view.addEventListener(StoreNavEvent.NAV_RESET, onNavReset);
			
			// Listen to the avatar preview controller for events.
			_model.avatarPreviewModel.controller.addEventListener(StoreAvatarPreviewEvent.ADD_TOKENS_CLICK, onAddTokensClick);
			
			// Listen to view for events.
			_model.view.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			_model.view.addEventListener(StoreEvent.CLOSE_CLICK, onCloseClick);
			
			// Listen to the home view for buy events.
			_model.homeView.addEventListener('buy item', onHomeViewBuy);
			
			// Listen for user token amount changes.
			_model.avatar.addEventListener(AvatarUpdateEvent.TOKENS_UPDATE, onUserTokensUpdated);
			_model.avatar.addEventListener(AvatarUpdateEvent.SUBLEVEL_UPDATE, onAvatarSubLevelUpdate);
			
			// Apply the initial skin.
			applySkin();
			
			// Load shop keeper.
			loadShopKeeper();
			
			// Update inventory.
			_model.updateInventory();
			
			initAvatar();
		}
		
		////////////////////
		// INSTANCE METHODS
		////////////////////
		
		private function closeStore():void
		{
			// Do all clean up procedures.
			// Call destroy on controllers.
			_model.itemListModel.controller.destroy();
			_model.avatarPreviewModel.controller.destroy();
			
			// Call destroy on the main view.
			_model.view.destroy();
			
			// Remove all event listeners.
			_model.removeEventListener(StoreEvent.ITEMS_UPDATE, onItemsUpdate);
			_model.itemListModel.controller.removeEventListener(StoreItemEvent.SELECT, onItemSelect);
			_model.itemListModel.controller.removeEventListener(StoreItemEvent.ROLL_OVER, onItemRollOver);
			_model.itemListModel.controller.removeEventListener(StoreItemEvent.ROLL_OUT, onItemRollOut);
			_model.itemListModel.controller.removeEventListener(StoreItemEvent.BUY, onItemBuy);
			_model.itemListModel.controller.removeEventListener(StoreItemEvent.DESELECT, onItemDeselect);
			_model.navModel.controller.removeEventListener(StoreNavEvent.CATEGORY_SELECT, onCategorySelect);
			_model.navModel.controller.removeEventListener(StoreNavEvent.ROLL_OVER, onNavIconRollOver);
			_model.navModel.controller.removeEventListener(StoreNavEvent.ROLL_OUT, onNavIconRollOut);
			_model.navModel.view.removeEventListener(StoreNavEvent.NAV_RESET, onNavReset);
			_model.avatarPreviewModel.controller.removeEventListener(StoreAvatarPreviewEvent.ADD_TOKENS_CLICK, onAddTokensClick);
			_model.view.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			_model.view.removeEventListener(StoreEvent.CLOSE_CLICK, onCloseClick);
			_model.homeView.removeEventListener('buy item', onHomeViewBuy);
			_model.avatar.removeEventListener(AvatarUpdateEvent.TOKENS_UPDATE, onUserTokensUpdated);
			_model.avatar.removeEventListener(AvatarUpdateEvent.SUBLEVEL_UPDATE, onAvatarSubLevelUpdate);
			
			dispatchEvent(new StoreEvent(StoreEvent.CLOSE_STORE));
		}
		
		protected function initAvatar():void
		{
			// Get the avatar and pass it to the avatar preview model.
			_model.avatarPreviewModel.avatar = _model.avatar;
			
			// Pass user info to item list model.
			_model.itemListModel.userLevel = _model.avatar.level;
			_model.itemListModel.userSubLevel = _model.avatar.subLevel;
			_model.itemListModel.userTokens = _model.avatar.currency;
		}
		
		protected function applySkin():void
		{
			// Pass skin values to individual components.
			var storeSkin:IStoreSkin = _model.skin;
			storeSkin.storeId = _model.storeId;
			if (storeSkin.avatarPreviewBackgroundUrl) _model.avatarPreviewModel.backgroundUrl = storeSkin.avatarPreviewBackgroundUrl;
			if (storeSkin.itemListBackgroundUrl) _model.itemListModel.backgroundUrl = storeSkin.itemListBackgroundUrl;
			if (storeSkin.itemListWindowBackgroundUrl) _model.itemListModel.windowBackgroundUrl = storeSkin.itemListWindowBackgroundUrl;
			_model.navModel.setNavBorderUrls(storeSkin.navBorderTopUrl, storeSkin.navBorderMiddleUrl, storeSkin.navBorderBottomUrl);
			
			// Load store background and pass it to the view.
			var url:String = _model.backgroundUrl;
			var background:DisplayObject = new QuickLoader(url, backgroundComplete);
			
			function backgroundComplete():void
			{
				_model.view.background = background;
			}
		}
		
		protected function loadShopKeeper():void
		{
			// Load the shop keeper graphic and add it to the view.
			var url:String = _model.shopKeeperUrl;
			var shopKeeper:DisplayObject = new QuickLoader(url, onShopKeeperComplete);
			
			function onShopKeeperComplete():void
			{
				_model.view.shopKeeperDisplay = shopKeeper;
			}
		}
		
		protected function buyItem(item:StoreItem, confirmPopup:Boolean = true):void
		{
			// This will tell the server that we want the avatar to buy an item.
			StoreUtil.BuyItem(_model.avatar, _model.storeId, item, onPurchaseComplete);
			
			// This function gets called once the server says the purchase was successful.
			function onPurchaseComplete(params:Object = null):void
			{
				// Get store item from params.
				var storeItem:StoreItem = params.storeItem;
				// Get user inventory items from params.
				var userInventoryItems:Object = params.userInventoryItems;
				
				// Trigger purchase indicator.
				// Plays animations for the user to see and understand that their purchase
				// was successful.
				playPurchaseIndicator(storeItem);
				
				// Make sure it is a clothing item; as oppose to furniture.
				if (ItemType.IsClothing(storeItem.itemTypeId) == true)
				{
					// If clothing was purchased, place all purchased clothing
					// items on the avatar.
					for each (var inventoryItem:InventoryItem in userInventoryItems)
					{
						// Put the item on the avatar.
						_model.avatar.setApparel(inventoryItem);
					}
					
					// Tell the server to save what the avtar is currently wearing.
					// This way, when they leave the store, they will be wearing these
					// clothes in the world.
					CairngormEventDispatcher.getInstance().addEventListener(AvatarApparelSaveEvent.SAVE_SUCCESS, onSaveSuccess);
					CairngormEventDispatcher.getInstance().dispatchEvent(new AvatarApparelSaveEvent(_model.avatar));
				}
				else if (storeItem.itemTypeId == ItemType.PET_FOOD)
				{
					// If pet food was purchased, set the pet food item on the avatar.
					var petFoodItem:InventoryItem = params.userInventoryItems[0] as InventoryItem;
					if (petFoodItem) _model.avatar.setPetFoodInventoryItem(petFoodItem);
					// Pet food should be treated like everything else as far as this ui event call
					SocketClient.getInstance().sendPluginMessage("avatar_handler", "uiEvent", { uiEvent:"<uiEvent><uiId>2</uiId><avUp>1</avUp></uiEvent>" });
				}
				else
				{
					// Ask kevin what the hell this does.
					//this is handled by the AvatarApparelSaveCommand for clothing, so do this for furni as well...
					SocketClient.getInstance().sendPluginMessage("avatar_handler", "uiEvent", { uiEvent:"<uiEvent><uiId>2</uiId><avUp>1</avUp></uiEvent>" });
				}
				
				// Show a pop-up to the user that confirms the purchase.
				if(storeItem.itemTypeId == ItemType.PETS && confirmPopup)
				{
					SdgAlertChrome.show("You Adopted " + storeItem.name, "Pet Adopted!");
					
					// The pet button needs to be updated to know that they own a pet now.
					CairngormEventDispatcher.getInstance().dispatchEvent(new InventoryListEvent(_model.avatar.avatarId, ItemType.PETS));
				}
				else if(confirmPopup)
				{
					SdgAlertChrome.show("Check your inventory to use your new gear!", "ITEM PURCHASED");
				}
				
				// Update quantity owned.
				// Increment quantity owned for the purchased item.
				storeItem.qtyOwned++;
				// Update item quantity in the item list.
				_model.itemListModel.updateItemQuantity(storeItem);
				// Execute function specific to the controller
				storeUpdateOnPurchase();	
			}
			
			function onSaveSuccess(e:AvatarApparelSaveEvent):void
			{
				// Remove event listener.
				CairngormEventDispatcher.getInstance().removeEventListener(AvatarApparelSaveEvent.SAVE_SUCCESS, onSaveSuccess);
				
				// Reset the avatar preview.
				_model.avatarPreviewModel.avatar = _model.avatar;
			}
		}
		
		// Special call child controllers
		protected function storeUpdateOnPurchase():void
		{}
		
		protected function playPurchaseIndicator(item:StoreItem):void
		{
			// Play a sound to indicate the purchase.
			playPurchaseSound(item.price);
		}
		
		protected function playPurchaseSound(price:uint):void
		{
			// Play a coin sound for every 100 tokens of price.
			var max:uint = 7;
			var len:uint = Math.min(Math.round(price / 300), max);
			var delay:uint = 200;
			var soundUrl:String = _model.coinSoundUrl;
			var timer:Timer = new Timer(delay);
			timer.addEventListener(TimerEvent.TIMER, onTimerInterval);
			
			// Play the initial sound.
			_model.remoteSoundBank.playSound(soundUrl);
			
			// Start successive sounds.
			timer.start();
			
			function onTimerInterval(e:TimerEvent):void
			{
				if (timer.currentCount < len)
				{
					// Play the sound.
					_model.remoteSoundBank.playSound(soundUrl);
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
		
		private function onItemsUpdate(e:StoreEvent):void
		{
			// Pass the item collection to the item list model.
			_model.itemListModel.itemCollection = _model.items;
			
			// Send the view to browse view.
			_model.view.goToBrowseView();
		}
		
		private function onItemSelect(e:StoreItemEvent):void
		{
			// When an item is selected from the item list...
			
			// If the item is a background, don't do anything.
			if (e.item.itemTypeId == ItemType.BACKGROUNDS) return;
			
			if(e.item.isGroup)
			{
				_model.avatarPreviewModel.addItemSet(e.item);
			}
			else
			{
				// Put the item on the avatar.
				_model.avatarPreviewModel.addItem(e.item);
			}
		}
		
		private function onItemBuy(e:StoreItemEvent):void
		{
			// Attempt to buy the item.
			buyItem(e.item, false);
		}
		
		private function onItemRollOver(e:StoreItemEvent):void
		{
			// When an item is rolled over with the mouse...
			
			// Update the tooltip with item info.
			var item:StoreItem = e.item;
			var itemInfo:String = 	item.name + '\n' +
									item.description + '\n' +
									item.price + ' Tokens';
			_model.toolTip.text = itemInfo;
			
			// Show the tooltip.
			_model.toolTip.visible = true;
		}
		
		private function onItemRollOut(e:StoreItemEvent):void
		{
			// When an item is rolled out with the mouse...
			
			// Hide the tooltip.
			_model.toolTip.visible = false;
		}
		
		private function onNavIconRollOver(e:StoreNavEvent):void
		{
			// Update the tooltip with item info.
			var teamName:String = e.team;
			_model.toolTip.text = teamName;
			
			// Show the tooltip.
			_model.toolTip.visible = true;
		}
		
		private function onNavIconRollOut(e:StoreNavEvent):void
		{
			// Hide the tooltip.
			_model.toolTip.visible = false;
		}
		
		private function onMouseMove(e:MouseEvent):void
		{
			// Make the tooltip follow the mouse.
			_model.toolTip.x = _model.view.mouseX + 10;
			_model.toolTip.y = _model.view.mouseY;
		}
		
		private function onCategorySelect(e:StoreNavEvent):void
		{
			// Get cateogry id.
			var catId:uint = e.categoryId;
			
			// Select category.
			_model.selectCategory(catId);
			
			// Hide the shop keeper.
			_model.view.hideShopKeeper();
		}
		
		private function onAddTokensClick(e:StoreAvatarPreviewEvent):void
		{
			// Show the token transaction dialog.
			if (_model.avatar.membershipStatus == 3)
				MainUtil.showDialog(SaveYourGameDialog);
			else
				MainUtil.showDialog(TransactionDialog);
		}
		
		private function onCloseClick(e:StoreEvent):void
		{
			closeStore();
		}
		
		protected function onHomeViewBuy(e:Event):void
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
				var item:StoreItem = StoreItem.StoreItemFromXML(itemXML);
				if (item == null) return;
				
				// Buy the item.
				buyItem(item, true);
			}
			
			function onError(e:IOErrorEvent):void
			{
				// Remove event listeners.
				urlLoader.removeEventListener(Event.COMPLETE, onComplete);
				urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, onError);
			}
		}
		
		private function onNavReset(e:StoreNavEvent):void
		{
			// Reset Current Category
			_model.categoryId = 0;
			
			// When we recieve a nav reset event we want to return to the home view.
			_model.view.goToHomeView();
		}
		
		private function onItemDeselect(e:StoreItemEvent):void
		{
			// Reset clothing.
			_model.avatarPreviewModel.resetClothing();
		}
		
		private function onUserTokensUpdated(e:AvatarUpdateEvent):void
		{
			_model.itemListModel.userTokens = _model.avatar.currency;
		}
		
		private function onAvatarSubLevelUpdate(e:AvatarUpdateEvent):void
		{
			// Update item list model.
			_model.itemListModel.userSubLevel = _model.avatar.subLevel;
			_model.itemListModel.userLevel = _model.avatar.level;
		}
		
	}
}