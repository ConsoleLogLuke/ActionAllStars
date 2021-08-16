package com.sdg.model
{
	public class BadgeCategory extends IdObject
	{
		protected var _description:String;
		
		public function BadgeCategory(id:uint, name:String, description:String)
		{
			super(id, name);
			
			_description = description;
		}
		
		////////////////////
		// STATIC METHODS
		////////////////////
		
		public static function BadgeCategoryCollectionFromXML(badgeCategoryList:XMLList):BadgeCategoryCollection
		{
			var i:uint = 0;
			var badgeCategories:BadgeCategoryCollection = new BadgeCategoryCollection();
			while (badgeCategoryList.badgeCategory[i] != null)
			{
				var badgeCategory:BadgeCategory = BadgeCategoryFromXML(badgeCategoryList.badgeCategory[i]);
				badgeCategories.push(badgeCategory);
				
				i++;
			}
			
			return badgeCategories;
		}
		
		public static function BadgeCategoryFromXML(badgeCategoryXML:XML):BadgeCategory
		{
			// Validate data from XML.
			var id:uint = (badgeCategoryXML.@id != null) ? badgeCategoryXML.@id : 0;
			var name:String = (badgeCategoryXML.name != null) ? badgeCategoryXML.name : '';
			var description:String = (badgeCategoryXML.description) ? badgeCategoryXML.description : '';
			
			var badgeCategory:BadgeCategory = new BadgeCategory(id, name, description);
			
			return badgeCategory;
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		public function get description():String
		{
			return _description;
		}
		
	}
}