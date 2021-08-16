package com.sdg.model
{
	public class ServerModelCollection extends ObjectCollection
	{
		public function ServerModelCollection()
		{
			super();
		}
		
		////////////////////
		// INSTANCE METHODS
		////////////////////
		
		/**
		 * Returns the item at the specified index.
		 */
		public function getAt(index:int):ServerModel
		{	
			return _data[index];
		}
		
		/**
		 * Returns the index of the specified item.
		 */
		public function indexOf(value:ServerModel):int
		{
			return _data.indexOf(value);
		}
	
		/**
		 * Returns whether the value exists.
		 */
		public function contains(value:ServerModel):Boolean
		{
			return _data.indexOf(value) > -1;
		}
		
		/**
		 * Adds item to the end of the collection.
		 */
		public function push(value:ServerModel):uint
		{
			return _data.push(value);
		}
		
		/**
		 * Returns the item with specified id.
		 */
		public function getFromId(id:int):ServerModel
		{	
			var i:int = 0;
			var len:int = _data.length;
			for (i; i < len; i++)
			{
				var item:ServerModel = getAt(i);
				if (item.id == id) return item;
			}
			
			// If we get here, we couldn't find a match.
			return null;
		}
		
	}
}