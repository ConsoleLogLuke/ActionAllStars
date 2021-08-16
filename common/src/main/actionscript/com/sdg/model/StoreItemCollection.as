package com.sdg.model
{
	public class StoreItemCollection extends ObjectCollection
	{
		public function StoreItemCollection()
		{
			super();
		}
		
		////////////////////
		// INSTANCE METHODS
		////////////////////
		
		/**
		 * Returns the item at the specified index.
		 */
		public function getAt(index:int):StoreItem
		{	
			return _data[index];
		}
		
		/**
		 * Returns the index of the specified item.
		 */
		public function indexOf(value:StoreItem):int
		{
			return _data.indexOf(value);
		}
	
		/**
		 * Returns whether the value exists.
		 */
		public function contains(value:StoreItem):Boolean
		{
			return _data.indexOf(value) > -1;
		}
		
		/**
		 * Adds item to the end of the collection.
		 */
		public function push(value:StoreItem):uint
		{
			return _data.push(value);
		}
		
		/**
		 * Returns the item with specified id.
		 */
		public function getFromId(id:int):StoreItem
		{	
			var i:int = 0;
			var len:int = _data.length;
			for (i; i < len; i++)
			{
				var item:StoreItem = getAt(i);
				if (item.id == id) return item;
			}
			
			// If we get here, we couldn't find a match.
			return null;
		}
		
	}
}