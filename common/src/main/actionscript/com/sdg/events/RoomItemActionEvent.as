package com.sdg.events
{
	import com.sdg.model.SdgItem;
	import flash.events.Event;

	public class RoomItemActionEvent extends Event
	{
		public static const ROOM_ITEM_ACTION:String = 'roomItemAction';
		
		public var item:SdgItem;
		public var action:String;
		public var params:Object;
		public var consequence:Object;
		
		public function RoomItemActionEvent(type:String, item:SdgItem, action:String, params:Object = null, consequence:Object = null)
		{
			super(type);
			this.item = item;
			this.action = action;
			this.params = params;
			this.consequence = consequence;
		}
		
		override public function clone():Event
		{
			return new RoomItemActionEvent(type, item, action, params, consequence);
		}
	}
}