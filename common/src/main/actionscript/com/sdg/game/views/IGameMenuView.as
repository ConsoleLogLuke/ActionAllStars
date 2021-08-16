package com.sdg.game.views
{
	import com.sdg.game.models.IGameMenuModel;
	
	import flash.events.IEventDispatcher;
	
	public interface IGameMenuView extends IEventDispatcher
	{
		function set model(value:IGameMenuModel):void;
		function close():void;
	}
}