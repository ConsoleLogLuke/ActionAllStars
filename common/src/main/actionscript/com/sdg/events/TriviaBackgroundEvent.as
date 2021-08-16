package com.sdg.events
{
	import flash.events.Event;

	public class TriviaBackgroundEvent extends Event
	{
		public static const READY_FOR_QUESTION:String = 'ready for question';
		public static const QUESTION_SHOWN:String = 'question shown';
		public static const GAME_MODE_OFF:String = 'game mode off';
		
		public function TriviaBackgroundEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}