package com.sdg.pickem
{
	public class PickemInstance extends Object
	{
		private var _elapsedSinceStart:int;
		private var _elapsedCurrentCycle:int;
		private var _elapsedCurrentQuestion:int;
		private var _questionIndex:int;
		private var _state:String;
		private var _countdown:int;
		
		/**
		 * PickemInstance is a data container that represents an instance of time within a pickem game.
		 */
			
		public function PickemInstance(elapsedSinceStart:int, elapsedCurrentCycle:int, elapsedCurrentQuestion:int, questionIndex:int, state:String, countdown:int)
		{
			super();
			
			_elapsedSinceStart = elapsedSinceStart;
			_elapsedCurrentCycle = elapsedCurrentCycle;
			_elapsedCurrentQuestion = elapsedCurrentQuestion;
			_questionIndex = questionIndex;
			_state = state;
			_countdown = countdown;
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		public function get elapsedSinceStart():int
		{
			return _elapsedSinceStart;
		}
		
		public function get elapsedCurrentCycle():int
		{
			return _elapsedCurrentCycle;
		}
		
		public function get elapsedCurrentQuestion():int
		{
			return _elapsedCurrentQuestion;
		}
		
		public function get questionIndex():int
		{
			return _questionIndex;
		}
		
		public function get state():String
		{
			return _state;
		}
		
		public function get countdown():int
		{
			return _countdown;
		}
		
	}
}