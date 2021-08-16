package com.sdg.util
{
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;
	
	public class LayoutUtil extends Object
	{
		public static function CenterObject(object:DisplayObject, x:Number, y:Number):void
		{
			var rect:Rectangle = object.getRect(object);
			object.x = x - (rect.width / 2 + rect.x);
			object.y = y - (rect.height / 2 + rect.y);
		}
		
	}
}