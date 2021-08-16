package com.sdg.model
{
	public class IdObjectCollection extends ObjectCollection
	{
		public function IdObjectCollection(array:Array = null)
		{
			super();
			
			if (array)
			{
				var i:uint = 0;
				var len:uint = array.length;
				for (i; i < len; i++)
				{
					var item:IIdObject = array[i] as IIdObject;
					if (item) push(item);
				}
			}
		}
		
		////////////////////
		// INSTANCE METHODS
		////////////////////
		
		/**
		 * Returns the item at the specified index.
		 */
		public function getAt(index:int):IIdObject
		{	
			return _data[index];
		}
		
		/**
		 * Returns the index of the specified item.
		 */
		public function indexOf(value:IIdObject):int
		{
			return _data.indexOf(value);
		}
	
		/**
		 * Returns whether the value exists.
		 */
		public function contains(value:IIdObject):Boolean
		{
			return _data.indexOf(value) > -1;
		}
		
		/**
		 * Adds item to the end of the collection.
		 */
		public function push(value:IIdObject):uint
		{
			return _data.push(value);
		}
		
		/**
		 * Returns the item with specified id.
		 */
		public function getFromId(id:int):IIdObject
		{	
			var i:int = 0;
			var len:int = _data.length;
			for (i; i < len; i++)
			{
				var item:IIdObject = getAt(i);
				if (item.id == id) return item;
			}
			
			// If we get here, we couldn't find a match.
			return null;
		}
		
	}
}