package com.sdg.store.catalog
{
	import flash.events.Event;

	public class StoreCatalogStoreSelectEvent extends Event
	{
		public static const STORE_SELECT:String = 'store catalog store select';
		
		protected var _storeId:uint;
		
		public function StoreCatalogStoreSelectEvent(type:String, storeId:uint, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			_storeId = storeId;
		}
		
		public function get storeId():uint
		{
			return _storeId;
		}
		
	}
}