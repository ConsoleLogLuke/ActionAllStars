package com.sdg.mvc
{
	import flash.events.IEventDispatcher;
	
	public interface IModel extends IEventDispatcher
	{
		function init():void;
	}
}