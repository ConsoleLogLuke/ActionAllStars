package com.sdg.collections
{
	import com.sdg.collections.iterators.MapIterator;
	import mx.events.CollectionEventKind;
	
	public class AbstractOrderedMap extends AbstractMapCollection implements IOrderedMapCollection
	{
		protected var _keys:Array = [];
		
		/**
		 * Returns whether the map contains any items.
		 */
		public function get isEmpty():Boolean
		{
			return _keys.length < 1;
		}
		
		/**
		 * Returns the number of items in the map.
		 */
		public function get size():uint
		{
			return _keys.length;
		}
		
		/**
		 * Returns the item at the specified index.
		 */
		public function getByIndex(index:int):*
		{
			return this.get(_keys[index]);
		}
		
		/**
		 * Returns an array of keys.
		 */
		public function getKeys():Array
		{
			return _keys.slice();
		}

		/**
		 * Returns the key at the specified index.
		 */
		public function keyByIndex(index:int):Object
		{
			return _keys[index];
		}
		
		/**
		 * Returns the index of the specified item.
		 */
		public function indexOf(value:*):int
		{
			var key:Object = keyOf(value);
			return _keys.indexOf(key);
		}
	
		/**
		 * Returns the index of the specified key.
		 */
		public function indexOfKey(key:Object):int
		{
			return _keys.indexOf(key);
		}
		
		/**
		 * Removes and returns the item at the specified key.
		 */
		public function remove(key:Object):*
		{
			var index:int = _keys.indexOf(key);
			
			if (index == -1) throw new ArgumentError("Cannot remove item at 'key' [" + key + "]. The item does not exist.");
			
			var item:* = data[key];
			
			delete data[key];
			_keys.splice(index, 1);
			
			collectionChanged(CollectionEventKind.REMOVE, key, null, [item]);
			
			return item;
		}
	
		/**
		 * Removes and returns the item at the specified index.
		 */
		public function removeByIndex(index:int):*
		{
			var key:Object = _keys[index];
			
			if (key == null) throw new ArgumentError("Cannot remove item at 'index' [" + index + "]. The item does not exist.");
			
			var item:* = data[key];
			
			delete data[key];
			_keys.splice(index, 1);
			
			collectionChanged(CollectionEventKind.REMOVE, key, null, [item]);
			
			return item;
		}
		
		/**
		 * Returns an iterator for the map.
		 */
		public function getIterator():IIterator
		{
			return new MapIterator(IMapCollection(this, _keys));
		}
	}
}