package com.sdg.trivia
{
	import com.sdg.model.QuestionCategoryId;
	
	public class Question extends Object
	{
		protected var _id:int;
		protected var _text:String;
		protected var _answers:Array;
		protected var _correctAnswerId:int;
		private var _categoryId:int;
		
		public function Question(id:int, text:String, answers:Array, correctId:int)
		{
			super();
			
			// set values
			_text = text;
			_answers = answers;
			_id = id;
			_correctAnswerId = correctId;
		}
		
		////////////////////
		// INSTANCE METHODS
		////////////////////
		
		public function toString():String
		{
			return 'Question: ' + _id + ', ' + _text + ', ' + _answers.length + ' answers, correct ID: ' + _correctAnswerId;
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		public static function ParseQuestionXML(questionXML:XML):Question
		{
			// create a question object from the XML
			// the xml must be in a specific/predetermined format
			try
			{
				var text:String = questionXML.text;
				var correctID:int = questionXML.answers.@correctId;
				var id:int = int(questionXML.@questionId);
			}
			catch (e:Error)
			{
				throw(new Error('Could not parse necessary information from questionXML: ' + e.message));
				return null;
			}
			var answer:TriviaAnswer;
			var answers:Array = [];
			var i:int = 0;
			
			// questions have 1 or more answers
			// create an array of all answers within this question "answers"
			while (questionXML.answers.answer[i] != null)
			{
				var answerXML:XML = questionXML.answers.answer[i];
				var answerId:int = answerXML.@id;
				var isCorrect:Boolean = questionXML.answers.@correctId == answerId;
				answer = new TriviaAnswer(answerId, answerXML, isCorrect);	
				
				// Assign answer image url.
				answer.imageUrl = (answerXML.@imageUrl != null) ? answerXML.@imageUrl : '';
				
				// Assign color 1.
				//if (answerXML.@color1 != null && String(answerXML.@color1).length > 0) answer.color1 = parseInt('0x' + answerXML.@color1);
				answer.color1 = (answerXML.@color1 != null && String(answerXML.@color1).length > 0) ? parseInt('0x' + answerXML.@color1) : 16581376;
				
				// Assign color 2.
				answer.color2 = (answerXML.@color2 != null && String(answerXML.@color1).length > 0) ? parseInt('0x' + answerXML.@color2) : 16581376;
				
				// Assign color 3.
				answer.color3 = (answerXML.@color3 != null && String(answerXML.@color1).length > 0) ? parseInt('0x' + answerXML.@color3) : 16581376;
				
				// Assign color 4.
				answer.color4 = (answerXML.@color4 != null && String(answerXML.@color1).length > 0) ? parseInt('0x' + answerXML.@color4) : 16581376;
				
				answers.push(answer);
				i++;
			}
			
			// make sure we have atleast 1 answer
			if (answers.length < 1)
			{
				trace('Question: Could not create a question. Must have atleast 1 answer.');
				trace('Question ' + id + ': ' + text);
				return null;
			}
			
			// Create a new Question object.
			var q:Question = new Question(id, text, answers, correctID);
			
			// Assign a question category id.
			if (questionXML.@questionCategoryId != null && String(questionXML.@questionCategoryId).length > 0)
			{
				q.categoryId = questionXML.@questionCategoryId;
			}
			
			return q;
		}
		
		public static function ParseMultipleQuestionXML(questionsXML:XMLList):TriviaQuestionCollection
		{
			// Create question objects from the XML.
			// Store all of them in a TriviaQuestionCollection.
			var questions:TriviaQuestionCollection = new TriviaQuestionCollection();
			var question:Question;
			var answers:Array;
			var i:int = 0;
			var i2:int;
			while (questionsXML.question[i] != null)
			{
				// create a new Question object from XML
				question = ParseQuestionXML(questionsXML.question[i]);
				
				// append the question object to the TriviaQuestionCollection
				if (question != null) questions.push(question);
				i++;
			}
			
			return questions;
		}
		
		public function getAnswer(answerId:int):TriviaAnswer
		{
			// Return an answer from the answer array with specified answer id.
			var i:int;
			var len:int = answers.length;
			var answer:TriviaAnswer;
			for (i; i < len; i++)
			{
				if (TriviaAnswer(answers[i]).id == answerId) return answers[i] as TriviaAnswer;
			}
			
			return null;
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		public function get text():String
		{
			return _text;
		}
		
		public function get id():int
		{
			return _id;
		}
		public function set id(value:int):void
		{
			_id = value;
		}
		
		public function get correctAnswerId():int
		{
			return _correctAnswerId;
		}
		
		public function get answers():Array
		{
			return _answers;
		}
		
		public function get categoryId():int
		{
			return _categoryId;
		}
		public function set categoryId(value:int):void
		{
			// Validate the category Id.
			switch (value)
			{
				case QuestionCategoryId.TRIVIA :
					_categoryId = value;
					break;
				case QuestionCategoryId.TEAM :
					_categoryId = value;
					break;
				case QuestionCategoryId.PLAYER :
					_categoryId = value;
					break;
				default:
					// Invalid value.
			}
		}
		
	}
}