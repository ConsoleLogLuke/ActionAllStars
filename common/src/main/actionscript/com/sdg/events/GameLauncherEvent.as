package com.sdg.events
{
	import flash.events.Event;

	public class GameLauncherEvent extends Event
	{
		public static const CLICKED:String = 'game launch clicked';
		
		public var gameId:uint = 0;
		
		public function GameLauncherEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}