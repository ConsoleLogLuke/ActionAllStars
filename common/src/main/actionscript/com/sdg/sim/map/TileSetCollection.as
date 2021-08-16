package com.sdg.sim.map
{
	import com.sdg.model.ObjectCollection;

	public class TileSetCollection extends ObjectCollection
	{
		public function TileSetCollection()
		{
			super();
		}
		
		////////////////////
		// INSTANCE METHODS
		////////////////////
		
		/**
		 * Returns the item at the specified index.
		 */
		public function getAt(index:int):TileSet
		{	
			return _data[index];
		}
		
		/**
		 * Returns the index of the specified item.
		 */
		public function indexOf(value:TileSet):int
		{
			return _data.indexOf(value);
		}
	
		/**
		 * Returns whether the value exists.
		 */
		public function contains(value:TileSet):Boolean
		{
			return _data.indexOf(value) > -1;
		}
		
		/**
		 * Adds item to the end of the collection.
		 */
		public function push(value:TileSet):uint
		{
			return _data.push(value);
		}
		
		/**
		 * Returns the item with specified id.
		 */
		public function getFromId(id:int):TileSet
		{	
			var i:int = 0;
			var len:int = _data.length;
			for (i; i < len; i++)
			{
				var item:TileSet = getAt(i);
				if (item.id == id) return item;
			}
			
			// If we get here, we couldn't find a match.
			return null;
		}
		
		/**
		 * Returns a collection of items that have the specified id.
		 */
		public function getMultipleFromId(id:int):TileSetCollection
		{	
			var i:int = 0;
			var len:int = _data.length;
			var collection:TileSetCollection = new TileSetCollection();
			for (i; i < len; i++)
			{
				var item:TileSet = getAt(i);
				if (item.id == id) collection.push(item);
			}
			
			// Return the collection.
			return collection;
		}
		
		/**
		 * Returns the item with specified value.
		 */
		public function getFromValue(value:String):TileSet
		{	
			var i:int = 0;
			var len:int = _data.length;
			for (i; i < len; i++)
			{
				var item:TileSet = getAt(i);
				if (item.value == value) return item;
			}
			
			// If we get here, we couldn't find a match.
			return null;
		}
		
		/**
		 * Returns a collection of items that have the specified value.
		 */
		public function getMultipleFromValue(value:String):TileSetCollection
		{	
			var i:int = 0;
			var len:int = _data.length;
			var collection:TileSetCollection = new TileSetCollection();
			for (i; i < len; i++)
			{
				var item:TileSet = getAt(i);
				if (item.value == value) collection.push(item);
			}
			
			// Return the collection.
			return collection;
		}
		
	}
}