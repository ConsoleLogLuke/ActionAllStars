package com.sdg.events.room
{
	import com.sdg.control.room.RoomController;
	
	import flash.events.Event;

	public class RoomEvent extends Event
	{
		public static const ROOM_CHANGED:String = 'room changed';
		
		private var _roomController:RoomController;
		
		public function RoomEvent(type:String, roomController:RoomController, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			_roomController = roomController;
			
			super(type, bubbles, cancelable);
		}
		
	}
}