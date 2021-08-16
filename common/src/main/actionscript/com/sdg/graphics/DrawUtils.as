package com.sdg.graphics
{

	import flash.display.Sprite;

	public class DrawUtils extends Object {
		
		public static function DrawRoundRect(obj:Sprite, width:Number, height:Number, corner:Number):void
		{
			// if the corners will be atleast half the width and height
			// draw an elipse instead
			if (corner >= width / 2 && corner >= height / 2)
			{
				if (width > height)
				{
					corner = height / 2;
				}
				else
				{
					corner = width / 2;
				}
				obj.graphics.drawCircle(width / 2, height / 2, corner);
			}
			else
			{
				obj.graphics.moveTo(corner, 0);
				obj.graphics.lineTo(width-corner, 0);
				obj.graphics.curveTo(width, 0, width, corner);
				obj.graphics.lineTo(width, height-corner);
				obj.graphics.curveTo(width, height, width-corner, height);
				obj.graphics.lineTo(corner, height);
				obj.graphics.curveTo(0, height, 0, height-corner);
				obj.graphics.lineTo(0, corner);
				obj.graphics.curveTo(0, 0, corner, 0);
			}
		}
	}
}