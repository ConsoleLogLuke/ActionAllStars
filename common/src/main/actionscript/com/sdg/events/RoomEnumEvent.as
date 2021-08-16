package com.sdg.events
{
	import com.sdg.model.SdgItem;
	import flash.events.Event;

	public class RoomEnumEvent extends Event
	{
		public static const ENUM_REFRESH:String = 'enumRefresh';
		public static const ITEM_ADDED:String = 'itemAdded';
		public static const ITEM_REMOVED:String = 'itemRemoved';
		
		public var item:SdgItem;
		
		public function RoomEnumEvent(type:String, item:SdgItem = null)
		{
			super(type);
			this.item = item;
		}
		
		override public function clone():Event
		{
			return new RoomEnumEvent(type, item);
		}
	}
}