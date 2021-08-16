package com.sdg.model
{
	public class SubLevelCollection extends ObjectCollection
	{
		public function SubLevelCollection()
		{
			super();
		}
		
		////////////////////
		// INSTANCE METHODS
		////////////////////
		
		/**
		 * Returns the item at the specified index.
		 */
		public function getAt(index:int):SubLevel
		{	
			return _data[index];
		}
		
		/**
		 * Returns the index of the specified item.
		 */
		public function indexOf(value:SubLevel):int
		{
			return _data.indexOf(value);
		}
	
		/**
		 * Returns whether the value exists.
		 */
		public function contains(value:SubLevel):Boolean
		{
			return _data.indexOf(value) > -1;
		}
		
		/**
		 * Adds item to the end of the collection.
		 */
		public function push(value:SubLevel):uint
		{
			return _data.push(value);
		}
		
		/**
		 * Returns the item with specified id.
		 */
		public function getFromId(id:int):SubLevel
		{	
			var i:int = 0;
			var len:int = _data.length;
			for (i; i < len; i++)
			{
				var object:SubLevel = getAt(i);
				if (object.id == id) return object;
			}
			
			// If we get here, we couldn't find a match.
			return null;
		}
		
		/**
		 * Adds item to the end of the collection.
		 */
		public function sortByPointsToLevel(ascending:Boolean = true):void
		{
			var dir:int = (ascending) ? 1 : -1;
			
			sort(pointSort);
			
			function pointSort(a:SubLevel, b:SubLevel):int
			{
				if (a.pointsToLevel < b.pointsToLevel)
				{
					return -1 * dir;
				}
				else if (a.pointsToLevel > b.pointsToLevel)
				{
					return 1 * dir;
				}
				else
				{
					return 0;
				}
			}
		}
		
	}
}