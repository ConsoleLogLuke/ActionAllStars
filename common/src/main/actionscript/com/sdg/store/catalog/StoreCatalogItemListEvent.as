package com.sdg.store.catalog
{
	import flash.events.Event;

	public class StoreCatalogItemListEvent extends Event
	{
//		public static const FILTER_ALL_TIME_CLICK:String = 'filter all time click';
		public static const FILTER_WEEK_CLICK:String = 'filter week click';
		
		public static const FILTER_MONTH_CLICK:String = 'filter month click';
		
		public function StoreCatalogItemListEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}