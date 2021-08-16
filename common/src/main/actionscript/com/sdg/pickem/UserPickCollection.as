package com.sdg.pickem
{
	import com.sdg.model.ObjectCollection;

	public class UserPickCollection extends ObjectCollection
	{
		public function UserPickCollection()
		{
			super();
		}
		
		/**
		 * Returns the UserPick with the specified eventId and questionId.
		 */
		public function getPick(eventId:int, questionId:int):UserPick
		{	
			var eventPicks:UserPickCollection = new UserPickCollection();
			var pick:UserPick;
			var i:int = 0;
			var len:int = length;
			for (i; i < len; i++)
			{
				pick = _data[i];
				if (pick.eventId == eventId) eventPicks.push(pick);
			}
			
			i = 0;
			len = eventPicks.length;
			for (i; i < len; i++)
			{
				pick = eventPicks.getAt(i);
				if (pick.questionId == questionId) return pick;
			}
			
			return null;
		}
		
		/**
		 * Returns the item at the specified index.
		 */
		public function getAt(index:int):UserPick
		{	
			return _data[index];
		}
		
		/**
		 * Returns the index of the specified item.
		 */
		public function indexOf(value:UserPick):int
		{
			return _data.indexOf(value);
		}
	
		/**
		 * Returns whether the value exists.
		 */
		public function contains(value:UserPick):Boolean
		{
			return _data.indexOf(value) > -1;
		}
		
		/**
		 * Adds item to the end of the collection.
		 */
		public function push(value:UserPick):uint
		{
			return _data.push(value);
		}
		
		/**
		 * Sets item at specific index within collection.
		 */
		public function setAt(value:UserPick, index:int):void
		{
			_data[index] = value;
		}
		
	}
}