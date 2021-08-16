package com.sdg.game.views
{
	import com.sdg.game.models.IGameMenuModel;
	
	public interface ISubMenuView
	{
		function show(model:IGameMenuModel):void;
		function hide():void;
		function get headerText():String;
		function close():void;
	}
}