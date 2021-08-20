package com.sdg.control.room.itemClasses
{
	import com.adobe.cairngorm.control.CairngormEventDispatcher;
	import com.sdg.components.dialog.EmoteDialog;
	import com.sdg.components.dialog.SaveYourGameDialog;
	import com.sdg.components.dialog.ShoeChargingBubble;
	import com.sdg.display.RoomItemSWF;
	import com.sdg.events.InventoryListEvent;
	import com.sdg.events.ItemPurchaseEvent;
	import com.sdg.events.RoomItemDisplayEvent;
	import com.sdg.model.Avatar;
	import com.sdg.model.InventoryItem;
	import com.sdg.model.ModelLocator;
	import com.sdg.model.StoreCategory;
	import com.sdg.model.StoreItem;
	import com.sdg.utils.MainUtil;
	import com.sdg.utils.PreviewUtil;
	import com.sdg.store.StoreConstants;

	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;

	/**
	 * The controller for food vendor room items like the hotdog cart, etc
	 */
	public class FoodVender extends RoomItemController
	{
		private const HOTDOG_CART_VENDOR_ID:int = 589;
		private const GAME_CART_VENDOR:int = 604;
		private const SHOE_CHARGING_VENDOR_ID:int = 609;

		private var _foodVendorDisplay:MovieClip;

		public function FoodVender()
		{
			super();
		}

		protected function showHotdogCartDialog(event:Event):void
		{
			// set up our parameters to the dialog
			var params:Object = new Object();
			params.button = _foodVendorDisplay;
			params.columns = 3;
			params.vendorId = HOTDOG_CART_VENDOR_ID;
			params.bubbleBorderColor = 0x9F9F9F;
			params.bubbleBackgroundColor = 0xECECEC;
			params.text = "What would you like to order?";
			params.closeOnEmoting = true;
			params.showEmoteBubble = false;

			// show the dialog
			var dialog:EmoteDialog = MainUtil.showDialog(EmoteDialog, params, false, false) as EmoteDialog;
			dialog.addEventListener(Event.CLOSE, onEmoteDialogClose);
			var swf:Object = RoomItemSWF(display).content;
			swf.isOrdering = true;
		}

		protected function showShoeChargingDialog(event:Event):void
		{
			var params:Object = new Object();
			params.button = _foodVendorDisplay;

			// get the avatar's shoes
			var avatar:Avatar = ModelLocator.getInstance().avatar;
			var shoes:InventoryItem = avatar.apparel[PreviewUtil.getLayerId(PreviewUtil.SHOES)] as InventoryItem;
			if (!shoes)
			{
				trace("showShoeChargingDialog: user has no shoes!");
				return;
			}

			if (shoes.walkSpeedPercent < 0 || !shoes.cooldownSeconds)
			{
				params.text = "You must be wearing speed shoes in order to re-charge them here.";
				params.bubbleHeight = 88;
			}
			else if (shoes.charges == 20)
			{
				params.text = "Your shoes are fully charged. Come back when you are low on charges.";
				params.bubbleHeight = 100;
			}
			else
			{
				// calculate the number of charges needed
				var chargesNeeded:int = 20 - shoes.charges;
				const costPerCharge:int = 25;
				var cost:int = chargesNeeded * costPerCharge;

				// make sure we have enough tokens
				if (avatar.currency < cost)
				{
					params.text = "You need at least " + cost + " tokens to refill your charges";
					params.bubbleHeight = 88;
				}
				else
				{
					var chargesStr:String = chargesNeeded == 1 ? "charge" : "charges";
					params.text = "You need " + chargesNeeded + " " + chargesStr + " to repair your shoes.  Fix'em up for " + cost + " tokens";
					params.buttonsType = ShoeChargingBubble.BUTTONS_OK_CANCEL;
					params.bubbleHeight = 125;
				}
			}

			// show the dialog
			MainUtil.showDialog(ShoeChargingBubble, params, false, false);
		}

		protected function showGameCartDialog():void
		{
			// promo message
//			var params:Object = new Object();
//			params.button = _foodVendorDisplay;
//			params.swfPath = "swfs/gameVendorMessage3.swf";
//			MainUtil.showDialog(ShoeChargingBubble, params, false, false);

			// see if we already have the game
			CairngormEventDispatcher.getInstance().addEventListener(InventoryListEvent.LIST_COMPLETED, onGameInventoryListCompleted);
			dispatchEvent(new InventoryListEvent(ModelLocator.getInstance().avatar.avatarId, PreviewUtil.BOARD_GAME));
		}

		override protected function itemResourcesCompleteHandler(event:Event):void
		{
			super.itemResourcesCompleteHandler(event);
			RoomItemSWF(display).addEventListener(RoomItemDisplayEvent.CONTENT, loadCompleteHandler);
		}

		protected function loadCompleteHandler(event:Event):void
		{
			if (display == null) return;

			var swf:RoomItemSWF = RoomItemSWF(display);
			var temp:Object = Object(swf.content);
			var hotDogCart:MovieClip = temp.hotDogCart as MovieClip;
			if (hotDogCart)
			{
				_foodVendorDisplay = hotDogCart;
				_foodVendorDisplay.addEventListener(MouseEvent.CLICK, showHotdogCartDialog);
			}

			var chargeStation:MovieClip = temp.chargeStationHitspot as MovieClip;
			if (chargeStation)
			{
				_foodVendorDisplay = chargeStation;
				_foodVendorDisplay.addEventListener(MouseEvent.CLICK, showShoeChargingDialog);
			}

			var gameCart:MovieClip = temp.gameCart as MovieClip;
			if (gameCart)
			{
				_foodVendorDisplay = gameCart;
				_foodVendorDisplay.addEventListener(MouseEvent.CLICK, onCartClick);
			}

			function onCartClick(event:MouseEvent):void
			{
				if (ModelLocator.getInstance().avatar.membershipStatus == 3)
					MainUtil.showDialog(SaveYourGameDialog);
				else
					showGameCartDialog();
			}
		}

		protected function onEmoteDialogClose(event:Event):void
		{
			event.currentTarget.removeEventListener(Event.CLOSE, onEmoteDialogClose);
			var swf:Object = RoomItemSWF(display).content;
			if (swf.hasOwnProperty("isOrdering"))
				swf.isOrdering = false;
		}

		private function onGameInventoryListCompleted(ev:InventoryListEvent):void
        {
			CairngormEventDispatcher.getInstance().removeEventListener(InventoryListEvent.LIST_COMPLETED, onGameInventoryListCompleted);

        	var hasConcentration:Boolean = false;
       		for each (var item:InventoryItem in ModelLocator.getInstance().avatar.getInventoryListById(ev.itemTypeId))
       		{
       			if (item.itemId == 4242)
       				hasConcentration = true;
       		}

			var params:Object = new Object();
			params.button = _foodVendorDisplay;
			params.swfPath = "swfs/gameVendorMessage1.swf";

       		// if we don't have concentration yet, just give it away
       		if (!hasConcentration)
       		{
				// purchase the 'giveaway' item for zero tokens
				var gameItem:StoreItem = new StoreItem(4242, null,	null, 0, 0,	0, false, 0, null, null, new StoreCategory("", 0, StoreConstants.STORE_ID_GAMEVENDOR, 0,"",0), 0, 0, 0, 0, 0, 0);
				dispatchEvent(new ItemPurchaseEvent(ModelLocator.getInstance().avatar, gameItem, StoreConstants.STORE_ID_GAMEVENDOR));
       		}
       		else
				params.swfPath = "swfs/gameVendorMessage2.swf";

			// speak to the user
			MainUtil.showDialog(ShoeChargingBubble, params, false, false);
        }
	}
}
