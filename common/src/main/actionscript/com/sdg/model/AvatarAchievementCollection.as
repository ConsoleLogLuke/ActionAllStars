package com.sdg.model
{
	public class AvatarAchievementCollection extends ObjectCollection
	{
		public function AvatarAchievementCollection()
		{
			super();
		}
		
		////////////////////
		// STATIC METHODS
		////////////////////
		
		public static function ParseMultipleAvatarAchievementsXML(xml:XMLList):AvatarAchievementCollection
		{
			var i:int = 0;
			var avatarAchievementXML:XML;
			var avatarAchievement:AvatarAchievement;
			var collection:AvatarAchievementCollection = new AvatarAchievementCollection();
			while (xml.avatarAchievement[i] != null)
			{
				avatarAchievementXML = xml.avatarAchievement[i];
				avatarAchievement = AvatarAchievement.ParseAvatarAchievementXML(avatarAchievementXML);
				if (avatarAchievement != null) collection.push(avatarAchievement);
				i++;
			}
			return collection;
		}
		
		////////////////////
		// INSTANCE METHODS
		////////////////////
		
		/**
		 * Return an array of achievement id's for avatar achievements from this list
		 * that have been completed.
		 * array[achievementId] = true;
		 */	
		public function getCompletedAchievementIdArray():Array
		{
			// Determine which pieces have been found and pass
			// an array with those values to the movie.
			var i:uint = 0;
			var len:uint = _data.length;
			var array:Array = [];
			for (i; i < len; i++)
			{
				var avatarAchievement:AvatarAchievement = _data[i];
				// Make sure the achievement is complete.
				if (avatarAchievement.isComplete != true) continue;
				// If the achievement is complete add the value to the array.
				array[avatarAchievement.id.toString()] = true;
			}
			
			return array;
		}
		
		/**
		 * Returns the item at the specified index.
		 */
		public function getAt(index:int):AvatarAchievement
		{	
			return _data[index];
		}
		
		/**
		 * Returns the index of the specified item.
		 */
		public function indexOf(value:AvatarAchievement):int
		{
			return _data.indexOf(value);
		}
	
		/**
		 * Returns whether the value exists.
		 */
		public function contains(value:AvatarAchievement):Boolean
		{
			return _data.indexOf(value) > -1;
		}
		
		/**
		 * Adds item to the end of the collection.
		 */
		public function push(value:AvatarAchievement):uint
		{
			return _data.push(value);
		}
		
		/**
		 * Returns the item with specified id.
		 */
		public function getFromId(id:int):AvatarAchievement
		{	
			var i:int = 0;
			var len:int = _data.length;
			var achievement:AvatarAchievement;
			for (i; i < len; i++)
			{
				achievement = _data[i] as AvatarAchievement;
				if (achievement.id == id) return achievement;
			}
			
			// If we get here, we couldn't find a match.
			return null;
		}
		
		/**
		 * Returns items with specified criteria attribute id.
		 */
		public function getFromCriteriaAttributeId(attributeId:int):AvatarAchievementCollection
		{	
			var i:int = 0;
			var len:int = _data.length;
			var collection:AvatarAchievementCollection = new AvatarAchievementCollection();
			for (i; i < len; i++)
			{
				// Get reference to avatar achievement.
				var item:AvatarAchievement = _data[i];
				// Determine if any criteria match the input attribute id.
				// If we found a matching criteria attribute id,
				// add the avatar achievement to the collection.
				if (item.getCriteriaWithAttributeId(attributeId).length > 0) collection.push(item);
			}
			
			// Return collection.
			return collection;
		}
		
	}
}