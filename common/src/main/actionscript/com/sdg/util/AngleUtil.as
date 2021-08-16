package com.sdg.util
{
	public class AngleUtil extends Object
	{
		public static function DegreesToRadians(degrees:Number):Number
		{
			return (degrees / 360) * (Math.PI * 2);
		}
		
		public static function RadiansToDegrees(radians:Number):Number
		{
			return (radians / (Math.PI * 2)) * 360;
		}
		
	}
}