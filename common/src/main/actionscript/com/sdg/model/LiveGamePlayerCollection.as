package com.sdg.model
{
	public class LiveGamePlayerCollection extends ObjectCollection
	{
		public function LiveGamePlayerCollection()
		{
			super();
		}
		
		////////////////////
		// INSTANCE METHODS
		////////////////////
		
		/**
		 * Returns the item at the specified index.
		 */
		public function getAt(index:int):LiveGamePlayer
		{	
			return _data[index];
		}
		
		/**
		 * Returns the index of the specified item.
		 */
		public function indexOf(value:LiveGamePlayer):int
		{
			return _data.indexOf(value);
		}
	
		/**
		 * Returns whether the value exists.
		 */
		public function contains(value:LiveGamePlayer):Boolean
		{
			return _data.indexOf(value) > -1;
		}
		
		/**
		 * Adds item to the end of the collection.
		 */
		public function push(value:LiveGamePlayer):uint
		{
			return _data.push(value);
		}
		
		/**
		 * Returns the item with specified id.
		 */
		public function getFromId(id:uint):LiveGamePlayer
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