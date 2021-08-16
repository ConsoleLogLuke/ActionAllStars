package com.sdg.model
{
	import com.sdg.pet.events.PetUpdateEvent;
	
	public class PetItem extends InventoryItem
	{
		// Miliseconds for how long a full charge of happiness/energy would last.
		public static const DURATION_OF_FULL_ENERGY:int = 3600000; // 900000
		public static const DURATION_OF_FULL_HAPPINESS:int = 3600000;
		public static const ENERGY_LEVEL_STEPS:int = 4;
		public static const HAPPINESS_LEVEL_STEPS:int = 4;
		
		private var _happiness:Number;
		private var _energy:Number;
		private var _happinessTimeStamp:Number;
		private var _energyTimeStamp:Number;
		private var _createdTime:Number;
		private var _isFollowingOwner:Boolean;
		private var _isLeashed:Boolean;
		
		public function PetItem()
		{
			super();
			
			_createdTime = 0;
			_energy = 0;
			_energyTimeStamp = 0;
			_happiness = 0;
			_happinessTimeStamp = 0;
			_isFollowingOwner = false;
			_isLeashed = false;
		}
		
		////////////////////
		// PUBLIC FUNCTIONS
		////////////////////
		
		public static function isCustomPetName(petName:String):Boolean
		{
			// Check if input name is a custom pet name.
			return (petName.indexOf('Pet') < 0);
		}
		
		public function setHappiness(value:Number, timeStamp:Number):void
		{
			// Time stamp is expected in miliseconds.
			_happiness = value;
			_happinessTimeStamp = timeStamp;
			
			dispatchEvent(new PetUpdateEvent(PetUpdateEvent.HAPPINESS, this));
		}
		
		public function setEnergy(value:Number, timeStamp:Number):void
		{
			// Time stamp is expected in miliseconds.
			_energy = value;
			_energyTimeStamp = timeStamp;
			
			dispatchEvent(new PetUpdateEvent(PetUpdateEvent.ENERGY, this));
		}
		
		////////////////////
		// GET/SET FUNCTIONS
		////////////////////
		
		public function get happiness():Number
		{
			// Happiness is a product of the value and when the value was set.
			var dateTime:Number = ModelLocator.getInstance().serverDate.time;
			var timeSinceValueWasSet:Number = dateTime - _happinessTimeStamp;
			var timeLeftUntilEmpty:Number = (DURATION_OF_FULL_HAPPINESS * _happiness) - timeSinceValueWasSet;
			var value:Number = timeLeftUntilEmpty / DURATION_OF_FULL_HAPPINESS;
			value = Math.min(value, 1);
			value = Math.max(value, 0);
			return value;
		}
		
		public function get happinessLevelStep():int
		{
			return Math.ceil(HAPPINESS_LEVEL_STEPS * happiness);
		}
		
		public function get energy():Number
		{
			// If it's a pet owned by god avatar, always return 1.
			if (avatarId == 4) return 1;
			
			// Energy is a product of the value and when the value was set.
			var dateTime:Number = ModelLocator.getInstance().serverDate.time;
			var timeSinceValueWasSet:Number = dateTime - _energyTimeStamp;
			var timeLeftUntilEmpty:Number = (DURATION_OF_FULL_ENERGY * _energy) - timeSinceValueWasSet;
			var value:Number = timeLeftUntilEmpty / DURATION_OF_FULL_ENERGY;
			value = Math.min(value, 1);
			value = Math.max(value, 0);
			return value;
		}
		
		public function get energyLevelStep():int
		{
			return Math.ceil(ENERGY_LEVEL_STEPS * energy);
		}
		
		public function get createdTime():Number
		{
			return _createdTime;
		}
		public function set createdTime(value:Number):void
		{
			_createdTime = value;
		}
		
		public function get isFollowingOwner():Boolean
		{
			return _isFollowingOwner;
		}
		public function set isFollowingOwner(value:Boolean):void
		{
			_isFollowingOwner = value;
		}
		
		public function get isLeashed():Boolean
		{
			return _isLeashed;
		}
		public function set isLeashed(value:Boolean):void
		{
			_isLeashed = value;
		}
		
	}
}