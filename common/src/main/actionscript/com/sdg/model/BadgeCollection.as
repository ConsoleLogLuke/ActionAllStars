package com.sdg.model
{
	import com.sdg.utils.StringUtil;
	
	public class BadgeCollection extends ObjectCollection
	{
		public function BadgeCollection()
		{
			super();
		}
		
		////////////////////
		// INSTANCE METHODS
		////////////////////
		
		/**
		 * Returns the item at the specified index.
		 */
		public function getAt(index:int):Badge
		{	
			return _data[index];
		}
		
		/**
		 * Returns the index of the specified item.
		 */
		public function indexOf(value:Badge):int
		{
			return _data.indexOf(value);
		}
	
		/**
		 * Returns whether the value exists.
		 */
		public function contains(value:Badge):Boolean
		{
			return _data.indexOf(value) > -1;
		}
		
		/**
		 * Adds item to the end of the collection.
		 */
		public function push(value:Badge):uint
		{
			return _data.push(value);
		}
		
		/**
		 * Returns the item with specified id.
		 */
		public function getFromId(id:int):Badge
		{	
			var i:int = 0;
			var len:int = _data.length;
			for (i; i < len; i++)
			{
				var badge:Badge = getAt(i);
				if (badge.id == id) return badge;
			}
			
			// If we get here, we couldn't find a match.
			return null;
		}
		
		/**
		 * Sorts items alphabetically by name.
		 */
		public function sortAlphabetically():void
		{	
			_data.sort(alphabeticNameCompare);
			
			function alphabeticNameCompare(a:Badge, b:Badge):int
			{
				return StringUtil.AlphabeticCompare(a.name, b.name);
			}
		}
		
	}
}