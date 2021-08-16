package com.sdg.model
{
	public class ActionAllStarsEventCollection extends ObjectCollection
	{
		public function ActionAllStarsEventCollection()
		{
			super();
		}
		
		/**
		 * Returns the item at the specified index.
		 */
		public function getAt(index:int):ActionAllStarsEvent
		{	
			return _data[index];
		}
		
		/**
		 * Returns the index of the specified item.
		 */
		public function indexOf(value:ActionAllStarsEvent):int
		{
			return _data.indexOf(value);
		}
	
		/**
		 * Returns whether the value exists.
		 */
		public function contains(value:ActionAllStarsEvent):Boolean
		{
			return _data.indexOf(value) > -1;
		}
		
		/**
		 * Adds item to the end of the collection.
		 */
		public function push(value:ActionAllStarsEvent):uint
		{
			return _data.push(value);
		}
	}
}