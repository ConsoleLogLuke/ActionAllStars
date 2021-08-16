package com.sdg.events
{
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.sdg.components.controls.TurfItem;

	public class TurfItemDragEvent extends CairngormEvent
	{
		public static const ITEM_DRAG_ENTERED:String = "item drag entered";
		
		private var _item:TurfItem;
		
		public function TurfItemDragEvent(item:TurfItem)
		{
			super(ITEM_DRAG_ENTERED);
			_item = item;
		}
		
		// properties
		public function get turfItem():TurfItem
		{
			return _item;
		}
	}
}