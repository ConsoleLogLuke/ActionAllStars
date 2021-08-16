package com.sdg.events
{
	import com.adobe.cairngorm.control.CairngormEvent;

	public class ShowOverlayEvent extends CairngormEvent
	{
		public static const OVERLAY:String = "overlay";
		
		public function ShowOverlayEvent()
		{
			super(OVERLAY);
		}
	}
}