package com.sdg.model
{
	public class BadgeLevelCollection extends ObjectCollection
	{
		public function BadgeLevelCollection()
		{
			super();
		}
		
		////////////////////
		// INSTANCE METHODS
		////////////////////
		
		/**
		 * Returns the item at the specified index.
		 */
		public function getAt(index:int):BadgeLevel
		{	
			return _data[index];
		}
		
		/**
		 * Returns the index of the specified item.
		 */
		public function indexOf(value:BadgeLevel):int
		{
			return _data.indexOf(value);
		}
	
		/**
		 * Returns whether the value exists.
		 */
		public function contains(value:BadgeLevel):Boolean
		{
			return _data.indexOf(value) > -1;
		}
		
		/**
		 * Adds item to the end of the collection.
		 */
		public function push(value:BadgeLevel):uint
		{
			return _data.push(value);
		}
		
		/**
		 * Returns the item with specified id.
		 */
		public function getFromId(id:int):BadgeLevel
		{	
			var i:int = 0;
			var len:int = _data.length;
			for (i; i < len; i++)
			{
				var level:BadgeLevel = getAt(i);
				if (level.id == id) return level;
			}
			
			// If we get here, we couldn't find a match.
			return null;
		}
		
	}
}