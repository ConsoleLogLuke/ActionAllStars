package com.sdg.leaderboard.model
{
	import com.sdg.model.ObjectCollection;

	public class TopUserCollection extends ObjectCollection
	{
		public function TopUserCollection()
		{
			super();
		}
		
		////////////////////
		// PUBLIC METHODS
		////////////////////
		
		/**
		 * Returns the item at the specified index.
		 */
		public function getAt(index:int):TopUser
		{	
			return _data[index];
		}
		
		/**
		 * Returns the index of the specified item.
		 */
		public function indexOf(value:TopUser):int
		{
			return _data.indexOf(value);
		}
	
		/**
		 * Returns whether the value exists.
		 */
		public function contains(value:TopUser):Boolean
		{
			return _data.indexOf(value) > -1;
		}
		
		/**
		 * Adds item to the end of the collection.
		 */
		public function push(value:TopUser):uint
		{
			return _data.push(value);
		}
		
		/**
		 * Returns the item with specified id.
		 */
		public function getFromId(id:int):TopUser
		{	
			var i:int = 0;
			var len:int = _data.length;
			for (i; i < len; i++)
			{
				var item:TopUser = getAt(i);
				if (item.id == id) return item;
			}
			
			// If we get here, we couldn't find a match.
			return null;
		}
		
	}
}