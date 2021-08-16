package com.sdg.events
{
	import com.adobe.cairngorm.control.CairngormEvent;

	public class GetJabsEvent extends CairngormEvent
	{
		public static const GET_JABS:String = "getJabs";
		
		public function GetJabsEvent()
		{
			super(GET_JABS);
		}
	}
}