package com.sdg.components.events
{
	import flash.events.Event;

	public class InteractiveGridEvent extends Event
	{
		public static const TILE_CLICK:String = 'tileClick';
		public static const TILE_DOWN:String = 'tileDown';
		public static const TILE_HOVER:String = 'tileHover';
		public static const TILE_UP:String = 'tileUp';
		
		public var columnIndex:int;
		public var rowIndex:int;
		public var buttonDown:Boolean;
		
		public function InteractiveGridEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false,
								  columnIndex:int = -1, rowIndex:int = -1, buttonDown:Boolean = false)
		{
			super(type, bubbles, cancelable);
			
			this.columnIndex = columnIndex;
	        this.rowIndex = rowIndex;
			this.buttonDown = buttonDown;
		}
		
		override public function clone():Event
	    {
	        return new InteractiveGridEvent(type, bubbles, cancelable,
	        					 columnIndex, rowIndex, buttonDown);
	    }
	}
}