package com.sdg.store.preview
{
	import flash.events.Event;

	public class StoreAvatarPreviewEvent extends Event
	{
		public static const NEW_AVATAR:String = 'new avatar';
		public static const NEW_APPAREL_ITEM:String = 'new apparel item';
		public static const NEW_BACKGROUND_URL:String = 'new background url';
		public static const ADD_TOKENS_CLICK:String = 'add tokens click';
		public static const TOKENS_DELIVERED:String = 'tokens delivered';
		
		public function StoreAvatarPreviewEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}