package com.sdg.npc
{
	import flash.events.Event;

	public class NPCEvent extends Event
	{
		public static const NPC_CLICK:String = 'npc click';
		
		protected var _npcId:String;
		
		public function NPCEvent(type:String, npcId:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			_npcId = npcId;
		}
		
		public function get npcId():String
		{
			return _npcId;
		}
		
	}
}