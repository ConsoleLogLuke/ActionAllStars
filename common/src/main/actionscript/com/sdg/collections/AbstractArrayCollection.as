package com.sdg.collections
{
	import flash.events.EventDispatcher;
	
	public class AbstractArrayCollection extends EventDispatcher
	{	
		protected var data:Array;
		
		/**
		 * Returns the number of items in the collection.
		 */
		public function get size():uint
		{
			return data.length;
		}
	
		/**
		 * Returns whether the collection contains any items.
		 */
		public function get isEmpty():Boolean
		{
			return size < 1;
		}
		
		/**
		 * Returns the item at the specified index.
		 */
		public function get(index:int):*
		{	
			return data[index];
		}
		
		/**
		 * Returns the index of the specified item.
		 */
		public function indexOf(value:*):int
		{
			return data.indexOf(value);
		}
	
		/**
		 * Returns whether the value exists.
		 */
		public function contains(value:*):Boolean
		{
			return data.indexOf(value) > -1;
		}

		/**
		 * Removes all items in the collection.
		 */
		public function removeAll():void
		{
			data = [];
		}
	
		/**
		 * Returns an array of the items in the collection.
		 */
		public function toArray():Array
		{
			return data.slice();
		}
	}
}