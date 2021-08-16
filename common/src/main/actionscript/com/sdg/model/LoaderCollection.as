package com.sdg.model
{
	import flash.display.Loader;
	
	public class LoaderCollection extends ObjectCollection
	{
		public function LoaderCollection()
		{
			super();
		}
		
		////////////////////
		// INSTANCE METHODS
		////////////////////
		
		/**
		 * Returns the item at the specified index.
		 */
		public function getAt(index:int):Loader
		{	
			return _data[index];
		}
		
		/**
		 * Returns the index of the specified item.
		 */
		public function indexOf(value:Loader):int
		{
			return _data.indexOf(value);
		}
	
		/**
		 * Returns whether the value exists.
		 */
		public function contains(value:Loader):Boolean
		{
			return _data.indexOf(value) > -1;
		}
		
		/**
		 * Adds item to the end of the collection.
		 */
		public function push(value:Loader):uint
		{
			return _data.push(value);
		}
		
		/**
		 * Removes the first item from the collection and returns that item.
		 */
		public function shift():Loader
		{
			return _data.shift() as Loader;
		}
		
	}
}