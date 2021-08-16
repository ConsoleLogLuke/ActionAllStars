package com.sdg.control.room.itemClasses
{
	import com.sdg.events.RoomNavigateEvent;
	import com.sdg.model.SdgItem;
	
	import flash.events.MouseEvent;
	
	public class ExitPoint extends RoomItemController
	{
		public function ExitPoint()
		{
		}
		
		override protected function mouseClickHandler(event:MouseEvent):void
		{
			super.mouseClickHandler(event);
			dispatchEvent(new RoomNavigateEvent(RoomNavigateEvent.ENTER_ROOM, item.attributes.destination));			
		}
	}
}