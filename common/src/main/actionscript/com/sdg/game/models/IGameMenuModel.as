package com.sdg.game.models
{
	import flash.events.IEventDispatcher;
	
	public interface IGameMenuModel extends IEventDispatcher
	{
		function close():void;
	}
}