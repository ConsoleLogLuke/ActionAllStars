package com.sdg.collections
{
	import com.sdg.collections.iterators.MapIterator;
	import flash.errors.IllegalOperationError; // Non-SDG
	import mx.events.CollectionEventKind;

	public class AbstractOrderedMap extends AbstractMapCollection implements IOrderedMapCollection
	{
		protected var keys:Array = []; // Non-SDG - _keys to keys

		/**
		 * Returns whether the map contains any items.
		 */
		public function get isEmpty():Boolean
		{
			return keys.length < 1; // Non-SDG - _keys to keys
		}

		/**
		 * Returns the number of items in the map.
		 */
		public function get size():uint
		{
			return keys.length; // Non-SDG - _keys to keys
		}

		/**
		 * Returns the item at the specified index.
		 */
		public function getByIndex(index:int):*
		{
			return this.get(keys[index]); // Non-SDG - _keys to keys
		}

		/**
		 * Returns an array of keys.
		 */
		public function getKeys():Array
		{
			return keys.slice(); // Non-SDG - _keys to keys
		}

		/**
		 * Returns the key at the specified index.
		 */
		public function keyByIndex(index:int):Object
		{
			return keys[index]; // Non-SDG - _keys to keys
		}

		/**
		 * Returns the index of the specified item.
		 */
		public function indexOf(value:*):int
		{
			var key:Object = keyOf(value);
			return keys.indexOf(key); // Non-SDG - _keys to keys
		}

		/**
		 * Returns the index of the specified key.
		 */
		public function indexOfKey(key:Object):int
		{
			return keys.indexOf(key); // Non-SDG - _keys to keys
		}

		/**
		 * Removes and returns the item at the specified key.
		 */
		public function remove(key:Object):*
		{
			var index:int = keys.indexOf(key); // Non-SDG - _keys to keys

			if (index == -1) throw new ArgumentError("Cannot remove item at 'key' [" + key + "]. The item does not exist.");

			var item:* = data[key];

			delete data[key];
			keys.splice(index, 1); // Non-SDG - _keys to keys

			collectionChanged(CollectionEventKind.REMOVE, key, null, [item]);

			return item;
		}

		/**
		 * Removes and returns the item at the specified index.
		 */
		public function removeByIndex(index:int):*
		{
			var key:Object = keys[index]; // Non-SDG - _keys to keys

			if (key == null) throw new ArgumentError("Cannot remove item at 'index' [" + index + "]. The item does not exist.");

			var item:* = data[key];

			delete data[key];
			keys.splice(index, 1); // Non-SDG - _keys to keys

			collectionChanged(CollectionEventKind.REMOVE, key, null, [item]);

			return item;
		}

		/**
		 * Returns an iterator for the map.
		 */
		public function getIterator():IIterator
		{
			return new MapIterator(IMapCollection(this), keys); // Non-SDG - fix small mistake and change _keys to keys
		}

		// Non-SDG start
		public function add(key:Object, value:*):void
		{
			throw new IllegalOperationError("add has not been implemented in the AbstractOrderedMap class");
		}

		public function removeAll():void
		{
			throw new IllegalOperationError("removeAll has not been implemented in the AbstractOrderedMap class");
		}
		// Non-SDG end
	}
}
