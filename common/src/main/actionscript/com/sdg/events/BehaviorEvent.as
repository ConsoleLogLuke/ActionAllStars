package com.sdg.events
{
	import flash.events.Event;

	public class BehaviorEvent extends Event
	{
		public static const COMPLETE:String = 'complete';
		public static const INTERRUPT:String = 'interrupt';
		
		public function BehaviorEvent(type:String)
		{
			super(type);
		}
	}
}