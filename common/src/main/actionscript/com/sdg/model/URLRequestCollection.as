package com.sdg.model
{
	import flash.net.URLRequest;
	
	public class URLRequestCollection extends ObjectCollection
	{
		public function URLRequestCollection()
		{
			super();
		}
		
		////////////////////
		// INSTANCE METHODS
		////////////////////
		
		/**
		 * Returns the item at the specified index.
		 */
		public function getAt(index:int):URLRequest
		{	
			return _data[index];
		}
		
		/**
		 * Returns the index of the specified item.
		 */
		public function indexOf(value:URLRequest):int
		{
			return _data.indexOf(value);
		}
	
		/**
		 * Returns whether the value exists.
		 */
		public function contains(value:URLRequest):Boolean
		{
			return _data.indexOf(value) > -1;
		}
		
		/**
		 * Adds item to the end of the collection.
		 */
		public function push(value:URLRequest):uint
		{
			return _data.push(value);
		}
		
		/**
		 * Removes the first item from the collection and returns that item.
		 */
		public function shift():URLRequest
		{
			return _data.shift() as URLRequest;
		}
		
	}
}