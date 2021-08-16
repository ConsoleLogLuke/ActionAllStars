package com.sdg.events
{
	import flash.events.Event;

	public class TaskEvent extends Event
	{
		public static const START:String = 'start';
		public static const COMPLETE:String = 'complete';
		public static const INTERRUPT:String = 'interrupt';
		
		public function TaskEvent(type:String)
		{
			super(type);
		}
	}
}