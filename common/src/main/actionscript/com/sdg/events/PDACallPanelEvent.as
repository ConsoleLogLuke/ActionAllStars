package com.sdg.events
{
	import flash.events.Event;

	public class PDACallPanelEvent extends Event
	{
		public static const ANSWER_CLICK:String = 'answer click';
		
		public function PDACallPanelEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}