package com.sdg.messageBoard.events
{
	import flash.events.Event;

	public class TurfMessageEvent extends Event
	{
		public static var BG_ID_CHANGE:String = "bg id change";
		public static var STICKER_ID_CHANGE:String = "sticker id change";
		
		public function TurfMessageEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}