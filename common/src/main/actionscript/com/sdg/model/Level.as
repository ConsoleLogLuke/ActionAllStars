package com.sdg.model
{
	public class Level extends IdObject
	{
		public static const AMATEUR_COLOR:uint = 0xffffff;
		public static const ROOKIE_COLOR:uint = 0x1a3c69;
		public static const PRO_COLOR:uint = 0x9f091e;
		public static const VETERAN_COLOR:uint = 0xe2a000;
		public static const ALLSTAR_COLOR:uint = 0x000000;
		
		protected var _subLevels:SubLevelCollection;
		protected var _pointsMin:uint;
		protected var _pointsMax:uint;
		
		protected static const _levelColorMap:Object =
		{
			1: AMATEUR_COLOR,
			2: ROOKIE_COLOR,
			3: PRO_COLOR,
			4: VETERAN_COLOR,
			5: ALLSTAR_COLOR
		}
		
		public function Level(id:uint, name:String, subLevels:SubLevelCollection, pointsMin:uint, pointsMax:uint)
		{
			super(id, name);
			
			_subLevels = subLevels;
			_pointsMin = pointsMin;
			_pointsMax = pointsMax;
		}
		
		////////////////////
		// STATIC METHODS
		////////////////////
		
		public static function LevelCollectionFromXML(levelList:XMLList):LevelCollection
		{
			var i:uint = 0;
			var levelCollection:LevelCollection = new LevelCollection();
			while (levelList.level[i] != null)
			{
				levelCollection.push(LevelFromXML(levelList.level[i]));
				i++;
			}
			
			return levelCollection;
		}
		
		public static function LevelFromXML(levelXML:XML):Level
		{
			// Validate data from XML.
			var id:uint = (levelXML.levelId != null) ? levelXML.levelId : 0;
			var name:String = (levelXML.levelName != null) ? levelXML.levelName : '';
			var subLevels:SubLevelCollection = SubLevel.SubLevelCollectionFromXML(levelXML);
			
			// Sort sub levels by points.
			subLevels.sort(subLevelSort);
			
			// Determine point range.
			var pointsMin:uint = uint.MAX_VALUE;
			var pointsMax:uint = 0;
			var i:uint = 0;
			var len:uint = subLevels.length;
			for (i; i < len; i++)
			{
				var subLevel:SubLevel = subLevels.getAt(i);
				pointsMin = Math.min(pointsMin, subLevel.pointsToLevel);
				pointsMax = Math.max(pointsMax, subLevel.pointsToLevel);
			}
			
			return new Level(id, name, subLevels, pointsMin, pointsMax);
			
			function subLevelSort(a:SubLevel, b:SubLevel):int
			{
				if (a.pointsToLevel < b.pointsToLevel)
				{
					return -1;
				}
				else if (a.pointsToLevel > b.pointsToLevel)
				{
					return 1;
				}
				else
				{
					return 0;
				}
			}
		}
		
		public static function GetLevelColor(level:uint):uint
		{
			return _levelColorMap[level];
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		public function get subLevels():SubLevelCollection
		{
			return _subLevels;
		}
		
		public function get pointsMin():uint
		{
			return _pointsMin;
		}
		
		public function get pointsMax():uint
		{
			return _pointsMax;
		}
		
		public function get levelColor():uint
		{
			return _levelColorMap[id];
		}
		
	}
}