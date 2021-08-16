package com.sdg.control.room.itemClasses
{
	import com.sdg.display.RoomItemSWF;
	import com.sdg.events.SdgSwfEvent;
	import com.sdg.model.Avatar;
	import com.sdg.model.ModelLocator;
	import com.sdg.model.SdgItem;
	import com.sdg.swf.SWFContainer;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class InteractiveDoodad extends RoomItemController
	{
		
		protected var _clientAvatar:Avatar;
		
		public function InteractiveDoodad()
		{
			super();
		}
		
		////////////////////
		// INSTANCE METHODS
		////////////////////
		
		
		
		////////////////////
		// EVENT HANDLERS
		////////////////////
		
		override protected function mouseClickHandler(event:MouseEvent):void
		{
			trace('You clicked an InteractiveDoodad.');
		}
		
	}
}