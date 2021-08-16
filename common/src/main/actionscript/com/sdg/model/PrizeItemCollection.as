package com.sdg.model
{
	public class PrizeItemCollection extends ObjectCollection
	{
		public function PrizeItemCollection()
		{
			super();
		}
		
		////////////////////
		// INSTANCE METHODS
		////////////////////
		
		/**
		 * Returns the item at the specified index.
		 */
		public function getAt(index:int):PrizeItem
		{	
			return _data[index];
		}
		
		/**
		 * Returns the index of the specified item.
		 */
		public function indexOf(value:PrizeItem):int
		{
			return _data.indexOf(value);
		}
	
		/**
		 * Returns whether the value exists.
		 */
		public function contains(value:PrizeItem):Boolean
		{
			return _data.indexOf(value) > -1;
		}
		
		/**
		 * Adds item to the end of the collection.
		 */
		public function push(value:PrizeItem):uint
		{
			return _data.push(value);
		}
		
		/**
		 * Returns the item with specified id.
		 */
		public function getFromId(id:int):PrizeItem
		{	
			var i:int = 0;
			var len:int = _data.length;
			for (i; i < len; i++)
			{
				var item:PrizeItem = getAt(i);
				if (item.id == id) return item;
			}
			
			// If we get here, we couldn't find a match.
			return null;
		}
		
		/**
		 * Returns the item with specified id.
		 */
		public function getFromInstanceId(instanceId:int):PrizeItem
		{	
			var i:int = 0;
			var len:int = _data.length;
			for (i; i < len; i++)
			{
				var item:PrizeItem = getAt(i);
				if (item.instanceId == instanceId) return item;
			}
			
			// If we get here, we couldn't find a match.
			return null;
		}
		
	}
}