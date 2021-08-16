package com.sdg.events
{
	import com.sdg.model.PDACallModel;
	
	import flash.events.Event;

	public class PDACallEvent extends Event
	{
		public static const CALL_ANSWERED:String = 'call answered';
		
		private var _callData:PDACallModel;
		
		public function PDACallEvent(type:String, callData:PDACallModel, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			_callData = callData;
		}
		
		public function get callData():PDACallModel
		{
			return _callData;
		}
		
	}
}