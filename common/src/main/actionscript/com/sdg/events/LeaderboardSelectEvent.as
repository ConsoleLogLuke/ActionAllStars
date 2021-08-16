package com.sdg.events
{
	import flash.events.Event;

	public class LeaderboardSelectEvent extends Event
	{
		public static const SELECTED:String = 'selected';
		public var _index:uint;
		
		public function LeaderboardSelectEvent(type:String, index:uint, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			_index = index;
		}
		
	}
}