package com.sdg.pickem
{
	import com.sdg.model.ActionAllStarsEvent;
	import com.sdg.model.ActionAllStarsEventType;
	import com.sdg.trivia.TriviaQuestionCollection;

	public class PickemEvent extends ActionAllStarsEvent
	{
		public static const POLL_DURATION:int = 12000;
		public static const ROOM_RESULT_DURATION:int = 10000;
		public static const WORLD_RESULT_DURATION:int = 5000;
		public static const RESULT_AGGREGATION_DURATION:int = 8000;
		protected var _questions:TriviaQuestionCollection;
		
		private var _endTime:Date;
		
		public function PickemEvent(id:String, startTime:Date, endTime:Date, questions:TriviaQuestionCollection, logoURL:String = '')
		{
			super(ActionAllStarsEventType.PICKEM_EVENT, id, startTime, logoURL);
			
			_questions = questions;
			_endTime = endTime;
		}
		
		////////////////////
		// INSTANCE METHODS
		////////////////////
		
		override public function toString():String
		{
			return 'PickemEvent: [startTime: ' + startTime + ', questions: ' + _questions.length + ']';
		}
		
		public static function getQuestionDuration():Number
		{
			//return POLL_DURATION + ROOM_RESULT_DURATION + WORLD_RESULT_DURATION;
			return POLL_DURATION + RESULT_AGGREGATION_DURATION + WORLD_RESULT_DURATION;
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
			var questionAnswerDuration:Number = POLL_DURATION + ROOM_RESULT_DURATION + WORLD_RESULT_DURATION;
			return questionAnswerDuration * _questions.length;
		}
		
		public function get endTime():Date
		{
			return _endTime;
		}
		
	}
}