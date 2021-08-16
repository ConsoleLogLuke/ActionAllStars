package com.sdg.collections
{
	import flash.errors.IllegalOperationError;
	import mx.events.CollectionEventKind;
	
	public class HashMap extends AbstractUnorderedMap implements IMapCollection
	{
		public function HashMap(source:Object = null)
		{
			data = {};
			if (source) populate(source);
		}
	
		/**
		 * Adds the element to the map at the specified key.
		 */
		public function add(key:Object, value:*):void
		{
			if (data[key] != null) throw new ArgumentError("An item already exists at 'key' [" + key + "].");
			
			data[key] = value;
			
			count++;
			
			collectionChanged(CollectionEventKind.ADD, key, null, [value]);
		}
		
		/**
	    * Removes all items in the map.
	    */
		public function removeAll():void
		{
			data = {};
			count = 0;
			
			collectionChanged(CollectionEventKind.RESET);
		}
	}
}