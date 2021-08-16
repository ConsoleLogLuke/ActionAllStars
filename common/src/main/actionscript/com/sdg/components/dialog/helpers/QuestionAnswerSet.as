package com.sdg.components.dialog.helpers
{
	public class QuestionAnswerSet
	{
		private var _qOrderId:int;				// order 0 or 1
		private var _qQuestionId:int;			// which question is it?
		private var _qText:String;				// the question text
		private  var _answers:Array = new Array;	// answers sorted by order 		
		private  var _answersXml:XMLList;
		 
	// given an xml fragment from the download representing this question and answers 
	// parse it out and sort the answers by their order id into answerText

		public function QuestionAnswerSet( inputXml:XML )
		{
			_qOrderId = int(inputXml.orderId);
			_qQuestionId = int(inputXml.questionId);
			_qText = inputXml.text;

			var _ansId:int;
			var _ansOrderId:int;
			var _ansText:String;
			
			_answersXml = inputXml.answers.children(); 

			for each (var item:XML in _answersXml )	// get the xml into the array
			{
				_ansId = int(item.answerId[0]);
				_ansOrderId = int(item.orderId[0]);
				_ansText = String(item.text[0]);
				_answers.push({answerId:_ansId, orderId:_ansOrderId, answerText:_ansText});
			}
			_answers.sortOn("orderId");			
		}

		// access methods
		
		public function getAnswerText(index:int):String
		{	return( _answers[index]["answerText"] );	}

		public function getAnswerId(index:int):int
		{	return( _answers[index]["answerId"] );		}

		// access questions
		public function getQOrderId():int
		{	return( _qOrderId )							}
		
		public function getQQuestionId():int
		{	return( _qQuestionId );						}
		
		public function getQText():String
		{	return( _qText );							}
		
	} // end class
}