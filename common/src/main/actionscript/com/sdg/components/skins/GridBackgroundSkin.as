package com.sdg.components.skins
{
	import com.sdg.utils.BitmapUtil;
	import com.sdg.utils.DrawUtil;
	
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.geom.Matrix;
	
	import mx.skins.ProgrammaticSkin;

	public class GridBackgroundSkin extends ProgrammaticSkin
	{
		public function GridBackgroundSkin()
		{
		}
		
		override protected function updateDisplayList(w:Number, h:Number):void
		{	
			var columns:uint = parent.hasOwnProperty("columns") ? Object(parent).columns : 1;
			var rows:uint = parent.hasOwnProperty("rows") ? Object(parent).rows : 1;
			
			var g:Graphics = graphics;
			g.clear();
			
			var fillColors:Array = getStyle("gridFillColors");
			
			if (fillColors)
			{
				var bmp:BitmapData = BitmapUtil.createCheckeredPalette(false, fillColors);
				
				g.beginBitmapFill(bmp);
				g.drawRect(0, 0, columns, rows);
				g.endFill();
				
				scaleX = w / columns;
				scaleY = h / rows;
			}
			else
			{
				g.beginFill(0, 0);
				g.drawRect(0, 0, w, h);
				g.endFill();
			}
		}
	}
}