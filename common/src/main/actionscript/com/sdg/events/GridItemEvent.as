package com.sdg.events
{
	import flash.display.DisplayObject;
	import flash.events.Event;

	public class GridItemEvent extends Event
	{
		public static const INTO_VISIBILITY:String = 'grid item into visibility';
		public static const OUT_OF_VISIBILITY:String = 'grid item into visibility';
		
		protected var _display:DisplayObject;
		
		public function GridItemEvent(type:String, display:DisplayObject, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			_display = display;
		}
		
		public function get display():DisplayObject
		{
			return _display;
		}
		
	}
}