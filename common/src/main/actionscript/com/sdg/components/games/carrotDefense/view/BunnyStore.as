package com.sdg.components.games.carrotDefense.view
//      com.sdg.components.games.carrotDefense.view.BunnyStore
{
	import com.adobe.cairngorm.control.CairngormEventDispatcher;
	import com.sdg.components.controls.CustomMVPAlert;
	import com.sdg.components.controls.SdgAlertChrome;
	import com.sdg.components.dialog.InteractiveDialog;
	import com.sdg.components.dialog.SaveYourGameDialog;
	import com.sdg.events.ItemPurchaseEvent;
	import com.sdg.logging.LoggingUtil;
	import com.sdg.model.Avatar;
	import com.sdg.model.MembershipStatus;
	import com.sdg.model.ModelLocator;
	import com.sdg.model.StoreItem;
	import com.sdg.net.Environment;
	import com.sdg.net.QuickLoader;
	import com.sdg.net.socket.SocketClient;
	import com.sdg.store.StoreConstants;
	import com.sdg.utils.Constants;
	import com.sdg.utils.MainUtil;
	import com.sdg.utils.PreviewUtil;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;

	public class BunnyStore extends InteractiveDialog
	{
		public function BunnyStore()
		{
			super();
		}
		
		public override function init(params:Object):void
		{
			
			// just hardcode for now.
			params = {
					url:Environment.getAssetUrl() + '/test/gameSwf/gameId/106/gameFile/towerDefense_shop.swf'
					};
			super.init(params);	
			
			if (ModelLocator.getInstance().avatar.membershipStatus == MembershipStatus.GUEST)
			{
				MainUtil.showDialog(SaveYourGameDialog);
				this.close();	
				// don't need to do anything else
				return;
			}
			
		}
		
		private function initCurrentText():void
		{
			var av:Avatar = ModelLocator.getInstance().avatar;
			var url:String = Environment.getApplicationUrl() + '/api/dyn/avatar/ac?avatarId='+av.avatarId+'&currencyId=1';
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
				
				// Get feed xml.
				var xml:XML = new XML(loader.data);
				
				var s:Object = (_display as QuickLoader).content;
				try
				{
					s.setCarrotText(xml.balance);
				}
				catch(err:Error)
				{
					trace("FUNCTION NOT FOUND");
				}
			}
			
			function onError(e:IOErrorEvent):void
			{
				// Remove event listeners.
				loader.removeEventListener(Event.COMPLETE, onComplete);
				loader.removeEventListener(IOErrorEvent.IO_ERROR, onError);
			}
		}
		
		protected override function loadCompleteHandler():void
		{
			super.loadCompleteHandler();
			initCurrentText();
			//_display.x = -_display.width/2;
			//_display.y = -_display.height/2;
			
			try
			{
				var minWidth:Number = _display.width <= root.width ? _display.width : root.width;
				minWidth = root.width;
				_display.x = -minWidth/2;
				
				//var minHeight:Number = _display.height < root.height ? _display.height : root.height;
				var minHeight:Number = _display.height;
				minHeight = root.height;
				_display.y = -minHeight/2;
			}
			catch(e:Error)
			{
				_display.x = -_display.width/2;
				_display.y = -_display.height/2;
			}
		}
		
		// Completely overrided since need new currency.
		protected override function buyItem(item:StoreItem, confirmPopup:Boolean = true):void
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
				LoggingUtil.sendClickLogging(LoggingUtil.MVP_UPSELL_VIEW_CARROT_STORE);
				/*var mvpAlert:MVPAlert = MVPAlert.show("Only MVP members can shop in the Action AllStars stores. Become an MVP " + 
						"member now to collect all the hottest gear and Home Turf items!", "Join the Team!", onMVPClose);
						mvpAlert.addButton("Become A Member", LoggingUtil.MVP_UPSELL_CLICK_INTERACTIVE_DIALOG, 250);
						*/
						
				var mvpAlert:CustomMVPAlert = CustomMVPAlert.show(Environment.getAssetUrl() + '/test/gameSwf/gameId/106/gameFile/mvp_upsell_popUp_BunniesAttack_JoinTheTeam.swf',
																LoggingUtil.MVP_UPSELL_CLICK_CARROT_STORE,onMVPClose);
				
				
				return;
			}
			// Attempt to buy the item.
			
			// Make sure the item is the correct gender.
			//
			//
			
			// Try to make the purchase.
			CairngormEventDispatcher.getInstance().addEventListener(ItemPurchaseEvent.SUCCESS, onItemPurchaseSuccess);
			CairngormEventDispatcher.getInstance().addEventListener(ItemPurchaseEvent.ALREADY_OWNED, onItemAlreadyOwned);
			CairngormEventDispatcher.getInstance().addEventListener(ItemPurchaseEvent.INSUFFICIENT_TOKENS, onNotEnoughCurrency);
			CairngormEventDispatcher.getInstance().dispatchEvent(new ItemPurchaseEvent(avatar, item, StoreConstants.STORE_ID_INWOLRDSHOPDIALOG));
			
			function onItemPurchaseSuccess(e:ItemPurchaseEvent):void
			{
				// When an item is purchased successfuly, we want to put it on the avatar right away.
				
				// Remove event listener.
				CairngormEventDispatcher.getInstance().removeEventListener(ItemPurchaseEvent.SUCCESS, onItemPurchaseSuccess);
				CairngormEventDispatcher.getInstance().removeEventListener(ItemPurchaseEvent.ALREADY_OWNED, onItemAlreadyOwned);
				CairngormEventDispatcher.getInstance().removeEventListener(ItemPurchaseEvent.INSUFFICIENT_TOKENS, onNotEnoughCurrency);
				
				// Make sure the event is for the correct avatar.
				if (avatar.id != e.avatar.id) return;
				
				// Make sure the item is the one we just tried to buy.
				if (item.id != e.storeItem.id) return;
				
				// Play purchase sound.
				//playPurchaseSound(item.price);
				SocketClient.getInstance().sendPluginMessage("avatar_handler", "uiEvent", { uiEvent:"<uiEvent><uiId>3</uiId><avUp>1</avUp></uiEvent>" });
				if(e.storeItem.itemTypeId != com.sdg.utils.PreviewUtil.PETS)
				{
					SdgAlertChrome.show("Check your Inventory to use your new gear!", "ITEM PURCHASED!");
				}
				else
				{
					SdgAlertChrome.show("You Adopted " + e.storeItem.name, "Pet Adopted!");
				}
				
				close();
			}
			
			function onItemAlreadyOwned(e:ItemPurchaseEvent):void
			{
				// When an item is purchased successfuly, we want to put it on the avatar right away.
				
				// Remove event listener.
				CairngormEventDispatcher.getInstance().removeEventListener(ItemPurchaseEvent.SUCCESS, onItemPurchaseSuccess);
				CairngormEventDispatcher.getInstance().removeEventListener(ItemPurchaseEvent.ALREADY_OWNED, onItemAlreadyOwned);
				CairngormEventDispatcher.getInstance().removeEventListener(ItemPurchaseEvent.INSUFFICIENT_TOKENS, onNotEnoughCurrency);
				if(e.storeItem.itemTypeId != com.sdg.utils.PreviewUtil.PETS)
				{
					SdgAlertChrome.show("Hey, did you know you already own this item?  Open your Customizer to find and use it.", "TIME OUT!");
				}
				else
				{
					SdgAlertChrome.show("Hey, did you know you already own this pet?", "TIME OUT!");
				}
			}
			
			function onNotEnoughCurrency(ev:ItemPurchaseEvent):void
			{
				CairngormEventDispatcher.getInstance().removeEventListener(ItemPurchaseEvent.SUCCESS, onItemPurchaseSuccess);
				CairngormEventDispatcher.getInstance().removeEventListener(ItemPurchaseEvent.ALREADY_OWNED, onItemAlreadyOwned);
				CairngormEventDispatcher.getInstance().removeEventListener(ItemPurchaseEvent.INSUFFICIENT_TOKENS, onNotEnoughCurrency);
				
				SdgAlertChrome.show("Hey there, it looks like you need more carrots!", "TIME OUT!");
			}
			function onMVPClose(event:Object):void
			{
				var identifier:int = event.detail;
				
				if (identifier == LoggingUtil.MVP_UPSELL_CLICK_CARROT_STORE)
					MainUtil.goToMVP(identifier);
			}
			
		}
		
	}
}