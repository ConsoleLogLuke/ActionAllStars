package com.sdg.events
{
	import flash.events.Event;

	public class SelectedEvent extends Event
	{
		public static const SELECTED:String = 'select';
		
		private var _index:int;
		
		public function SelectedEvent(type:String, index:int = 0)
		{
			super(type);
			
			_index = index;
		}
		
		public function get index():int
		{
			return _index;
		}
	}
}