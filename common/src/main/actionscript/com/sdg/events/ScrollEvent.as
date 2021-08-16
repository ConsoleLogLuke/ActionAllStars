package com.sdg.events
{
	import flash.events.Event;

	public class ScrollEvent extends Event
	{
		public static const SCROLL:String = 'scroll event';
		
		public var scrollPosition:Number;
		
		public function ScrollEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}