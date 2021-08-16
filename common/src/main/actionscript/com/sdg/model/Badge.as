package com.sdg.model
{
	public class Badge extends IdObject
	{
		protected var _description:String;
		protected var _badgeCategoryId:uint;
		protected var _levels:BadgeLevelCollection;
		
		public function Badge(id:uint, name:String, description:String, badgeCategoryId:uint, levels:BadgeLevelCollection)
		{
			super(id, name);
			
			_description = description;
			_badgeCategoryId = badgeCategoryId;
			_levels = levels;
		}
		
		////////////////////
		// STATIC METHODS
		////////////////////
		
		public static function BadgeCollectionFromXML(badgeList:XMLList):BadgeCollection
		{
			var i:uint = 0;
			var badges:BadgeCollection = new BadgeCollection();
			while (badgeList.badge[i] != null)
			{
				var badge:Badge = BadgeFromXML(badgeList.badge[i]);
				badges.push(badge);
				
				i++;
			}
			
			return badges;
		}
		
		public static function BadgeFromXML(badgeXML:XML):Badge
		{
			// Validate data from XML.
			var id:uint = (badgeXML.@id != null) ? badgeXML.@id : 0;
			var name:String = (badgeXML.name != null) ? badgeXML.name : '';
			var description:String = (badgeXML.description) ? badgeXML.description : '';
			var badgeCategoryId:uint = (badgeXML.badgeCategory.@categoryId != null) ? badgeXML.badgeCategory.@categoryId : 0;
			var badgeLevels:BadgeLevelCollection = BadgeLevel.BadgeLevelCollectionFromXML(badgeXML.child('badgeLevels'));
			
			var badge:Badge = new Badge(id, name, description, badgeCategoryId, badgeLevels);
			
			return badge;
		}
		
		public function hasMultipleLevels():Boolean
		{
			if (_levels.length > 1)
				return true;
			else
				return false;
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		public function get description():String
		{
			return _description;
		}
		
		public function get badgeCategoryId():uint
		{
			return _badgeCategoryId;
		}
		
		public function get levels():BadgeLevelCollection
		{
			return _levels;
		}
		
	}
}