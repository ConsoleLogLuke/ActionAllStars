package com.sdg.events
{
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.sdg.model.Avatar;
	import com.sdg.model.StoreItem;

	public class ItemPurchaseEvent extends CairngormEvent
	{
		public static const ITEM_PURCHASE:String = "itemPurchase";
		public static const SUCCESS:String = "item purchase success";
		public static const ALREADY_OWNED:String = "item purchase fail";
		public static const INSUFFICIENT_TOKENS:String = "item purchase fail - tokens";
		
		private var _avatar:Avatar;
		private var _storeItem:StoreItem;
		
		private var _storeId:int;
		
		private var _userInventoryItems:Array;
		
		public function ItemPurchaseEvent(avatar:Avatar, storeItem:StoreItem, storeId:int,type:String = ITEM_PURCHASE,  userInventoryItems:Array = null)
		{
			super(type);
			_storeId=storeId;			
			_userInventoryItems=userInventoryItems;
			_avatar = avatar;
			_storeItem = storeItem;
		}
		
		public function get userInventoryItems():Array{
			return _userInventoryItems;
		}
		
	
		public function get storeItem():StoreItem
		{
			return _storeItem;
		}
		
		public function get avatar():Avatar
		{
			return _avatar;
		}		
		
		public function get storeId():int
		{
			return _storeId;
		}
		
	}
}