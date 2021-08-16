package com.sdg.store.item
{
	import com.sdg.model.StoreItem;
	
	import flash.events.Event;

	public class StoreItemEvent extends Event
	{
		public static const SELECT:String = 'item select';
		public static const DESELECT:String = 'item deselect';
		public static const MAGNIFY:String = 'item magnify';
		public static const BUY:String = 'item buy';
		public static const ROLL_OVER:String = 'item roll over';
		public static const ROLL_OUT:String = 'item roll out';
		public static const QUANTITY_UPDATE:String = 'quantity update';
		
		protected var _item:StoreItem;
		
		public function StoreItemEvent(type:String, item:StoreItem, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			_item = item;
		}
		
		public function get item():StoreItem
		{
			return _item;
		}
		
	}
}