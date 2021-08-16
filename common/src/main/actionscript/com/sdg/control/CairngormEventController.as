package com.sdg.control
{
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.adobe.cairngorm.control.CairngormEventDispatcher;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	public class CairngormEventController extends EventDispatcher
	{
		override public function dispatchEvent(event:Event):Boolean
		{
			if (event is CairngormEvent)
		 	{
		  		return CairngormEventDispatcher.getInstance().dispatchEvent(event as CairngormEvent);
		  	}
			else
			{
				return super.dispatchEvent(event);
			}
		}
	}
}