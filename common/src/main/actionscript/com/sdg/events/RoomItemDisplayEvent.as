package com.sdg.events
{
	import com.sdg.display.IRoomItemDisplay;
	
	import flash.events.Event;

	public class RoomItemDisplayEvent extends Event
	{
		public static const CONTENT:String = 'new content';
		public static const MOUSE_OVER_ITEM:String = 'mouse over item';
		public static const MOUSE_OUT_ITEM:String = 'mouse out item';
		public static const MOUSE_DOWN_ITEM:String = 'mouse down item';
		public static const MOUSE_CLICK_ITEM:String = 'mouse click item';
		public static const ROLL_OVER_ITEM:String = 'roll over item';
		public static const ROLL_OUT_ITEM:String = 'roll out item';
		public static const MOVE:String = 'move item';
		
		private var _display:IRoomItemDisplay;
		
		public function RoomItemDisplayEvent(type:String, display:IRoomItemDisplay, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			_display = display;
			
			super(type, bubbles, cancelable);
		}
		
		public function get display():IRoomItemDisplay
		{
			return _display;
		}
		
	}
}