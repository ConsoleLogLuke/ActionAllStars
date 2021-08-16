package com.sdg.model
{

	[Bindable]
	public class AvatarLevel
	{	
		public static const MAX_LEVEL_NUMBER:int = 5;
		
		public var levelId:uint;
		public var levelName:String;
		public var pointsToLevel:uint;
		
		private static const LEVEL_NAMES:Object = 
		{
		   1:"Amateur",
		   2:"Rookie",
		   3:"Pro",
		   4:"Veteran",
		   5:"AllStar"
		};
		
		public static function getFontColor(level:uint):int
		{
			return level == 1 ? 0x666666 : 0xffffff;
		}
		
		public static function getLevelName(level:int):String
		{
			var levelName:String = (LEVEL_NAMES[level] != null) ? LEVEL_NAMES[level] : 'Unknown';
			
			return levelName;
		}
		
		public static function getLevelNameFromSubLevel(subLevel:int):String
		{
			var level:uint = Math.ceil(subLevel / 5);
			var levelName:String = (LEVEL_NAMES[level] != null) ? LEVEL_NAMES[level] : 'Unknown';
			
			return levelName;
		}
	}
}