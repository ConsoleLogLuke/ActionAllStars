package com.sdg.printshop
{
	import flash.events.Event;

	public class PrintShopEvent extends Event
	{
		public static const CLOSE_SHOP:String = 'shop close';
		public static const CLOSE_CLICK:String = 'shop close click';
		public static const PREVIEW_COMPLETE:String = 'print preview complete';
		public static const PAGE_COMPLETE:String = 'print page complete';
		
		public function PrintShopEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}