package com.sdg.store.list
{
	import flash.events.Event;

	public class StoreItemListSortEvent extends Event
	{
		public static const SORT_SELECT:String = 'store item list sort select';
		
		protected var _sortName:String;
		
		public function StoreItemListSortEvent(type:String, sortName:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			_sortName = sortName;
		}
		
		public function get sortName():String
		{
			return _sortName;
		}
		
	}
}