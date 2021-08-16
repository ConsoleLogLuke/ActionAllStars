package com.sdg.components.skins
{
	import flash.display.GradientType;
	import flash.geom.Matrix;
	
	import mx.skins.Border;
	import mx.utils.ColorUtil;
	
	public class ButtonSkin extends Border
	{
		override protected function updateDisplayList(w:Number, h:Number):void
		{
			graphics.clear();
			
			var bc:Number = getStyle("borderColor");
			var ba:Number = getStyle("borderAlpha");
			var bt:Number = getStyle("borderThickness");
			var cr1:Number = getStyle("cornerRadius");
			var cr2:Number = cr1 - bt;
			var fc:Object = getStyle("fillColors"); 		// [up1, up2, over1, over2]
			var fa:Object = getStyle("fillAlphas");			// [up1, up2, over1, over2]
			var ha:Array = getStyle("highlightAlphas"); 	// [top, bottom]
			var fw:Number = w - bt * 2; 					// fill width
			var fh:Number = h - bt * 2; 					// fill height
			
			var c:Number;
			
			switch (name)
			{
				case "selectedUpSkin":
				case "selectedOverSkin":
				case "selectedDownSkin":
				case "downSkin":
					c = getStyle("selectionColor");
					fc = [c, c];
					fa.length = 2;
					break;
					
				case "upSkin":
					fc.length = 2;
					fa.length = 2;
					break;
					
				case "overSkin":
					fc = fc.length > 3 ? [ fc[2], fc[3] ] : adjustBrightness([ fc[0], fc[1] ], 20);
					fa = fa.length > 3 ? [ fa[2], fa[3] ] : [ fa[0], fa[1] ];
					break;
				
				case "selectedDisabledSkin":
				case "disabledSkin":
					bc = getStyle("disabledColor");
					c = ColorUtil.adjustBrightness(bc, 50);
					fc = [c, c];
					fa.length = 2;
					break;
			}
			
			//	drawRoundRect(
			// 		x, y, width, height, cornerRadius,
			//		color, alpha
			//		gradientMatrix, gradientType, gradientRatios,
			//		hole);
			
			var gm:Matrix = verticalGradientMatrix(0, 0, w, h);
			
			// border
			if (bt)
			{
				drawRoundRect(
					0, 0, w, h, cr1,
					bc, 1,
					null, null, null,
					{ x:bt, y:bt, w:fw, h:fh, r:cr2 });
			}
			
			// fill
			drawRoundRect(
				bt, bt, fw, fh, cr2,
				fc, fa,
				gm, GradientType.LINEAR, [130, 255]);
			
			// pill highlight
			if (ha[0] || ha[1])
			{
				var pad:Number = bt + 2;
				drawRoundRect(
					bt + 2, bt, w - (bt + 2) * 2, 7, 3,
					adjustBrightness(fc, 80), ha);
			}
		}
		
		private function adjustBrightness(color:Object, amount:uint):Object
		{
			if (color is Array)
			{
				var colors:Array = [];
				for (var i:int = 0; i < color.length; i++)
					colors[i] = ColorUtil.adjustBrightness(color[i], amount);
					
				return colors;
			}
			
			return ColorUtil.adjustBrightness(uint(color), amount);
		}
	}
}
