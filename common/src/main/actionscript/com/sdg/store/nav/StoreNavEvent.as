package com.sdg.store.nav
{
	import flash.events.Event;

	public class StoreNavEvent extends Event
	{
		public static const CATEGORY_SELECT:String = 'store category select';
		public static const SUB_CATEGORY_SELECT:String = 'store sub-category select';
		public static const NAV_UPDATE:String = 'store navigation updated';
		public static const STORE_UPDATE:String = 'store update';
		public static const NAV_RESET:String = 'navigation reset';
		public static const NEW_BORDER_URL:String = 'new navigation border url';
		public static const ROLL_OVER:String = 'item roll over';
		public static const ROLL_OUT:String = 'item roll out';
		
		protected var _categoryId:int;
		protected var _tier:uint;
		protected var _team:String;
		
		public function StoreNavEvent(type:String, categoryId:int = 0, tier:uint = 1, team:String="",bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			_categoryId = categoryId;
			_tier = tier;
			_team = team;
		}
		
		public function get categoryId():int
		{
			return _categoryId;
		}
		
		public function get tier():uint
		{
			return _tier;
		}
		
		public function get team():String
		{
			return _team;
		}
		
	}
}