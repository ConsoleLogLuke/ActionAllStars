package com.sdg.components.events
{
	import flash.events.Event;

	public class TurfVoteEvent extends Event
	{
		public static const VOTE:String = 'vote';
		
		public var vote:uint;
		
		public function TurfVoteEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, vote:int = 0)
		{
			super(type, bubbles, cancelable);
			
			this.vote = vote;
		}
	}
}