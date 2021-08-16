package com.sdg.collections
{
	public interface IListCollection extends ICollection
	{	
		/**
		 * Adds the item to the collection.
		 */
		function add(value:*):void;
	
		/**
		 * Adds the contents of the collection to the list.
		 * The collection can be an array or an implementation of the ICollection interface.
		 */
		function addAll(collection:*):Array;

		/**
		 * Inserts the item at the specified index.
		 */
		function put(index:int, value:*):void;

		/**
		 * Inserts the contents of the collection into the list at the specified index.
		 * The collection can be an array or an implementation of the ICollection interface.
		 */
		function putAll(index:int, collection:*):void;
	
		/**
		 * Overwrites the item at the specified index.
		 */
		function set(index:int, value:*):void;
	
		/**
		 * Returns the item at the specified index.
		 */
		function get(index:int):*;
	
		/**
		 * Returns the index of the specified item.
		 */
		function indexOf(value:*):int;
	
		/**
		 * Removes and returns a single item at the specified index.
		 */
		function remove(index:int):*;
	}
}