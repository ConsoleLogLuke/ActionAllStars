package com.sdg.events
{
	import com.adobe.cairngorm.control.CairngormEvent;

	public class ItemTypeListEvent extends CairngormEvent
	{
		public static const ITEM_TYPE_LIST:String = "itemTypeList";
		
		private var _itemClassId:uint;
		
		public function ItemTypeListEvent(itemClassId:uint)
		{
			_itemClassId = itemClassId;
			super(ITEM_TYPE_LIST);
		}
		
		// properties
		
		public function get itemClassId():uint
		{
		   	return _itemClassId;	
		}
	}
}