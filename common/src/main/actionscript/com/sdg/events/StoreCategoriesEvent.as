package com.sdg.events
{
	import com.adobe.cairngorm.control.CairngormEvent;

	public class StoreCategoriesEvent extends CairngormEvent
	{
		public static const STORE_CATEGORIES:String = "storeCategories";
		public static const COMPLETE:String = 'store categories complete';
		
		private var _parentCategoryId:int;
		private var _storeId:int;
		
		public function StoreCategoriesEvent(parentCategoryId:int, storeId:int = -1, type:String = STORE_CATEGORIES)
		{
			_parentCategoryId = parentCategoryId;
			_storeId = storeId;
						
			super(type);
		}
		
		public function get parentCategoryId():int
		{
			return _parentCategoryId;
		}
		
		public function get storeId():int
		{
			return _storeId;
		}
	}
}