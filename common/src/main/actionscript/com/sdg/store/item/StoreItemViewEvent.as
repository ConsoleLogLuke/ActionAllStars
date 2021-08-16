package com.sdg.store.item
{
	import com.sdg.model.StoreItem;
	
	import flash.events.Event;

	public class StoreItemViewEvent extends Event
	{
		public static const THUMBNAIL_CLICK:String = 'item thumbnail click';
		public static const THUMBNAIL_OVER:String = 'item thumbnail roll over';
		public static const THUMBNAIL_OUT:String = 'item thumbnail roll out';
		public static const THUMBNAIL_DOWN:String = 'item thumbnail mouse down';
		public static const THUMBNAIL_UP:String = 'item thumbnail mouse up';
		public static const MAGNIFY_CLICK:String = 'item magnify click';
		public static const BUY_CLICK:String = 'item buy click';
		
		public function StoreItemViewEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}