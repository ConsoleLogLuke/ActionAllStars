package com.sdg.trivia
{
	import com.sdg.model.ObjectCollection;
	
	
	public class TriviaQuestionCollection extends ObjectCollection
	{
		public function TriviaQuestionCollection()
		{
			super();
		}
		
		/**
		 * Returns the item at the specified index.
		 */
		public function get(index:int):Question
		{	
			return _data[index];
		}
		public function getAt(index:int):Question
		{	
			return _data[index];
		}
		
		/**
		 * Returns the index of the specified item.
		 */
		public function indexOf(value:Question):int
		{
			return _data.indexOf(value);
		}
	
		/**
		 * Returns whether the value exists.
		 */
		public function contains(value:Question):Boolean
		{
			return _data.indexOf(value) > -1;
		}
		
		/**
		 * Adds item to the end of the collection.
		 */
		public function push(value:Question):uint
		{
			return _data.push(value);
		}
		
	}
}