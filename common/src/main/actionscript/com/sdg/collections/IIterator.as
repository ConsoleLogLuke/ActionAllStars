package com.sdg.collections
{
	public interface IIterator
	{
		/**
		 * Returns the current index, key or linked list item of the iterator.
		 */
		function get location():Object;
		
		/**
		 * Resets the iterator to its starting location.
		 */
		function reset():void;

		/**
		 * Returns whether there remains an item to iterate over.
		 */
		function hasNext():Boolean;

		/**
		 * Returns the next item.
		 */
		function next():*;

		/**
		 * Removes and returns the current item.
		 */
		function remove():*;
		
		/**
		 * Removes and returns the next item.
		 */
		function removeNext():*
	}
}