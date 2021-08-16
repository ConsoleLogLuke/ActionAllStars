package com.sdg.store.catalog
{
	import flash.events.Event;

	public class StoreCatalogEvent extends Event
	{
		public static const CLOSE_CLICK:String = 'store catalog close click';
		
		public function StoreCatalogEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}