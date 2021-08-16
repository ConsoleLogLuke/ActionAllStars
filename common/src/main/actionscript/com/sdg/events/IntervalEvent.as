package com.sdg.events
{
	import flash.events.Event;

	public class IntervalEvent extends Event
	{
		public static const INTERVAL:String = 'interval';
		
		public var elapsed:uint;
		
		public function IntervalEvent(type:String, elapsed:uint)
		{
			super(type);
			
			this.elapsed = elapsed;
		}
		
		override public function clone():Event
		{
			return new IntervalEvent(type, elapsed);
		}
		
		override public function toString():String
		{
			return "[IntervalEvent elapsed=" + elapsed + "]";
		}
	}
}