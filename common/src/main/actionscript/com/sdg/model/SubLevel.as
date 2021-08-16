package com.sdg.model
{
	public class SubLevel extends IdObject
	{
		protected var _pointsToLevel:uint;
		protected var _number:uint;
		
		public function SubLevel(id:uint, name:String, number:uint, pointsToLevel:uint)
		{
			super(id, name);
			
			_number = number;
			_pointsToLevel = pointsToLevel;
		}
		
		////////////////////
		// STATIC METHODS
		////////////////////
		
		public static function SubLevelCollectionFromXML(levelXML:XML):SubLevelCollection
		{
			var i:uint = 0;
			var subLevelCollection:SubLevelCollection = new SubLevelCollection();
			while (levelXML.subLevel[i] != null)
			{
				subLevelCollection.push(SubLevelFromXML(levelXML.subLevel[i]));
				i++;
			}
			
			return subLevelCollection;
		}
		
		public static function SubLevelFromXML(subLevelXML:XML):SubLevel
		{
			// Validate data from XML.
			var id:uint = (subLevelXML.subLevelId != null) ? subLevelXML.subLevelId : 0;
			var name:String = (subLevelXML.subLevelName != null) ? subLevelXML.subLevelName : '';
			var pointsToLevel:uint = (subLevelXML.pointsToLevel != null) ? subLevelXML.pointsToLevel : uint.MAX_VALUE;
			var number:uint = (subLevelXML.subLevelOrder != null) ? subLevelXML.subLevelOrder : 0;
			
			return new SubLevel(id, name, number, pointsToLevel);
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		public function get pointsToLevel():uint
		{
			return _pointsToLevel;
		}
		
		public function get number():uint
		{
			return _number;
		}
		
	}
}