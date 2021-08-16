package com.sdg.events
{
	import com.sdg.control.room.itemClasses.IRoomItemController;
	
	import flash.events.Event;

	public class RoomItemEvent extends Event
	{
		public static const MOVE:String = 'move';
		public static const REMOVED:String = 'removed';
		public static const ADDED:String = 'added';
		
		private var _roomItemController:IRoomItemController;
		
		public function RoomItemEvent(type:String, roomItemController:IRoomItemController, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			_roomItemController = roomItemController;
			
			super(type, bubbles, cancelable);
		}
		
		public function get roomItemController():IRoomItemController
		{
			return _roomItemController;
		}
		
	}
}