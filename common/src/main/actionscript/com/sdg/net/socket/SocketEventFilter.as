package com.sdg.net.socket
{
	import com.sdg.events.SocketEvent;
	import com.sdg.net.socket.SocketClient;
	
	public class SocketEventFilter
	{
		public var disableAfterEvent:Boolean;
		public var validParams:Object;
		public var listener:Function;
		
		private var _enabled:Boolean;
		private var _eventType:String;
		
		public function get enabled():Boolean
		{
			return _enabled;
		}
		
		public function set enabled(value:Boolean):void
		{
			if (value == _enabled) return;
			
			_enabled = value;
			
			if (_eventType != null)
			{
				if (_enabled)
					SocketClient.getInstance().addEventListener(_eventType, eventHandler);
				else
					SocketClient.getInstance().removeEventListener(_eventType, eventHandler);
			}
		}
		
		public function get eventType():String
		{
			return _eventType;
		}
		
		public function set eventType(value:String):void
		{
			if (value == _eventType) return;
			
			if (_enabled)
			{
				if (_eventType) SocketClient.getInstance().removeEventListener(_eventType, eventHandler);
				if (value != null) SocketClient.getInstance().addEventListener(value, eventHandler);
			}
			
			_eventType = value;
		}
		
		public function SocketEventFilter(listener:Function = null, eventType:String = null, validParams:Object = null, disableAfterEvent:Boolean = true):void
		{
			this.listener = listener;
			_eventType = eventType;
			this.validParams = validParams;
			this.disableAfterEvent = disableAfterEvent;
			
			enabled = true;
		}
		
		protected function eventHandler(event:SocketEvent):void
		{
			// Validate response by matching filter parameters.
			if (validParams)
			{
				var params:Object = event.params;
				
				for (var name:String in validParams)
				{
					if (params[name] != validParams[name]) return;
				}
			}
			
			if (disableAfterEvent) enabled = false;
			if (listener != null) listener(event);
		}
	}
}