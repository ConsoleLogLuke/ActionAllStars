package com.sdg.collections
{
	import com.sdg.collections.iterators.MapIterator;
	import mx.events.CollectionEventKind;
	
	public class AbstractUnorderedMap extends AbstractMapCollection
	{
		protected var count:int = 0;
		
		/**
		 * Returns whether the map contains any items.
		 */
		public function get isEmpty():Boolean
		{
			return count < 1;
		}
		
		/**
		 * Returns the number of items in the map.
		 */
		public function get size():uint
		{
			return count;
		}
		
		/**
		 * Returns an array of keys.
		 */
		public function getKeys():Array
		{
			var a:Array = [];
			
			for (var o:Object in data) a.push(o);
			
			return a;
		}
		
		/**
	    * Removes and returns the item at the specified key.
	    */
		public function remove(key:Object):*
		{
			var item:* = this.get(key);
			
			if (item == null) throw new ArgumentError("Cannot remove item at 'key' [" + key + "]. The item does not exist.");
			
			delete data[key];
		
			count--;
			
			collectionChanged(CollectionEventKind.REMOVE, key, null, [item]);
			
			return item;
		}
		
		/**
		 * Returns an iterator for the map.
		 */
		public function getIterator():IIterator
		{
			return new MapIterator(IMapCollection(this), getKeys());
		}
	}
}