package com.sdg.model
{
	import flash.geom.Point;
	
	public class PointCollection extends ObjectCollection
	{
		public function PointCollection()
		{
			super();
		}
		
		/**
		 * Returns the item at the specified index.
		 */
		public function getAt(index:int):Point
		{	
			return _data[index];
		}
		
		/**
		 * Returns the index of the specified item.
		 */
		public function indexOf(value:Point):int
		{
			return _data.indexOf(value);
		}
	
		/**
		 * Returns whether the value exists.
		 */
		public function contains(value:Point):Boolean
		{
			return _data.indexOf(value) > -1;
		}
		
		/**
		 * Adds item to the end of the collection.
		 */
		public function push(value:Point):uint
		{
			return _data.push(value);
		}
	}
}