package com.sdg.events
{
	import com.sdg.model.Achievement;
	
	import flash.events.Event;

	public class QuestCardEvent extends Event
	{
		public static const SHOW_CARD:String = 'show card';
		public static const OK:String = 'quest card ok';
		
		private var _quest:Achievement;
		
		public var isNewQuestOffer:Boolean;
		
		public function QuestCardEvent(type:String, quest:Achievement = null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			_quest = quest;
			
			// Set default value.
			// If this card is being shown to offer a new quest to the user, set this to TRUE externaly.
			isNewQuestOffer = false;
		}
		
		public function get quest():Achievement
		{
			return _quest;
		}
		
	}
}