package com.sdg.events
{
	import flash.events.Event;
	
	public class SocketPetEvent extends SocketEvent
	{
		public static const PET_PLAYED:String = 'petPlayed';
		public static const PET_CONSUMED:String = 'petConsumed';
		public static const PET_FOLLOW_MODE:String = 'setPetFollowMode';
		
		private var _petInventoryId:int;
		private var _petName:String;
		private var _happiness:Number;
		private var _energy:Number;
		private var _happinessTimeStamp:Number;
		private var _energyTimeStamp:Number;
		private var _followMode:int;
		
		public function SocketPetEvent(type:String, petInventoryId:int, params:Object = null)
		{
			super(type, params);
			
			_petInventoryId = petInventoryId;
			_followMode = -1;
		}
		
		public function setEncodedEnergy(encodedValues:String):void
		{
			var energyValues:Array = encodedValues.split('~');
			_energy = int(energyValues[0]) / 100;
			_energyTimeStamp = energyValues[1] * 1000;
		}
		
		public function setEncodedHappiness(encodedValues:String):void
		{
			var happinessValues:Array = encodedValues.split('~');
			_happiness = int(happinessValues[0]) / 100;
			_happinessTimeStamp = happinessValues[1] * 1000;
		}
		
		////////////////////
		// GET/SET FUNCTIONS
		////////////////////
		
		public function get petInventoryId():int
		{
			return _petInventoryId;
		}
		
		public function get petName():String
		{
			return _petName;
		}
		public function set petName(value:String):void
		{
			_petName = value;
		}
		
		public function get happinessTimeStamp():Number
		{
			return _happinessTimeStamp;
		}
		
		public function get energyTimeStamp():Number
		{
			return _energyTimeStamp;
		}
		
		public function get happiness():Number
		{
			return _happiness;
		}
		
		public function get energy():Number
		{
			return _energy;
		}
		
		public function get followMode():int
		{
			return _followMode;
		}
		public function set followMode(value:int):void
		{
			_followMode = value;
		}
		
	}
}