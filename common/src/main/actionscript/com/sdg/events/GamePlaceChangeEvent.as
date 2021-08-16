package com.sdg.events
{
	import flash.events.Event;

	public class GamePlaceChangeEvent extends Event
	{
		public static const PLACE_UP:String = 'place up';
		public static const PLACE_DOWN:String = 'place down';
		
		private var _id:int;
		private var _previousPlace:int;
		private var _currentPlace:int;
		
		public function GamePlaceChangeEvent(type:String, id:int, previousPlace:int, currentPlace:int, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			_id = id;
			_previousPlace = previousPlace;
			_currentPlace = currentPlace;
		}
		
		public function get id():int
		{
			return _id;
		}
		
		public function get previousPlace():int
		{
			return _previousPlace;
		}
		
		public function get currentPlace():int
		{
			return _currentPlace;
		}
		
	}
}