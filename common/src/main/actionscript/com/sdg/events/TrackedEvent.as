package com.sdg.events
{
	import flash.events.EventDispatcher;
	
	public class TrackedEvent extends Object
	{
		protected var _target:EventDispatcher;
		protected var _type:String;
		protected var _listener:Function;
		
		public function TrackedEvent(target:EventDispatcher, type:String, listener:Function)
		{
			super();
			
			_target = target;
			_type = type;
			_listener = listener;
		}
		
		public function get target():EventDispatcher
		{
			return _target;
		}
		
		public function get type():String
		{
			return _type;
		}
		
		public function get listener():Function
		{
			return _listener;
		}
	}
}