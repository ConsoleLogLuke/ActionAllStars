package com.sdg.model
{
	public class BadgeCategoryCollection extends ObjectCollection
	{
		public function BadgeCategoryCollection()
		{
			super();
		}
		
		////////////////////
		// INSTANCE METHODS
		////////////////////
		
		/**
		 * Returns the item at the specified index.
		 */
		public function getAt(index:int):BadgeCategory
		{	
			return _data[index];
		}
		
		/**
		 * Returns the index of the specified item.
		 */
		public function indexOf(value:BadgeCategory):int
		{
			return _data.indexOf(value);
		}
	
		/**
		 * Returns whether the value exists.
		 */
		public function contains(value:BadgeCategory):Boolean
		{
			return _data.indexOf(value) > -1;
		}
		
		/**
		 * Adds item to the end of the collection.
		 */
		public function push(value:BadgeCategory):uint
		{
			return _data.push(value);
		}
		
		/**
		 * Returns the item with specified id.
		 */
		public function getFromId(id:int):BadgeCategory
		{	
			var i:int = 0;
			var len:int = _data.length;
			for (i; i < len; i++)
			{
				var category:BadgeCategory = getAt(i);
				if (category.id == id) return category;
			}
			
			// If we get here, we couldn't find a match.
			return null;
		}
		
	}
}