package com.sdg.collections
{
	import mx.events.CollectionEventKind;
	
	public class HashTable extends AbstractOrderedMap implements IOrderedMapCollection
	{
		public function HashTable(source:Object = null)
		{
			data = {};
			if (source) populate(source);
		}
	
		/**
		 * Adds the item to the map at the specified key.
		 */
		public function add(key:Object, value:*):void
		{
			if (data[key] != null) throw new ArgumentError("An item already exists at 'key' [" + key + "].");
			
			data[key] = value;
			keys.push(key);
			
			collectionChanged(CollectionEventKind.ADD, key, null, [value]);
		}
	
		/**
		 * Removes all items in the map.
		 */
		public function removeAll():void
		{
			data = {};
			keys = [];
			
			collectionChanged(CollectionEventKind.RESET);
		}
	}
}