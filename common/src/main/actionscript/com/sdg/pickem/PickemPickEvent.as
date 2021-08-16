package com.sdg.pickem
{
	import flash.events.Event;

	public class PickemPickEvent extends Event
	{
		public static const NEW_PICK:String = 'new user pick';
		public static const FINAL_PICK:String = 'made final pick';
		public static const FIRST_TIME_GAME_COMPLETE:String = 'first time game complete';
		public static const VOTE_REGISTERED:String = 'vote registered';
		
		public function PickemPickEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}