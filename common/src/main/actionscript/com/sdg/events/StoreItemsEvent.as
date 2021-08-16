package com.sdg.events
{
	import com.adobe.cairngorm.control.CairngormEvent;

	public class StoreItemsEvent extends CairngormEvent
	{
		public static const STORE_ITEMS:String = "storeItems";
		public static const COMPLETE:String = 'store items complete';
		
		private var _storeId:uint;
		private var _parentCategoryId:uint;
		private var _avatarId:uint;
		
		public function StoreItemsEvent(storeId:uint, parentCategoryId:int, avatarId:uint, type:String = STORE_ITEMS)
		{
			_storeId = storeId;
			_parentCategoryId = parentCategoryId;
			_avatarId = avatarId;			
			super(type);
		}
		
		// properties
		
		public function get storeId():uint
		{
		   	return _storeId;	
		}
		
		public function get parentCategoryId():uint
		{
			return _parentCategoryId;
		}
		
		public function get avatarId():uint
		{
			return _avatarId;
		}
	}
}