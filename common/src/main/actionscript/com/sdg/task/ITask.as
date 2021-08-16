package com.sdg.task
{
	import flash.events.IEventDispatcher;

	public interface ITask extends IEventDispatcher
	{
		function get isRunning():Boolean;
	
		function start():void;
	
		function interrupt():void;
	}
}