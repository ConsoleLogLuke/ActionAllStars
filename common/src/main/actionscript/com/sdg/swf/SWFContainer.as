package com.sdg.swf
{
	import com.sdg.display.SDGContainer;
	import com.sdg.events.SdgSwfEvent;
	
	import flash.events.EventDispatcher;
	
	public class SWFContainer extends SDGContainer
	{
		
		protected var _actionControl:EventDispatcher;
		
		public function SWFContainer()
		{
			super();
			
			// create a medium for dispatching actions
			_actionControl = new EventDispatcher();
		}
		
		public function receiveAction(name:String, params:Object = null):void
		{
			return;
		}
		
		protected function dispatchAction(params:Object):void
		{
			// dispatch a swf action event
			var ev:SdgSwfEvent = new SdgSwfEvent(SdgSwfEvent.SDG_SWF_ACTION);
			ev.data = params;
			_actionControl.dispatchEvent(ev);
		}
		protected function dispatchSWFEvent(params:Object):void
		{
			// dispatch a swf action event
			var ev:SdgSwfEvent = new SdgSwfEvent(SdgSwfEvent.SDG_SWF_EVENT);
			ev.data = params;
			_actionControl.dispatchEvent(ev);
		}
		
		
		public function get actionControl():EventDispatcher
		{
			return _actionControl;
		}
		
		public function set time(value:String):void
		{
			trace('SWFContainer time: ' + value);
		}
		
	}
	
}