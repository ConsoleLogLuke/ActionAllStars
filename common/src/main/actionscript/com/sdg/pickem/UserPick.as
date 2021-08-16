package com.sdg.pickem
{
	import com.sdg.trivia.TriviaAnswer;
	
	public class UserPick extends Object
	{
		private var _eventId:int;
		private var _questionId:int;
		private var _pickedAnswer:TriviaAnswer;
		
		public function UserPick(eventId:int, questionId:int, pickedAnswer:TriviaAnswer)
		{
			super();
			
			_eventId = eventId;
			_questionId = questionId;
			_pickedAnswer = pickedAnswer;
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		public function get eventId():int
		{
			return _eventId;
		}
		
		public function get questionId():int
		{
			return _questionId;
		}
		
		public function get pickedAnswer():TriviaAnswer
		{
			return _pickedAnswer;
		}
		
	}
}