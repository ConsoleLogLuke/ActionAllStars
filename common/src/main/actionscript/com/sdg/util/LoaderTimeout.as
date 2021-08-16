package com.sdg.util
{
	import flash.display.Loader;
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	public class LoaderTimeout extends Object
	{
		public static function StartTimeout(loader:Loader, duration:uint, onTimeout:Function):void
		{
			var timer:Timer = new Timer(duration);
			timer.addEventListener(TimerEvent.TIMER, onTimer);
			timer.start();
			
			loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onProgress);
			
			function onProgress(e:ProgressEvent):void
			{
				timer.reset();
				timer.start();
			}
			
			function onTimer(e:TimerEvent):void
			{
				// Timeout.
				
				// Remove listeners.
				loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, onProgress);
				timer.removeEventListener(TimerEvent.TIMER, onTimer);
				
				// Kill timer.
				timer.reset();
				timer = null;
				
				// Call handler.
				onTimeout();
				
				// Kill references.
				loader = null;
				onTimeout = null;
			}
		}
	}
}