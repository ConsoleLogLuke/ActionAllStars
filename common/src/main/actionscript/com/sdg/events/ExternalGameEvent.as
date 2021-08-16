package com.sdg.events
{
	import flash.events.Event;

	public class ExternalGameEvent extends Event
	{
		public static const LOAD_GAME:String = 'load game';
		
		public function ExternalGameEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}