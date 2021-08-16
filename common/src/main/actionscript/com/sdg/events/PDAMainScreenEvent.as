package com.sdg.events
{
	import flash.events.Event;

	public class PDAMainScreenEvent extends Event
	{
		public static const MAIN_PANEL_CHANGE:String = 'main panel change';
		
		public function PDAMainScreenEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}