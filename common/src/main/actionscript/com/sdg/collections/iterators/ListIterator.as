package com.sdg.collections.iterators
{
	import com.sdg.collections.IListCollection;
	import com.sdg.collections.IIterator;
	import flash.errors.IllegalOperationError;
	
	public class ListIterator implements IIterator
	{	
		private var _list:IListCollection;
		private var _index:int = -1;
	
		/**
		 * Returns the current index.
		 */
		public function get location():Object
		{
			return _index;
		}
		
		public function ListIterator(list:IListCollection)
		{
			_list = list;
		}
	
		/**
		 * Resets the iteration _index;
		 */
		public function reset():void
		{
			_index = -1;
		}
	
		/**
		 * Returns whether there remains an item to iterate over.
		 */
		public function hasNext():Boolean
		{
			return _index + 1 < _list.size;
		}

		/**
		 * Returns the next item.
		 */
		public function next():*
		{
			if (++_index >= _list.size) throw new IllegalOperationError("The next location is out of bounds.");
			
			return _list.get(_index);
		}
		
		/**
		 * Removes and returns the current item.
		 */
		public function remove():*
		{
			if (_index < 0 || _index >= _list.size) throw new IllegalOperationError("The current location is out of bounds.");
			
			return _list.remove(_index--);
		}
		
		/**
		 * Removes and returns the next item.
		 */
		public function removeNext():*
		{
			if (_index + 1 >= _list.size) throw new IllegalOperationError("The next location is out of bounds.");
			
			return _list.remove(_index + 1);
		}
	}
}