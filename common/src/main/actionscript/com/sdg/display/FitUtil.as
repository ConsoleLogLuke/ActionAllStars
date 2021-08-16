package com.sdg.display
{
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;
	
	public class FitUtil extends Object
	{
		public static function FitDisplayObject(object:DisplayObject, fitArea:Rectangle, fitType:String):void
		{
			var xScale:Number = fitArea.width / object.width;
			var yScale:Number = fitArea.height / object.height;
			
			// Fit display object.
			if (fitType == FitType.FIT_MAX)
			{
				object.scaleX = object.scaleY = Math.max(xScale, yScale);
			}
			else if (fitType == FitType.FIT_WITHIN)
			{
				object.scaleX = object.scaleY = Math.min(xScale, yScale);
			}
			else if (fitType == FitType.FIT_STRETCH)
			{
				object.scaleX = xScale;
				object.scaleY = yScale;
			}
			else
			{
				throw(new Error('Unrecognized fit type: ' + fitType + '.'));
			}
		}
		
	}
}