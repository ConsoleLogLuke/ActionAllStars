package com.sdg.model
{
	import flash.events.EventDispatcher;
	
	[Bindable]
	public class InventoryItemType extends EventDispatcher
	{
		private var _itemTypeId:uint;
		private var _name:String;
		private var _itemClassId:uint;
		private var _numItems:int;
		
		public function InventoryItemType(itemTypeId:uint, name:String, itemClassId:uint)
		{
			_itemTypeId = itemTypeId;
			_name = name;
			_itemClassId = itemClassId;
		}
		
		// properties
		
		public function set itemTypeId(value:uint):void
		{
			_itemTypeId = value;
		}
		
		public function get itemTypeId():uint
		{
			return _itemTypeId;
		}

		public function get name():String
		{
			return _name;
		}

		public function get itemClassId():uint
		{
			return _itemClassId;
		}
		
		public function set numItems(value:int):void
		{
			_numItems = value;
		}
		
		public function get numItems():int
		{
			return _numItems;
		}
	}
}