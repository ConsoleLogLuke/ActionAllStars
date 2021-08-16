package com.sdg.model
{
	public class FandamoniumPrizeItemCollection extends ObjectCollection
	{
		public function FandamoniumPrizeItemCollection()
		{
			super();
		}
		
		////////////////////
		// INSTANCE METHODS
		////////////////////
		
		/**
		 * Returns the item at the specified index.
		 */
		public function getAt(index:int):FandamoniumPrizeItem
		{	
			return _data[index];
		}
		
		/**
		 * Returns the index of the specified item.
		 */
		public function indexOf(value:FandamoniumPrizeItem):int
		{
			return _data.indexOf(value);
		}
	
		/**
		 * Returns whether the value exists.
		 */
		public function contains(value:FandamoniumPrizeItem):Boolean
		{
			return _data.indexOf(value) > -1;
		}
		
		/**
		 * Adds item to the end of the collection.
		 */
		public function push(value:FandamoniumPrizeItem):uint
		{
			return _data.push(value);
		}
		
		/**
		 * Returns the item with specified id.
		 */
		public function getFromId(id:int):FandamoniumPrizeItem
		{	
			var i:int = 0;
			var len:int = _data.length;
			for (i; i < len; i++)
			{
				var item:FandamoniumPrizeItem = getAt(i);
				if (item.id == id) return item;
			}
			
			// If we get here, we couldn't find a match.
			return null;
		}
		
		/**
		 * Returns the item with specified id.
		 */
		public function getFromInstanceId(instanceId:int):FandamoniumPrizeItem
		{	
			var i:int = 0;
			var len:int = _data.length;
			for (i; i < len; i++)
			{
				var item:FandamoniumPrizeItem = getAt(i);
				if (item.instanceId == instanceId) return item;
			}
			
			// If we get here, we couldn't find a match.
			return null;
		}
		
	}
}