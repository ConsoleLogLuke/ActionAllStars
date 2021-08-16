package com.sdg.events
{
	import com.adobe.cairngorm.control.CairngormEvent;

	public class GetEmotesEvent extends CairngormEvent
	{
		public static const GET_EMOTES:String = "getEmotes";
		
		public function GetEmotesEvent()
		{
			super(GET_EMOTES);
		}
	}
}