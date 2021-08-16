package com.sdg.collections
{
	import flash.utils.Dictionary;
	import mx.events.CollectionEventKind;
	
	public class ObjectMap extends AbstractUnorderedMap implements IMapCollection
	{
		public function ObjectMap(weakKeys:Boolean = false, source:Object = null)
		{
			data = new Dictionary(weakKeys);
			if (source) populate(source);
		}
	
		/**
		 * Adds the item to the map at the specified key.
		 */
		public function add(key:Object, value:*):void
		{
			if (data[key] != null) throw new ArgumentError("An item already exists at 'key' [" + key + "].");
			
			data[key] = value;

			count++;
			
			collectionChanged(CollectionEventKind.ADD, key, null, [value]);
		}
		
		/**
		 * Adds the key to the map, referenced by itself.
		 */
		public function addKey(key:Object):void
		{
			if (data[key] != null) throw new ArgumentError("An item already exists at 'key' [" + key + "].");
			
			data[key] = key;

			count++;
			
			collectionChanged(CollectionEventKind.ADD, key, null, [key]);
		}
		
		/**
	    * Removes all items in the map.
	    */
		public function removeAll():void
		{
			data = new Dictionary();
			count = 0;
			
			collectionChanged(CollectionEventKind.RESET);
		}
	}
}