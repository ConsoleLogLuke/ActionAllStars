package com.sdg.model
{
	public class PartyBuddy extends Buddy
	{
		private var _numGuest:int;
		private var _partyName:String;
		
		public function PartyBuddy()
		{
			super();
		}
		
		public function set numGuest(value:int):void
		{
			_numGuest = value;
		} 
		
		public function get numGuest():int
		{
			return _numGuest;
		}
		
		public function set partyName(value:String):void
		{
			_partyName = value;
		}
		
		public function get partyName():String
		{
			return _partyName;
		}
	}
}