package com.sdg.utils
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	
	public class DisplayUtil
	{
		public static function createHitArea():Sprite
		{
			var hitArea:Sprite = new Sprite();
			hitArea.mouseEnabled = false;
			hitArea.visible = false;
			return hitArea;
		}
		
		public static function getAlphaBounds(display:DisplayObject):Rectangle
		{
			var bmp:BitmapData;
			
			if (display is Bitmap)
			{
				bmp = Bitmap(display).bitmapData;
				if (!bmp) return new Rectangle();
			}
			else
			{
				var width:uint = Math.ceil(display.width);
				var height:uint = Math.ceil(display.height);
				
				if (width == 0 || height == 0) return new Rectangle();
				
				bmp = new BitmapData(width, height, true, 0);
				bmp.draw(display);
			}
			
			return bmp.getColorBoundsRect(0xFF000000, 0, false);
		}
		
		/**
		 * Returns a bitmap image of the given DisplayObject object
		 */ 
		public static function displayObjectToBitmap(displayObject:DisplayObject, rect:Rectangle = null):Bitmap
		{
			var rectToDraw:Rectangle = rect;
			if (!rectToDraw)
				rectToDraw = new Rectangle(0, 0, displayObject.width, displayObject.height);
			
			var bd:BitmapData = new BitmapData(rectToDraw.width, rectToDraw.height, true, 0);
			bd.draw(displayObject, null, null, null, rectToDraw);
			
        	return new Bitmap(bd);
		}
	}
}