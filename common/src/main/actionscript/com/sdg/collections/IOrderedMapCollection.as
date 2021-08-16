package com.sdg.collections
{
	public interface IOrderedMapCollection extends IMapCollection
	{
		/**
		 * Returns the item at the specified index.
		 */
		function getByIndex(index:int):*
		
		/**
		 * Returns the key at the specified index.
		 */
		function keyByIndex(index:int):Object
		
		/**
		 * Returns the index of the specified item.
		 */
		function indexOf(value:*):int
	
		/**
		 * Returns the index of the specified key.
		 */
		function indexOfKey(key:Object):int
		
		/**
		 * Removes and returns the item at the specified index.
		 */
		function removeByIndex(index:int):*
	}
}