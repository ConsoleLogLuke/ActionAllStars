package com.sdg.utils
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	
	public class BitmapUtil
	{
		public static function createCheckeredPalette(transparent:Boolean, colors:Array):BitmapData
		{
			var l:int = colors.length;
			var c:Array = l ? colors : [0];
			
			var bmp:BitmapData = new BitmapData(2, 2, transparent, colors[0]);
			
			if (transparent)
			{
				if (!isNaN(colors[1])) bmp.setPixel32(1, 0, colors[1]);
				if (!isNaN(colors[2])) bmp.setPixel32(1, 1, colors[2]);
				if (!isNaN(colors[3])) bmp.setPixel32(0, 1, colors[3]);
				else if (!isNaN(colors[1])) bmp.setPixel32(0, 1, colors[1]);
			}
			else
			{
				if (!isNaN(colors[1])) bmp.setPixel(1, 0, colors[1]);
				if (!isNaN(colors[2])) bmp.setPixel(1, 1, colors[2]);
				if (!isNaN(colors[3])) bmp.setPixel(0, 1, colors[3]);
				else if (!isNaN(colors[1])) bmp.setPixel(0, 1, colors[1]);
			}
			
			return bmp;
		}
		
		public static function getAlphaBounds(bmp:BitmapData):Rectangle
		{
			return bmp.getColorBoundsRect(0xFF000000, 0, false);
		}
		
		public static function spriteToBitmap(input:Sprite,smooth:Boolean=false):Bitmap
		{
			var output:Bitmap;
			var bitmapCopy:BitmapData = new BitmapData(input.width,input.height);
			bitmapCopy.draw(input);
			//output = new Bitmap(bitmapCopy);
			output = new Bitmap(bitmapCopy,"auto",smooth);
			return output;
		}
	}
}