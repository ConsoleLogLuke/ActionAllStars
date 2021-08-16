package com.sdg.components.controls
{
	import com.sdg.model.InventoryItem;
	
	[Bindable]
	public class TurfItem
	{
		private var _inventoryItemList:Array;
		private var _inventoryCount:int;
		private var _viewUpdateDisabled:Boolean;
		
		public var inventoryCountDisplay:int;
		
		private var _isFree:Boolean = false;
		public var isGreyedOut:Boolean = false;
		
		public function TurfItem()
		{
			_inventoryItemList = new Array();
		}
		
		public function getInventoryItemByIndex(index:int):InventoryItem
		{
			return _inventoryItemList[index];
		}
		
		public function getInventoryItem(inventoryItemId:int):InventoryItem
		{
			for each (var inventoryItem:InventoryItem in _inventoryItemList)
			{
				if (inventoryItem.inventoryItemId == inventoryItemId)
					return inventoryItem;
			}
			return null;
		}
		
		public function addInventoryItem(inventoryItem:InventoryItem):void
		{
			if (_isFree && inventoryItem.itemValueType == InventoryItem.PREMIUM) return;
			
			_inventoryItemList.push(inventoryItem);
			
			if (inventoryItem.roomId == 0)
				inventoryCount++;
		}
		
		public function get isFree():Boolean
		{
			return _isFree;
		}
		
		public function set isFree(value:Boolean):void
		{
			_isFree = value;
			
			if (value == true)
			{
				_inventoryItemList = new Array();
				inventoryCount = 0;
			}
		}
		
		public function get inventoryTotal():int
		{
			return _inventoryItemList.length;
		}
		
		public function set viewUpdateDisabled(value:Boolean):void
		{
			_viewUpdateDisabled = value;
			
			if (_viewUpdateDisabled == false)
				inventoryCountDisplay = _inventoryCount;
		}
		
		public function get layoutId():int
		{
			return _inventoryItemList[0].layoutId;
		}
		
		public function set inventoryCount(value:int):void
		{
			_inventoryCount = value;
			
			if (_viewUpdateDisabled == false)
				inventoryCountDisplay = value;
		}
		
		public function get inventoryCount():int
		{
			return _inventoryCount;
		}
		
		public function get itemName():String
		{
			var name:String;
			
			name = _inventoryItemList[0].name;
			
			return name;
		}
		
		public function get themeId():int
		{
			return _inventoryItemList[0].themeId;
		}
		
		public function get turfValue():int
		{
			return _inventoryItemList[0].turfValue;
		}
		
		public function get itemTypeId():uint
		{
			return _inventoryItemList[0].itemTypeId;
		}
		
		public function get thumbnailUrl():String
		{
			var url:String;
			
			url = _inventoryItemList[0].thumbnailUrl;
			
			return url;
		}
		
		public function get availableInventoryItem():InventoryItem
		{
			for each (var inventoryItem:InventoryItem in _inventoryItemList)
			{
				if (inventoryItem.roomId == 0)
					return inventoryItem;
			}
			
			return null;
		}
	}
}
