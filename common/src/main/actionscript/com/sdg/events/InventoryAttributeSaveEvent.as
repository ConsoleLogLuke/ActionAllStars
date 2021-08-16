package com.sdg.events
{
	import com.adobe.cairngorm.control.CairngormEvent;

	public class InventoryAttributeSaveEvent extends CairngormEvent
	{
		public static const INVENTORY_ATTRIBUTE_SAVE:String = "InventoryAttributeSave";
		
		private var _avatarId:int;
		private var _userIventoryId:int;
		private var _inventoryAttributeNameId:int;
		private var _inventoryAttributeValue:String;
		private var _cost:int;
		
		public function InventoryAttributeSaveEvent(avatarId:int, userIventoryId:int, inventoryAttributeNameId:int, inventoryAttributeValue:String, cost:int = 0)
		{
			super(INVENTORY_ATTRIBUTE_SAVE);
			
			_avatarId = avatarId;
			_userIventoryId = userIventoryId;
			_inventoryAttributeNameId = inventoryAttributeNameId;
			_inventoryAttributeValue = inventoryAttributeValue;
			_cost = cost;
		}
		
		public function get avatarId():int
		{
			return _avatarId;
		}		
		
		public function get userIventoryId():int
		{
			return _userIventoryId;
		}		
		
		public function get inventoryAttributeNameId():int
		{
			return _inventoryAttributeNameId;
		}
		
		public function get inventoryAttributeValue():String
		{
			return _inventoryAttributeValue;
		}
		
		public function get cost():int
		{
			return _cost;	
		}
	}
}