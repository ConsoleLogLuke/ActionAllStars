package com.sdg.components.dialog
{
	import com.adobe.cairngorm.control.CairngormEventDispatcher;
	import com.sdg.business.resource.IRemoteResource;
	import com.sdg.components.controls.MVPAlert;
	import com.sdg.components.controls.SdgAlertChrome;
	import com.sdg.events.ItemPurchaseEvent;
	import com.sdg.events.RoomNavigateEvent;
	import com.sdg.logging.LoggingUtil;
	import com.sdg.model.Avatar;
	import com.sdg.model.ModelLocator;
	import com.sdg.model.StoreItem;
	import com.sdg.net.QuickLoader;
	import com.sdg.net.socket.SocketClient;
	import com.sdg.store.StoreConstants;
	import com.sdg.utils.Constants;
	import com.sdg.utils.ItemUtil;
	import com.sdg.utils.MainUtil;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import mx.containers.Canvas;
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;

	public class InteractiveDialog extends Canvas implements ISdgDialog
	{
		protected var _url:String = "";
		protected var _id:String = "";
		protected var _display:DisplayObject;
		protected var _resource:IRemoteResource;
		
		// To Regulate Logging
		private var _loggingStatus:Boolean = false; // turns on logging
		
		public function InteractiveDialog()
		{
			super();
			
			this.x = 0;
			this.y = 0;
		}
		
		public function init(params:Object):void
		{
			if (params)
			{
				_url = params.url;
				_id = params.id;
			}
			else
			{
				this.close();
			}
			
			_display = new QuickLoader(_url, loadCompleteHandler,null,3);
		}
		
		protected function loadCompleteHandler():void
		{
			_display.addEventListener(Event.CLOSE,onClick);
			_display.addEventListener("Transport",onTransport);
			_display.addEventListener('buy item', onBuyItem);
			this.rawChildren.addChild(_display);
			
			_loggingStatus = true;
			
			// So we can set dynamic content in the loaded swf.
			this.dispatchEvent(new Event(Event.COMPLETE));
		}
		
		protected function onBuyItem(event:Event):void
		{
			// Try to get an item id.
			var params:Object = event as Object;
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
				var item:StoreItem = StoreItem.StoreItemFromXML(itemXML,StoreConstants.STORE_ID_INWOLRDSHOPDIALOG);
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
		
		protected function buyItem(item:StoreItem, confirmPopup:Boolean = true):void
		{
			var avatar:Avatar = ModelLocator.getInstance().avatar;
			if (avatar.membershipStatus == Constants.MEMBER_STATUS_GUEST)
			{
				MainUtil.showDialog(SaveYourGameDialog);
				return;
			}
			// for cancelled or free users
			else if (avatar.membershipStatus != Constants.MEMBER_STATUS_PREMIUM)
			{
				LoggingUtil.sendClickLogging(LoggingUtil.MVP_UPSELL_VIEW_INTERACTIVE_DIALOG);
				var mvpAlert:MVPAlert = MVPAlert.show("Only MVP members can shop in the Action AllStars stores. Become an MVP " + 
						"member now to collect all the hottest gear and Home Turf items!", "Join the Team!", onMVPClose);
				
				mvpAlert.addButton("Become A Member", LoggingUtil.MVP_UPSELL_CLICK_INTERACTIVE_DIALOG, 250);
				return;
			}
			// Attempt to buy the item.
			
			// Make sure the user has enough currency.
			if (avatar.currency < item.price)
			{
				SdgAlertChrome.show("Hey there, it looks like you need more tokens!", "TIME OUT!");
				return;
			}
			
			// Make sure the avatar level is high enough to buy this item.
			if (avatar.subLevel < item.levelRequirement)
			{
				SdgAlertChrome.show("That's a bummer... you need to level up to own this item.", "TIME OUT!");
				return;
			}
			
			// Make sure the item is the correct gender.
			//
			//
			
			// Try to make the purchase.
			CairngormEventDispatcher.getInstance().addEventListener(ItemPurchaseEvent.SUCCESS, onItemPurchaseSuccess);
			CairngormEventDispatcher.getInstance().addEventListener(ItemPurchaseEvent.ALREADY_OWNED, onItemAlreadyOwned);
			CairngormEventDispatcher.getInstance().dispatchEvent(new ItemPurchaseEvent(avatar, item, StoreConstants.STORE_ID_CATALOG));
			
			function onItemPurchaseSuccess(e:ItemPurchaseEvent):void
			{
				// When an item is purchased successfuly, we want to put it on the avatar right away.
				
				// Remove event listener.
				CairngormEventDispatcher.getInstance().removeEventListener(ItemPurchaseEvent.SUCCESS, onItemPurchaseSuccess);
				CairngormEventDispatcher.getInstance().removeEventListener(ItemPurchaseEvent.ALREADY_OWNED, onItemAlreadyOwned);
				
				// Make sure the event is for the correct avatar.
				if (avatar.id != e.avatar.id) return;
				
				// Make sure the item is the one we just tried to buy.
				if (item.id != e.storeItem.id) return;
				
				// Play purchase sound.
				//playPurchaseSound(item.price);
				SocketClient.getInstance().sendPluginMessage("avatar_handler", "uiEvent", { uiEvent:"<uiEvent><uiId>3</uiId><avUp>1</avUp></uiEvent>" });
				if(confirmPopup)SdgAlertChrome.show("Check your Inventory to use your new gear!", "ITEM PURCHASED!");
				
				close();
			}
			
			function onItemAlreadyOwned(e:ItemPurchaseEvent):void
			{
				// When an item is purchased successfuly, we want to put it on the avatar right away.
				
				// Remove event listener.
				CairngormEventDispatcher.getInstance().removeEventListener(ItemPurchaseEvent.SUCCESS, onItemPurchaseSuccess);
				CairngormEventDispatcher.getInstance().removeEventListener(ItemPurchaseEvent.ALREADY_OWNED, onItemAlreadyOwned);
				
				SdgAlertChrome.show("Hey, did you know you already own this item?  Open your Customizer to find and use it.", "TIME OUT!");
			}
			
			function onMVPClose(event:CloseEvent):void
			{
				var identifier:int = event.detail;
				
				if (identifier == LoggingUtil.MVP_UPSELL_CLICK_INTERACTIVE_DIALOG)
					MainUtil.goToMVP(identifier);
			}
			
		}
		
		protected function onClick(e:Event):void
		{
			this.close();
		}
		
		protected function onTransport(e:Event):void
		{
			var roomId:String = "";
			if (e.hasOwnProperty("roomId"))
			{
				var obj:Object =  e as Object;
				roomId = obj.roomId as String;
			}
			
			if (_loggingStatus)
			{
				_loggingStatus = false;
				LoggingUtil.sendSignTransportClickLogging(int(_id));
			}
			
			dispatchEvent(new RoomNavigateEvent(RoomNavigateEvent.ENTER_ROOM, roomId));
			
			this.close();
		}
		
		public function close():void
		{
			_loggingStatus = false;			
			
			// Remove Listener
			_display.removeEventListener(Event.CLOSE,onClick);
			_display.removeEventListener("Transport",onTransport);
			_display.removeEventListener('buy item', onBuyItem);
			
			try
			{
				Object(_display).unloadSound();
			}
			catch(e:Error) {}
			
			//Forward the close event to anything listening
			this.dispatchEvent(new Event(Event.CLOSE));
			
			PopUpManager.removePopUp(this);
		}
		
		//Useful for listening to custom events.
		public function get content():DisplayObject
		{
			return this._display;
		}
		
	}
}