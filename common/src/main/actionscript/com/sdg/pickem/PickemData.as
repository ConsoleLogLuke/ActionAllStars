package com.sdg.pickem
{
	import com.sdg.model.ActionAllStarsEvent;
	import com.sdg.model.ActionAllStarsEventType;
	import com.sdg.trivia.Question;
	import com.sdg.trivia.TriviaQuestionCollection;

	public class PickemData extends ActionAllStarsEvent
	{
		private var _endTime:Date;
		private var _questions:TriviaQuestionCollection;
		
		public function PickemData(id:String, startTime:Date, endTime:Date, questions:TriviaQuestionCollection)
		{
			// Hard code start and end times.
			var now:Date = new Date();
			_startTime = startTime;
			_endTime = endTime;
			_questions = questions;
			
			super(ActionAllStarsEventType.PICKEM_EVENT, id, _startTime);
		}
		
		////////////////////
		// CLASS METHODS
		////////////////////
		
		public function getQuestion(questionId:int):Question
		{
			// Return a question from the question collection with specified question id.
			var i:int;
			var len:int = _questions.length;
			var question:Question;
			for (i; i < len; i++)
			{
				if (_questions.getAt(i).id == questionId) return _questions.getAt(i);
			}
			
			return null;
		}
		
		public function getQuestionIndex(questionId:int):int
		{
			// Return the index of the quesion at questionId.
			var i:int;
			var len:int = _questions.length;
			var question:Question;
			for (i; i < len; i++)
			{
				if (_questions.getAt(i).id == questionId) return i;
			}
			
			return -1;
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		public function get questions():TriviaQuestionCollection
		{
			return _questions;
		}
		
		public function get endTime():Date
		{
			return _endTime;
		}
		public function set endTime(value:Date):void
		{
			_endTime = value;
		}
		
	}
}