package com.sdg.game.keycombo
{
	import com.sdg.display.IDisplayObject;
	
	import flash.events.IEventDispatcher;
	
	public interface IKeyComboController extends IEventDispatcher, IDisplayObject
	{
		function start(initialValue:String):void;
		function stop(validStop:Boolean = true):void;
		function attemptToSetNextValue(value:String):void;
	}
}