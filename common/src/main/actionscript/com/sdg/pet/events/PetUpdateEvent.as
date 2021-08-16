package com.sdg.pet.events
{
	import com.sdg.model.PetItem;
	
	import flash.events.Event;

	public class PetUpdateEvent extends Event
	{
		public static const ENERGY:String = 'pet energy';
		public static const HAPPINESS:String = 'pet happiness';
		
		private var _petItem:PetItem;
		
		public function PetUpdateEvent(type:String, petItem:PetItem, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			_petItem = petItem;
		}
		
		public function get petItem():PetItem
		{
			return _petItem;
		}
		
	}
}