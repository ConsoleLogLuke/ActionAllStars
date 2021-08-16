package com.sdg.model
{
	public class LiveGameCollection extends ObjectCollection
	{
		public function LiveGameCollection()
		{
			super();
		}
		
		////////////////////
		// INSTANCE METHODS
		////////////////////
		
		/**
		 * Returns the item at the specified index.
		 */
		public function getAt(index:int):LiveGame
		{	
			return _data[index];
		}
		
		/**
		 * Returns the index of the specified item.
		 */
		public function indexOf(value:LiveGame):int
		{
			return _data.indexOf(value);
		}
	
		/**
		 * Returns whether the value exists.
		 */
		public function contains(value:LiveGame):Boolean
		{
			return _data.indexOf(value) > -1;
		}
		
		/**
		 * Adds item to the end of the collection.
		 */
		public function push(value:LiveGame):uint
		{
			return _data.push(value);
		}
		
		/**
		 * Returns the item with specified id.
		 */
		public function getFromId(id:String):LiveGame
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