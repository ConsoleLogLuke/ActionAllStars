package com.sdg.model
{
	public class BadgeLevel extends IdObject
	{
		protected var _description:String;
		protected var _rewards:RewardCollection;
		protected var _levelIndex:uint;
		
		public function BadgeLevel(id:uint, name:String, description:String, rewards:RewardCollection, levelIndex:uint)
		{
			super(id, name);
			
			_description = description;
			_rewards = rewards;
			_levelIndex = levelIndex;
		}
		
		////////////////////
		// STATIC METHODS
		////////////////////
		
		public static function BadgeLevelCollectionFromXML(badgeLevelList:XMLList):BadgeLevelCollection
		{
			var i:uint = 0;
			var badgeLevels:BadgeLevelCollection = new BadgeLevelCollection();
			while (badgeLevelList.badgeLevel[i] != null)
			{
				var badgeLevel:BadgeLevel = BadgeLevelFromXML(badgeLevelList.badgeLevel[i]);
				badgeLevels.push(badgeLevel);
				
				i++;
			}
			
			// Sort by level index.
			badgeLevels.sort(indexSort);
			
			return badgeLevels;
			
			function indexSort(a:BadgeLevel, b:BadgeLevel):int
			{
				if (a.levelIndex < b.levelIndex)
				{
					return -1;
				}
				else if (a.levelIndex > b.levelIndex)
				{
					return 1;
				}
				else
				{
					return 0;
				}
			}
		}
		
		public static function BadgeLevelFromXML(badgeLevelXML:XML):BadgeLevel
		{
			// Validate data from XML.
			var id:uint = (badgeLevelXML.@id != null) ? badgeLevelXML.@id : 0;
			var name:String = (badgeLevelXML.name != null) ? badgeLevelXML.name : '';
			var description:String = (badgeLevelXML.description) ? badgeLevelXML.description : '';
			var rewards:RewardCollection = Reward.RewardCollectionFromXML(badgeLevelXML.child('rewards'));
			var levelIndex:uint = (badgeLevelXML.@index != null) ? badgeLevelXML.@index : 0;
			
			var badgeLevel:BadgeLevel = new BadgeLevel(id, name, description, rewards, levelIndex);
			
			return badgeLevel;
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		public function get description():String
		{
			return _description;
		}
		
		public function get rewards():RewardCollection
		{
			return _rewards;
		}
		
		public function get levelIndex():uint
		{
			return _levelIndex;
		}
		
	}
}