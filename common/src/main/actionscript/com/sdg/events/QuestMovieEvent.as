package com.sdg.events
{
	import com.sdg.model.Achievement;
	
	import flash.events.Event;

	public class QuestMovieEvent extends Event
	{
		public static const SHOW_MOVIE:String = 'show quest movie';
		
		protected var _quest:Achievement;
		
		public function QuestMovieEvent(type:String, quest:Achievement, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			_quest = quest;
		}
		
		public function get quest():Achievement
		{
			return _quest;
		}
		
	}
}