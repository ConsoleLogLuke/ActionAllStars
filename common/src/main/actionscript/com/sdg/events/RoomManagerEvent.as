package com.sdg.events
{
	import flash.events.Event;

	public class RoomManagerEvent extends Event
	{
		public static const ENTER_ROOM_INIT:String = 'enterRoomInit';
		public static const ENTER_ROOM_START:String = 'enterRoomStart';
		public static const ENTER_ROOM_COMPLETE:String = 'enterRoomComplete';
		public static const ENTER_ROOM_ERROR:String = 'enterRoomError';
		public static const LEAVE_ROOM:String = 'leaveRoom';
		public static const REQUEST_FOR_WORLD_MAP:String = 'request for world map';

		public function RoomManagerEvent(type:String)
		{
			super(type);
		}
		
		override public function clone():Event
		{
			return new RoomManagerEvent(type);
		}
	}
}