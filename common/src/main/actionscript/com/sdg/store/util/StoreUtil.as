package com.sdg.store.util
{
	import com.adobe.cairngorm.control.CairngormEventDispatcher;
	import com.sdg.components.controls.CustomMVPAlert;
	import com.sdg.components.controls.SdgAlertChrome;
	import com.sdg.components.dialog.SaveYourGameDialog;
	import com.sdg.events.ItemPurchaseEvent;
	import com.sdg.logging.LoggingUtil;
	import com.sdg.model.Avatar;
	import com.sdg.model.StoreItem;
	import com.sdg.net.Environment;
	import com.sdg.store.StoreConstants;
	import com.sdg.utils.Constants;
	import com.sdg.utils.MainUtil;
	import com.sdg.utils.PreviewUtil;
	
	import mx.events.CloseEvent;
	
	public class StoreUtil extends Object
	{
		protected static const _assetPath:String = Environment.getAssetUrl() + '/test/gameSwf/gameId/70/gameFile/';
		
		public static function GetStoreHomeViewUrl(storeId:uint):String
		{
			return _assetPath + 'store_home_' + storeId + '.swf';
		}
		
		public static function GetStoreBackgroundUrl(storeId:uint):String
		{
			return _assetPath + 'store_background_' + storeId + '.swf';
		}
		
		public static function GetShopKeeperUrl(storeId:uint):String
		{
			return _assetPath + 'shopkeeper_' + storeId + '.swf';
		}
		
		public static function GetAssetPath():String
		{
			return _assetPath;
		}
		
		public static function GetCategoryThumbnailUrl(categoryId:uint):String
		{
			return Environment.getAssetUrl() + '/test/static/categoryThumbSwf?categoryId=' + categoryId;
		}
		
		public static function BuyItem(avatar:Avatar, storeId:int, item:StoreItem, onPurchaseComplete:Function = null, onAlreadyOwned:Function = null):void
		{
			// The user must be registered to buy items.
			if (avatar.membershipStatus == Constants.MEMBER_STATUS_GUEST)
			{
				MainUtil.showDialog(SaveYourGameDialog);
				return;
			}
			else if (avatar.membershipStatus == Constants.MEMBER_STATUS_FREE)
			{
				LoggingUtil.sendClickLogging(StoreConstants.getLoggingViewIdForStore(storeId));
				var closeIdentifierForLogging:int = StoreConstants.getLoggingClickIdForStore(storeId);
				
				CustomMVPAlert.show(Environment.getApplicationUrl() + "/test/gameSwf/gameId/82/gameFile/mvp_upsell_popUp_Store.swf",
											closeIdentifierForLogging, onClose);
				
				function onClose(event:CloseEvent):void
				{
					var identifier:int = event.detail;
					
					if (identifier == closeIdentifierForLogging)
						MainUtil.goToMVP(identifier);
				}
			
				return;
			}
			
			// Attempt to buy the item.
			if (item == null) return;
			
			// Make sure the user has enough currency.
			if (avatar.currency < item.price)
			{
				SdgAlertChrome.show("Hey there, it looks like you need more tokens!", "TIME OUT!");
				return;
			}
			
			// Make sure the avatar level is high enough to buy this item.
			if (avatar.subLevel < item.levelRequirement)
			{
				SdgAlertChrome.show("Sorry, you must level up to buy this item.", "Time Out!");
				return;
			}
			
			// Try to make the purchase.
			CairngormEventDispatcher.getInstance().addEventListener(ItemPurchaseEvent.SUCCESS, onItemPurchaseSuccess);
			CairngormEventDispatcher.getInstance().addEventListener(ItemPurchaseEvent.ALREADY_OWNED, onItemAlreadyOwned);
			CairngormEventDispatcher.getInstance().dispatchEvent(new ItemPurchaseEvent(avatar, item, storeId));

			function onItemPurchaseSuccess(e:ItemPurchaseEvent):void
			{
				// When an item is purchased successfuly, we want to put it on the avatar right away.
				
				// Remove event listener.
				CairngormEventDispatcher.getInstance().removeEventListener(ItemPurchaseEvent.SUCCESS, onItemPurchaseSuccess);
				CairngormEventDispatcher.getInstance().removeEventListener(ItemPurchaseEvent.ALREADY_OWNED, onItemAlreadyOwned);
				
				if (item == null) item = e.storeItem;
				
				// Make sure the event is for the correct avatar.
				if (avatar.id != e.avatar.id) return;
				
				// Make sure the item is the one we just tried to buy.
				if (item.id != e.storeItem.id) return;
				
				// Callback
				if (onPurchaseComplete != null) onPurchaseComplete(e);
			}
			
			function onItemAlreadyOwned(e:ItemPurchaseEvent):void
			{
				// The item is already owned and we don't allow purchasing twice.
				
				// Remove event listener.
				CairngormEventDispatcher.getInstance().removeEventListener(ItemPurchaseEvent.SUCCESS, onItemPurchaseSuccess);
				CairngormEventDispatcher.getInstance().removeEventListener(ItemPurchaseEvent.ALREADY_OWNED, onItemAlreadyOwned);
				
				var location:String;
				if (e.storeItem.itemTypeId == PreviewUtil.THEME)
					location = "Home Turf";
				else
					location = "Customizer";
				
				if(e.storeItem.itemTypeId == PreviewUtil.PETS)
				{
					SdgAlertChrome.show("You have already adopted this pet. This pet is waiting for you in your Home Turf.", "Time out!");
				}
				else
				{
					SdgAlertChrome.show("You already own this item, go to your " + location + " to use it.", "Time out!");
				}
				
				// Callback
				if (onAlreadyOwned != null) onAlreadyOwned(e);
			}
		}
		
	}
}