package com.sdg.trivia
{
	import com.sdg.model.ObjectCollection;

	public class TriviaEventCollection extends ObjectCollection
	{
		public function TriviaEventCollection()
		{
			super();
		}
		
		/**
		 * Returns the item at the specified index.
		 */
		public function getAt(index:int):TriviaEvent
		{	
			return _data[index];
		}
		
		/**
		 * Returns the index of the specified item.
		 */
		public function indexOf(value:TriviaEvent):int
		{
			return _data.indexOf(value);
		}
	
		/**
		 * Returns whether the value exists.
		 */
		public function contains(value:TriviaEvent):Boolean
		{
			return _data.indexOf(value) > -1;
		}
		
		/**
		 * Adds item to the end of the collection.
		 */
		public function push(value:TriviaEvent):uint
		{
			return _data.push(value);
		}
	}
}