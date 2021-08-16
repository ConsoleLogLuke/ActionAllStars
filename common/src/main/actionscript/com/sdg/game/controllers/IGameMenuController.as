package com.sdg.game.controllers
{
	import com.sdg.game.views.IGameMenuView;
	
	import flash.events.IEventDispatcher;
	
	public interface IGameMenuController extends IEventDispatcher
	{
		function get view():IGameMenuView;
	}
}