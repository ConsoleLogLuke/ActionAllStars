package com.sdg.model
{
	public class SdgItemCollection extends ObjectCollection
	{
		public function SdgItemCollection()
		{
			super();
		}
		
		////////////////////
		// INSTANCE METHODS
		////////////////////
		
		/**
		 * Returns the item at the specified index.
		 */
		public function getAt(index:int):SdgItem
		{	
			return _data[index];
		}
		
		/**
		 * Returns the index of the specified item.
		 */
		public function indexOf(value:SdgItem):int
		{
			return _data.indexOf(value);
		}
	
		/**
		 * Returns whether the value exists.
		 */
		public function contains(value:SdgItem):Boolean
		{
			return _data.indexOf(value) > -1;
		}
		
		/**
		 * Adds item to the end of the collection.
		 */
		public function push(value:SdgItem):uint
		{
			return _data.push(value);
		}
		
		/**
		 * Returns the item with specified id.
		 */
		public function getFromId(id:int):SdgItem
		{	
			var i:int = 0;
			var len:int = _data.length;
			var item:SdgItem;
			for (i; i < len; i++)
			{
				item = _data[i] as SdgItem;
				if (item.id == id) return item;
			}
			
			// If we get here, we couldn't find a match.
			return null;
		}
		
		/**
		 * Returns the item with specified id.
		 */
		public function getFromInstanceId(instanceId:int):SdgItem
		{	
			var i:int = 0;
			var len:int = _data.length;
			var item:SdgItem;
			for (i; i < len; i++)
			{
				item = _data[i] as SdgItem;
				if (item.instanceId == instanceId) return item;
			}
			
			// If we get here, we couldn't find a match.
			return null;
		}
		
	}
}