package com.sdg.events
{
	import flash.display.DisplayObject;
	import flash.events.Event;

	import mx.core.IUIComponent;
	
	public class RoomPopUpEvent extends Event
	{
		public static const ADD_POPUP:String = 'addPopUp';
		public static const REMOVE_POPUP:String = 'removePopUp';
		public static const CENTER_POPUP:String = 'centerPopUp';
		public static const ADD_QUED_POPUP:String = 'addQuedPopUp';
		public static const REMOVE_QUED_POPUP:String = 'removeQuedPopUp';
		
		public var popUp:DisplayObject;
		
		public function RoomPopUpEvent(type:String, popUp:DisplayObject, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
			this.popUp = popUp;
		}
		
		override public function clone():Event
		{
			return new RoomPopUpEvent(type, popUp, bubbles, cancelable);
		}
	}
}