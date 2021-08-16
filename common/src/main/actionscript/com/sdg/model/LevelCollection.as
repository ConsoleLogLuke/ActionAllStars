package com.sdg.model
{
	public class LevelCollection extends ObjectCollection
	{
		public function LevelCollection()
		{
			super();
		}
		
		////////////////////
		// INSTANCE METHODS
		////////////////////
		
		/**
		 * Returns the item at the specified index.
		 */
		public function getAt(index:int):Level
		{	
			return _data[index];
		}
		
		/**
		 * Returns the index of the specified item.
		 */
		public function indexOf(value:Level):int
		{
			return _data.indexOf(value);
		}
	
		/**
		 * Returns whether the value exists.
		 */
		public function contains(value:Level):Boolean
		{
			return _data.indexOf(value) > -1;
		}
		
		/**
		 * Adds item to the end of the collection.
		 */
		public function push(value:Level):uint
		{
			return _data.push(value);
		}
		
		/**
		 * Returns the item with specified id.
		 */
		public function getFromId(id:int):Level
		{	
			var i:int = 0;
			var len:int = _data.length;
			for (i; i < len; i++)
			{
				if (getAt(i).id == id) return getAt(i);
			}
			
			// If we get here, we couldn't find a match.
			return null;
		}
		
	}
}