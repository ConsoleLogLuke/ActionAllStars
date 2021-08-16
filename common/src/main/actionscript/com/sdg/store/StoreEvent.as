package com.sdg.store
{
	import flash.events.Event;

	public class StoreEvent extends Event
	{
		public static const ITEMS_UPDATE:String = 'store items update';
		public static const ITEM_QUANTITY_UPDATE:String = 'store items quantity update';
		public static const CLOSE_STORE:String = 'store close';
		public static const CLOSE_CLICK:String = 'store close click';
		
		public function StoreEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}