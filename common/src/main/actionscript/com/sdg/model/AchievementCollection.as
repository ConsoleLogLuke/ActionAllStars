package com.sdg.model
{
	public class AchievementCollection extends ObjectCollection
	{
		public function AchievementCollection()
		{
			super();
		}
		
		////////////////////
		// STATIC METHODS
		////////////////////
		
		public static function ParseMultipleAchievementsXML(xml:XMLList):AchievementCollection
		{
			var i:int = 0;
			var achievementXML:XML;
			var achievement:Achievement;
			var collection:AchievementCollection = new AchievementCollection();
			while (xml.achievement[i] != null)
			{
				achievementXML = xml.achievement[i];
				achievement = Achievement.ParseAchievementXML(achievementXML);
				if (achievement != null) collection.push(achievement);
				i++;
			}
			return collection;
		}
		
		////////////////////
		// INSTANCE METHODS
		////////////////////
		
		/**
		 * Returns the item at the specified index.
		 */
		public function getAt(index:int):Achievement
		{	
			return _data[index];
		}
		
		/**
		 * Returns the index of the specified item.
		 */
		public function indexOf(value:Achievement):int
		{
			return _data.indexOf(value);
		}
	
		/**
		 * Returns whether the value exists.
		 */
		public function contains(value:Achievement):Boolean
		{
			return _data.indexOf(value) > -1;
		}
		
		/**
		 * Adds item to the end of the collection.
		 */
		public function push(value:Achievement):uint
		{
			return _data.push(value);
		}
		
		/**
		 * Returns the item with specified id.
		 */
		public function getFromId(id:int):Achievement
		{	
			var i:int = 0;
			var len:int = _data.length;
			var achievement:Achievement;
			for (i; i < len; i++)
			{
				achievement = _data[i] as Achievement;
				if (achievement.id == id) return achievement;
			}
			
			// If we get here, we couldn't find a match.
			return null;
		}
		
	}
}