package com.sdg.util
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	public class Delay extends Object
	{
		public static function CallFunctionAfterDelay(delay:uint, functionToCall:Function):void
		{
			// After the specified amount of time,
			// Call the function.
			var timer:Timer = new Timer(delay);
			timer.addEventListener(TimerEvent.TIMER, onTimer);
			timer.start();
			
			function onTimer(e:TimerEvent):void
			{
				// Kill timer.
				timer.removeEventListener(TimerEvent.TIMER, onTimer);
				timer.reset();
				timer = null;
				
				// Call function.
				functionToCall();
				
				// Kill references.
				functionToCall = null;
			}
		}
		
	}
}