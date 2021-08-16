package com.sdg.trivia
{	
	import com.sdg.model.ActionAllStarsEvent;
	import com.sdg.model.ActionAllStarsEventType;
	
	/**
	 * This class is a data stucture and is NOT an Event object in
	 * terms of an actionscript event that may dispatched and listened
	 * for. It contains data that pertains to trivia game events.
	*/
	public class TriviaEvent extends ActionAllStarsEvent
	{
		public static const TIME_TO_ANSWER_DURATION:int = 20000;
		public static const SHOW_ANSWER_DURATION:int = 15000;
		protected var _questions:TriviaQuestionCollection;
		
		public function TriviaEvent(id:String, startTime:Date, questions:TriviaQuestionCollection, logoURL:String = '')
		{
			super(ActionAllStarsEventType.TRIVIA_EVENT, id, startTime, logoURL);
			
			_questions = questions;
		}
		
		////////////////////
		// INSTANCE METHODS
		////////////////////
		
		override public function toString():String
		{
			return 'TriviaEvent: [startTime: ' + startTime + ', questions: ' + _questions.length + ']';
		}
		
		public static function getQuestionAnswerDuration():Number
		{
			return TIME_TO_ANSWER_DURATION + SHOW_ANSWER_DURATION;
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		public function get questions():TriviaQuestionCollection
		{
			return _questions;
		}
		public function set questions(value:TriviaQuestionCollection):void
		{
			_questions = value;
		}
		
		override public function get duration():Number
		{
			var questionAnswerDuration:Number = TIME_TO_ANSWER_DURATION + SHOW_ANSWER_DURATION;
			return questionAnswerDuration * _questions.length;
		}
		
	}
}