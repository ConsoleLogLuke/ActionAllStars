package com.sdg.events
{
	import flash.events.Event;

	public class GlobalEvent extends Event
	{
		public static const INITIALIZE:String = 'initialize';
		public static const FRAME_RATE_CHANGE:String = 'frameRateChange';
		
		public function GlobalEvent(type:String)
		{
			super(type);
		}
		
		override public function toString():String
		{
			return "[GlobalEvent type=" + type + "]";
		}
	}
}