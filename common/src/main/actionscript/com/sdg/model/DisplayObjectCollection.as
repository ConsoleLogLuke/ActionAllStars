package com.sdg.model
{
	import flash.display.DisplayObject;
	
	public class DisplayObjectCollection extends ObjectCollection
	{
		public function DisplayObjectCollection()
		{
			super();
		}
		
		////////////////////
		// INSTANCE METHODS
		////////////////////
		
		/**
		 * Returns the item at the specified index.
		 */
		public function getAt(index:int):DisplayObject
		{	
			return _data[index];
		}
		
		/**
		 * Returns the index of the specified item.
		 */
		public function indexOf(value:DisplayObject):int
		{
			return _data.indexOf(value);
		}
	
		/**
		 * Returns whether the value exists.
		 */
		public function contains(value:DisplayObject):Boolean
		{
			return _data.indexOf(value) > -1;
		}
		
		/**
		 * Adds item to the end of the collection.
		 */
		public function push(value:DisplayObject):uint
		{
			return _data.push(value);
		}
		
	}
}