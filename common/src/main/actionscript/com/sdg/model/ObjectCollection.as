package com.sdg.model
{
	public class ObjectCollection extends Object
	{
		protected var _data:Array;
		
		public function ObjectCollection()
		{
			super();
			
			_data = [];
		}
		
		public function empty():void
		{
			_data = [];
		}
		
		public function get length():uint
		{
			return _data.length;
		}
		
		public function get isEmpty():Boolean
		{
			return _data.length < 1;
		}
		
		/**
		 * Remove item at specified index.
		 * Shift remainging values if necesary.
		 */
		public function removeAt(index:int):Array
		{
			return _data.splice(index, 1);
		}
		
		/**
		 * Sorts the elements in an array.
		 */
		public function sort(compareFunction:Function = null):void
		{
			_data.sort(compareFunction);
		}
		
		/**
		 * Reverses the array in place.
		 */
		public function reverse():Array
		{
			return _data.reverse();
		}
		
		/**
		 * Return a copy of the array.
		 */
		public function toArray():Array
		{
			return _data.concat();
		}
		
	}
}