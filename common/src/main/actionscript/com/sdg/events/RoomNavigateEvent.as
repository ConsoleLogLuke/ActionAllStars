package com.sdg.events
{
	import com.adobe.cairngorm.control.CairngormEvent;

	public class RoomNavigateEvent extends CairngormEvent
	{
		public static const ENTER_ROOM:String = "enterRoom";
		public static const ENTER_PREV_ROOM:String = "enterPrevRoom";
		public static const EXIT_ROOM:String = "exitRoom";
		
		public var roomId:String;
		
		public function RoomNavigateEvent(type:String, roomId:String = null)
		{
			super(type);
			this.roomId = roomId;
		}
	}
}