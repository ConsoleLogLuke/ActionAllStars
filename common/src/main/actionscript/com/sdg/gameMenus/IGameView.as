package com.sdg.gameMenus
{
	import flash.display.DisplayObject;
	
	public interface IGameView
	{
		function showMainMenu():void;
		function showGameFinish(resultXml:XML):void;
		function destroy():void;
		function get display():DisplayObject;
		function set stats(value:Array):void;
		function set storeItems(value:Array):void;
		function set teams(value:Array):void;
	}
}
