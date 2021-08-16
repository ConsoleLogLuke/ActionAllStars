package com.sdg.store.list
{
	import flash.events.Event;

	public class StoreItemListEvent extends Event
	{
		public static const NEW_BACKGROUND_URL:String = 'new background url';
		public static const NEW_WINDOW_BACKGROUND_URL:String = 'new window background url';
		public static const NEW_ITEM_SET_NAME:String = 'new item set name';
		public static const NEW_ITEM_SET_IMAGE_URL:String = 'new item set image url';
		public static const REMOVED_DETAIL_VIEW:String = 'removed detail view';
		public static const UPDATED_USER_TOKENS:String = 'updated user tokens';
		public static const UPDATED_USER_LEVEL:String = 'updated user level';
		
		public function StoreItemListEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}