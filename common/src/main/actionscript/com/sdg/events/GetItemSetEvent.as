package com.sdg.events
{
	import com.adobe.cairngorm.control.CairngormEvent;

	public class GetItemSetEvent extends CairngormEvent
	{
		public static const GET_ITEM_SETS:String = "getItemSets";
		
		public function GetItemSetEvent()
		{
			super(GET_ITEM_SETS);
		}
	}
}