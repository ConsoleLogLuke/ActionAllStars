package com.sdg.utils
{
	public class GameUtil
	{
		import com.sdg.model.AvatarLevel;
		import com.sdg.model.ModelLocator;
		
		// normalize percentage
		
		public static function normalizePercentage(level:int, points:int):Number
		{
			var percent:int;
			
			if (level >= AvatarLevel.MAX_LEVEL_NUMBER)
				percent = 100;
			else
			{
				var basePercentage:int = 25 * (level - 1);
				var nextLevel:int = level + 1;
				
				var nextPointTrigger:int = ModelLocator.getInstance().avatarLevels[nextLevel].pointsToLevel;
				var previousTrigger:int = ModelLocator.getInstance().avatarLevels[level].pointsToLevel;
				var gap:int = nextPointTrigger - previousTrigger;
				var normalizedPoints:int = points - previousTrigger;
				var relativePercentage:Number = 100 * (normalizedPoints / gap);
				percent = basePercentage + Math.floor(relativePercentage / (AvatarLevel.MAX_LEVEL_NUMBER - 1));
			}

			return percent;
		}
		
		public static function percentageToNextLevel(level:int, points:int):Number
		{
			if (level >= AvatarLevel.MAX_LEVEL_NUMBER)
				return 100;
				
			var nextLevel:int = level + 1;
			var nextPointTrigger:int = ModelLocator.getInstance().avatarLevels[nextLevel].pointsToLevel;
			var previousTrigger:int = ModelLocator.getInstance().avatarLevels[level].pointsToLevel;
			var gap:int = nextPointTrigger - previousTrigger;
			var normalizedPoints:int = points - previousTrigger;
			var percentage:Number = 100 * (normalizedPoints / gap);
			
			return percentage;
		}
	}
}