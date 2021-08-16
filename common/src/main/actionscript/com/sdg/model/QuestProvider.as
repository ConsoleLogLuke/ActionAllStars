package com.sdg.model
{
	public class QuestProvider extends Object
	{
		private var _id:int;
		private var _name:String;
		private var _inventoryItemId:int;
		private var _achievements:AchievementCollection;
		
		public function QuestProvider(id:int, name:String, inventoryItemId:int)
		{
			super();
			
			_id = id;
			_name = name;
			_inventoryItemId = inventoryItemId;
		}
		
		////////////////////
		// STATIC METHODS
		////////////////////
		
		public static function ParseQuestProviderXML(xml:XML):QuestProvider
		{
			var id:int = xml.questProviderId;
			var name:String = xml.name;
			var inventoryItemId:int = xml.inventoryItem.inventoryItemId;
			var questProvider:QuestProvider = new QuestProvider(id, name, inventoryItemId);
			return questProvider;
		}
		
		////////////////////
		// PUBLIC METHODS
		////////////////////
		
		public function addAchievement(achievement:Achievement):void
		{
			// Make sure the collection exists.
			if (_achievements == null) _achievements = new AchievementCollection();
			// Make sure an achievement with the same id does not exist in the collection.
			var currentAchievement:Achievement = _achievements.getFromId(achievement.id);
			if (currentAchievement == null)
			{
				// Append the new achievement to the collection.
				_achievements.push(achievement);
			}
		}
		
		public function mergeAchievements(questProvider:QuestProvider):void
		{
			// Only allow merging of quest providers with the same id.
			if (questProvider.id != _id) return;
			
			var newAchievements:AchievementCollection = questProvider.achievements;
			var i:int = 0;
			var len:int = newAchievements.length;
			var achievement:Achievement;
			for (i; i < len; i++)
			{
				achievement = newAchievements.getAt(i);
				addAchievement(achievement);
			}
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		public function get id():int
		{
			return _id;
		}
		
		public function get name():String
		{
			return _name;
		}
		
		public function get inventoryItemId():int
		{
			return _inventoryItemId;
		}
		
		public function get achievements():AchievementCollection
		{
			// Make sure the collection exists.
			if (_achievements == null) _achievements = new AchievementCollection();
			return _achievements;
		}
		
	}
}