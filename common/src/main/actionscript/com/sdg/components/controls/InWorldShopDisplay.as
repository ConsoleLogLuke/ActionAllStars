package com.sdg.components.controls
{
	import com.adobe.cairngorm.control.CairngormEventDispatcher;
	import com.sdg.components.dialog.SaveYourGameDialog;
	import com.sdg.components.dialog.TransactionDialog;
	import com.sdg.events.ItemPurchaseEvent;
	import com.sdg.graphics.Point;
	import com.sdg.model.Avatar;
	import com.sdg.model.ModelLocator;
	import com.sdg.model.StoreItem;
	import com.sdg.net.Environment;
	import com.sdg.net.QuickLoader;
	import com.sdg.net.socket.SocketClient;
	import com.sdg.store.StoreConstants;
	import com.sdg.utils.ItemUtil;
	import com.sdg.utils.MainUtil;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import mx.events.CloseEvent;
	
	public class InWorldShopDisplay extends Sprite
	{
		protected var _swfDialog:QuickLoader;
		
		public function InWorldShopDisplay()
		{
			const w:Number = 630;
			const h:Number = 510;
			
			super();
			
			var swfMask:Sprite = new Sprite();
			swfMask.graphics.beginFill(0x000000);
			swfMask.graphics.drawRect(0, 0, w, h);
			addChild(swfMask);
			mask = swfMask;
		}
		
		public function set swfUrl(value:String):void
		{
			if (_swfDialog != null)
				removeSwfDialog();
			
			_swfDialog = new QuickLoader(value, onSwfLoaded);
		}
		
		protected function removeSwfDialog():void
		{
			_swfDialog.removeEventListener('buy item', onBuyItem);
			_swfDialog.removeEventListener(Event.CLOSE, onClose);
			
			try
			{
				Object(_swfDialog.content).unloadSound();
			}
			catch(e:Error) {}
			
			removeChild(_swfDialog);
			_swfDialog = null;
		}
		
		protected function onSwfLoaded():void
		{
			addChild(_swfDialog);
			_swfDialog.addEventListener('buy item', onBuyItem);
			_swfDialog.addEventListener(Event.CLOSE, onClose);
		}
		
		protected function onClose(event:Event):void
		{
			close();
		}
		
		protected function close():void
		{
			removeSwfDialog();
			dispatchEvent(new Event(Event.CLOSE));
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
			
			if (avatar.membershipStatus == 3)
			{
				MainUtil.showDialog(SaveYourGameDialog);
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
			
		}
	}
}
