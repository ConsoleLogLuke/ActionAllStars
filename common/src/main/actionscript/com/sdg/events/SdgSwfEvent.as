package com.sdg.events
{
	import flash.events.Event;

	public class SdgSwfEvent extends Event
	{
		public static const SDG_SWF_EVENT:String = 'sdg swf event';
		public static const SDG_SWF_ACTION:String = 'sdg swf action';
		public static const INIT_CONTROLLER:String = 'init controller';
		public static const SDG_SWF_BACKGROUND_ITEM:String = 'background item';
		public var data:Object = new Object();
		
		public function SdgSwfEvent(type:String = SDG_SWF_EVENT, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable)
		}
	}
}