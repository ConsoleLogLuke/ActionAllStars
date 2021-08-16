package com.sdg.event
{
	import flash.events.Event;

	public class UIDialogueEvent extends Event
	{
		public static const OK:String = 'ok dialog event';
		public static const CANCEL:String = 'cancel dialog event';
		public static const CLOSE:String = 'close dialog event';
		
		public function UIDialogueEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}