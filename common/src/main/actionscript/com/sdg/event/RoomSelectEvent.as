package com.sdg.event
{
	import com.sdg.model.RoomInfo;
	
	import flash.events.Event;

	public class RoomSelectEvent extends Event
	{
		public static const SELECT:String = 'room select';
		
		public var roomInfo:RoomInfo;
		
		public function RoomSelectEvent(type:String, roomInfo:RoomInfo, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			this.roomInfo = roomInfo;
		}
		
	}
}