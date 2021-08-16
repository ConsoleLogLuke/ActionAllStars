package com.sdg.collections
{
	import flash.utils.Dictionary;
	
	/**
	 * A "most recently used" cache
	 */
	public class MruCache
	{
		private var _maxSize:uint;
		private var _dictionary:Dictionary = new Dictionary();
		private var _list:QuickList = new QuickList();
		
		public function MruCache(maxSize:uint = 50):void
		{
			_maxSize = maxSize;
		}
		
		/**
		 * Addes an item to the front of the cache.  If the list
		 * exceeds _maxSize the least recently used item of the cache is removed.
		 */
		public function addElement(key:Object, value:Object):void
		{
			// add the item to our containers
			_dictionary[key] = value;
			_list.insert(0, key);
		
			// remove the least recently used item if we just got larger than the max size
			if (_list.length > _maxSize)
			{
				var key2:Object = _list.pop();
				delete _dictionary[key2];	
			}	
		}
		
		/**
		 * Returns the object for the given key, if it exists, and 
		 * moves it to the top of the list. 
		 */
		public function getElement(key:Object):Object
		{
			var value:Object = _dictionary[key];
			if (value != null)
			{
				_list.removeValue(key);
				_list.insert(0, key);
			}
			
			return value;	
		}
		
		/**
		 * Returns true if the and object for the given key is in this container
		 */
		public function contains(key:Object):Boolean
		{
			return _dictionary[key] != null;
		}
	}
}