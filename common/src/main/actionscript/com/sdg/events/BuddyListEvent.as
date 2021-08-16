package com.sdg.events
{
	import com.adobe.cairngorm.control.CairngormEvent;

	public class BuddyListEvent extends CairngormEvent
	{
		public static const BUDDYLIST:String = "buddyList";
		
		public function BuddyListEvent()
		{
			super(BUDDYLIST);
		}
		
		// properties
	}
}