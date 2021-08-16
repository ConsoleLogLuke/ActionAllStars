package com.sdg.animation
{
	import flash.events.IEventDispatcher;

	public interface IAnimator extends IEventDispatcher
	{
		function get isPlaying():Boolean;
	
		function get loopCount():uint;
		function set loopCount(value:uint):void;
		
		function reset():void;
	
		function play():void;

		function stop():void;
	}
}