package com.sdg.printshop.printitem
{
	import flash.display.Sprite;
	import flash.events.IEventDispatcher;
	
	public interface IPrintItem extends IEventDispatcher
	{
		function getPrintPage():Sprite;
		function getPrintPreview():Sprite;
		function getPrintOffsetX():uint;
		function getPrintOffsetY():uint;
		function getLoggingId():int;
	}
}