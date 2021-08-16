package com.sdg.view.pda
{
	import flash.display.GradientType;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	
	import mx.containers.Canvas;
	import mx.controls.Label;
	
	public class SidePanelBackingBadges extends Canvas
	{
		//private var _label:Label;
		public static const HEADER_HEIGHT:Number = 45;
		public static const FOOTER_HEIGHT:Number = 25;
		
		public function SidePanelBackingBadges()
		{
			super();
		}
		
		override protected function updateDisplayList(w:Number, h:Number):void
		{
			super.updateDisplayList(w,h);
			
			//var gradientBoxMatrix:Matrix = new Matrix();
			
			var gradMatrix:Matrix = new Matrix();
			gradMatrix.createGradientBox(w, h, Math.PI / 2);
			
			graphics.clear();
			graphics.beginGradientFill(GradientType.LINEAR, [0x89C1F7, 0x253E9D], [1, 1], [1, 255], gradMatrix);
			graphics.drawRoundRect(0, 0, w, h, 10, 10);
			
			//graphics.lineStyle(2, 0, 1, true);
			
			//var corner:Number = getStyle("cornerRadius");
			
			//var bodyHeight:Number = h - HEADER_HEIGHT - FOOTER_HEIGHT;
			
			// header
			//graphics.beginFill(0x1B1B1B);
			//graphics.drawRoundRectComplex(0, 0, w, HEADER_HEIGHT, 0, corner, 0, 0);
			//graphics.endFill();
			
			// body
			//gradientBoxMatrix.createGradientBox(w, bodyHeight, Math.PI/2, 0, 0);
			//graphics.beginGradientFill(GradientType.LINEAR, [0xDFE6F2, 0x10429D], [1, 1], [0, 255], gradientBoxMatrix);
			//graphics.drawRect(0, HEADER_HEIGHT, w, bodyHeight); 
			//graphics.endFill();
			
			// footer
			//graphics.beginFill(0x1B1B1B);
			//graphics.drawRoundRectComplex(0, h - FOOTER_HEIGHT, w, FOOTER_HEIGHT, 0, 0, 0, corner);
			//graphics.endFill();
		}
	}
}