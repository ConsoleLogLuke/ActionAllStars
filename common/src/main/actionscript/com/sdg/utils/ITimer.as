package com.sdg.utils
{
	import flash.events.IEventDispatcher;

	public interface ITimer extends IEventDispatcher
	{
		function get currentIntervalTime():Number;
		
		function get interval():Number;
		function set interval(value:Number):void;
		
		function get intervalType():uint;
		
		function get isRunning():Boolean;
		
		function start():void;
	
		function stop():void;
	}
}