package com.sdg.events
{
	import com.sdg.model.QuestProvider;
	
	import flash.events.Event;

	public class QuestProviderEvent extends Event
	{
		public static const QUEST_PROVIDER_CLICKED:String = 'quest provider clicked';
		
		private var _questProvider:QuestProvider;
		
		public function QuestProviderEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		public function get questProvider():QuestProvider
		{
			return _questProvider;
		}
		public function set questProvider(value:QuestProvider):void
		{
			if (value == _questProvider) return;
			
			_questProvider = value;
		}
		
	}
}