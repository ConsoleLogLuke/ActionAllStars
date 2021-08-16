package com.sdg.collections
{
	import flash.events.IEventDispatcher;
	
	public interface ICollection extends IEventDispatcher
	{
		/**
		 * Returns the number of items in the collection.
		 */
		function get size():uint;
	
		/**
		 * Returns whether the collection contains any items.
		 */
		function get isEmpty():Boolean;
	
		/**
		 * Removes all of the items in the collection.
		 */
		function removeAll():void;

		/**
		 * Returns whether the value exists.
		 */
		function contains(value:*):Boolean;

		/**
		 * Returns an array of all the items in the collection.
		 */
		function toArray():Array;

		/**
		 * Returns an iterator for the collection.
		 */
		function getIterator():IIterator;
	}
}