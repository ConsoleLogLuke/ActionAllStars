package com.sdg.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.adobe.cairngorm.control.CairngormEventDispatcher;
	import com.sdg.business.SdgServiceDelegate;
	import com.sdg.components.controls.ProgressAlertChrome;
	import com.sdg.components.controls.SdgAlertChrome;
	import com.sdg.events.ItemPurchaseEvent;
	import com.sdg.factory.SdgItemFactory;
	import com.sdg.model.Avatar;
	import com.sdg.model.InventoryItem;
	import com.sdg.model.ModelLocator;
	import com.sdg.model.StoreItem;
	import com.sdg.utils.ErrorCodeUtil;
	
	import mx.rpc.IResponder;
	
	public class ItemPurchaseCommand implements ICommand, IResponder
	{
		private var _progressDialog:ProgressAlertChrome;
		private var _avatar:Avatar;
		private var _item:StoreItem;
		private var _storeId:int;
		public function execute(event:CairngormEvent):void
		{
			var ev:ItemPurchaseEvent = event as ItemPurchaseEvent;
			
			_avatar = ev.avatar;
			_item = ev.storeItem;
			_storeId=ev.storeId;
			
			if (ev.storeItem.price > 0)
				_progressDialog = ProgressAlertChrome.show("In Progress.  Please wait", "Purchasing Item", null, null, true);
				//_progressDialog = ProgressAlert.show("In Progress.  Please wait", "Purchasing Item", null, null, true);
				
			new SdgServiceDelegate(this).itemPurchase(ev.storeItem, ev.avatar.avatarId, ev.storeId);
		}
		
		public function result(data:Object):void
		{
			// Determine status.
			var status:int = (data.@status != null) ? data.@status : 0;
			var purchaseStatus:int = (data.@purchaseStatus != null) ? data.@purchaseStatus : 0;
			
			// Status of 1 indicates success.
			ModelLocator.getInstance().avatar.purchaseStatus = status;
			
			// close out progress dialog
			if (_progressDialog)
				_progressDialog.close();
				
			var inventoryItems:Array;
				
			// If the purchase was successful, dispatch an event.
			if (status == 1 && purchaseStatus == 1)
			{
				inventoryItems = getItems();
				CairngormEventDispatcher.getInstance().dispatchEvent(new ItemPurchaseEvent(_avatar, _item, _storeId, ItemPurchaseEvent.SUCCESS, inventoryItems));
			}
			else if (purchaseStatus == 501)
			{
				inventoryItems = getItems();
				CairngormEventDispatcher.getInstance().dispatchEvent(new ItemPurchaseEvent(_avatar, _item, _storeId, ItemPurchaseEvent.ALREADY_OWNED, inventoryItems));
			}
			else if (purchaseStatus == 500)
			{
				inventoryItems = getItems();
				CairngormEventDispatcher.getInstance().dispatchEvent(new ItemPurchaseEvent(_avatar, _item, _storeId, ItemPurchaseEvent.INSUFFICIENT_TOKENS, inventoryItems));
			}
			
			function getItems():Array
			{
				var items:Array = new Array();
				var factory:SdgItemFactory = new SdgItemFactory();
				for each (var inventoryItem:XML in data.i)
				{
					factory.setXML(inventoryItem);
					items.push(InventoryItem(factory.createInstance()));
				}
				
				return items;
			}
		}
		
		public function fault(info:Object):void
		{
			var myClass:Class = Object(this).constructor;
			var status:int = int(info.@status);
			
			SdgAlertChrome.show("Sorry, we were unable to complete your request. Error purchasing item.", "Time Out!", null, null, 
									true, true, 430, 200, ErrorCodeUtil.constructCode(myClass,status.toString()));
			
			// close out progress dialog
			if (_progressDialog)
	 			_progressDialog.close();
		}
	}
}