package com.sdg.events
{
	import com.adobe.cairngorm.control.CairngormEvent;

	public class PartyListEvent extends CairngormEvent
	{
		public static const PARTY_LIST:String = "partyList";
		
		public function PartyListEvent()
		{
			super(PARTY_LIST);
		}
		
		// properties
	}
}