package com.sdg.gameMenus
{
	import flash.events.IEventDispatcher;
	
	public interface IGameMenuItem extends IEventDispatcher
	{
		function destroy():void;
		
		function get width():Number;
		function get height():Number;
		
		function get x():Number;
		function set x(value:Number):void;
		
		function get y():Number;
		function set y(value:Number):void;
		
		function get onSelected():Function;
		function set onSelected(value:Function):void;
	}
}