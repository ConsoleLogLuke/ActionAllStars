package com.sdg.store.transaction
{
	import com.adobe.cairngorm.control.CairngormEventDispatcher;
	import com.sdg.events.ItemPurchaseEvent;
	import com.sdg.events.RoomCheckEvent;
	import com.sdg.model.ModelLocator;
	import com.sdg.model.StoreCategory;
	import com.sdg.model.StoreItem;
	import com.sdg.store.StoreConstants;
	
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	public class FreeItemAtom
	{
		private static var idArray:Object = new Object();
		private var _itemId:uint;
		private var _itemCheckId:uint;
		private var _limit:Boolean;
		private var _transactionTimer:Timer;
		
		public function FreeItemAtom(itemId:uint,itemCheckId:uint,limit:Boolean = true)
		{
			//super();
			
			_itemId = itemId;
			_itemCheckId = itemCheckId;
			_limit = limit;
			
			// Check Existing Item Ids
			if (idArray[_itemId])
			{
				return;
			}
			
			// Register Item Id
			idArray[itemId] = true;
			
			// Set Up Timer
			_transactionTimer = new Timer(10000,0);
			_transactionTimer.addEventListener(TimerEvent.TIMER,onTimerComplete);
			
			// Set up Store Listeners
			CairngormEventDispatcher.getInstance().addEventListener(ItemPurchaseEvent.SUCCESS, onPurchaseEvent);
			CairngormEventDispatcher.getInstance().addEventListener(ItemPurchaseEvent.ALREADY_OWNED, onPurchaseEvent);
			
			// Execute Transaction
			giveItem();
			
			// Start Timer
			_transactionTimer.start();
		}
		
		protected function giveItem():void
		{
			if (_limit)
			{
				// Check First Item
				CairngormEventDispatcher.getInstance().addEventListener(RoomCheckEvent.ROOM_CHECKED, onCheckCompleted);
				CairngormEventDispatcher.getInstance().dispatchEvent(new RoomCheckEvent(ModelLocator.getInstance().avatar.avatarId, 0, RoomCheckEvent.CHECK_ROOM, 0, 0, _itemCheckId));
			}
			else
			{
				sendPurchaseEvent();
			}

			function onCheckCompleted(e:RoomCheckEvent):void
			{
				CairngormEventDispatcher.getInstance().removeEventListener(RoomCheckEvent.ROOM_CHECKED, onCheckCompleted);
				
				var hasItem:Boolean = false;
				switch (e.status)
				{
					case 1:
						// Has Item
						hasItem = true;
						break;
					case 419:
						// No Item
						// Leave as False
						break;
					default:
						break;
				}
				
				if (!hasItem)
				{
					sendPurchaseEvent();
				}
				else
				{
					idArray[_itemId] = false;
					
					destroy();
				}
			}
			
			function sendPurchaseEvent():void
			{
				// Send Purchase Event
				var gameItem:StoreItem = new StoreItem(_itemId, null, null, 0, 0,	0, false, 0, null, null, new StoreCategory("", 0, StoreConstants.STORE_ID_GAMEVENDOR, 0,"",0), 0, 0, 0, 0, 0, 0);
				CairngormEventDispatcher.getInstance().dispatchEvent(new ItemPurchaseEvent(ModelLocator.getInstance().avatar, gameItem, StoreConstants.STORE_ID_GAMEVENDOR));
			}	
		}
		
		protected function destroy():void
		{
			// kill timer
			_transactionTimer.stop();
			_transactionTimer.removeEventListener(TimerEvent.TIMER,onTimerComplete);
			_transactionTimer = null;
			
			//Remove all event listeners
			CairngormEventDispatcher.getInstance().removeEventListener(ItemPurchaseEvent.SUCCESS, onPurchaseEvent);
			CairngormEventDispatcher.getInstance().removeEventListener(ItemPurchaseEvent.ALREADY_OWNED, onPurchaseEvent);
		}
		
		/////////////////////////
		// EVENTY LISTENER
		/////////////////////////
		
		protected function onTimerComplete(e:TimerEvent):void
		{
			// Remove Listeners
			_transactionTimer.removeEventListener(TimerEvent.TIMER,onTimerComplete);
			
			idArray[_itemId] = false;
			
			destroy();
		}
		
		protected function onPurchaseEvent(e:ItemPurchaseEvent):void
		{
			// Check to see if a related event
			if (_itemId != e.storeItem.itemId)
				return;
				
			idArray[_itemId] = false;
				
			destroy();
		}
		
	}
}