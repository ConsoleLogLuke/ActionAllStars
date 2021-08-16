package com.sdg.view.pda
{
	import flash.display.GradientType;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	
	import mx.containers.Canvas;
	import mx.controls.Label;
	
	public class SidePanelBacking extends Canvas
	{
		private var _label:Label;
		public static const HEADER_HEIGHT:Number = 45;
		public static const FOOTER_HEIGHT:Number = 25;
		
		public function SidePanelBacking()
		{
			super();
			_label = new Label();
			_label.setStyle("fontSize", 18);
			_label.setStyle("fontWeight", "bold");
			_label.setStyle("fontThickness", 250);
			_label.setStyle("fontFamily", "EuroStyle");
			addChild(_label);
			_label.filters = [new GlowFilter(0x000000, 1, 6, 6, 10)];
			_label.x = 20;
		}
		
		public function set headerText(value:String):void
		{
			_label.text = value;
			_label.y = HEADER_HEIGHT/2 - _label.height/2;
		}
		
		public function get headerText():String
		{
			return _label.text;
		}
		
		override protected function updateDisplayList(w:Number, h:Number):void
		{
			super.updateDisplayList(w,h);
			
			var gradientBoxMatrix:Matrix = new Matrix();
			
			graphics.clear();
			
			graphics.lineStyle(2, 0, 1, true);
			
			var corner:Number = getStyle("cornerRadius");
			
			var bodyHeight:Number = h - HEADER_HEIGHT - FOOTER_HEIGHT;
			
			// header
			graphics.beginFill(0x1B1B1B);
			graphics.drawRoundRectComplex(0, 0, w, HEADER_HEIGHT, 0, corner, 0, 0);
			graphics.endFill();
			
			// body
			gradientBoxMatrix.createGradientBox(w, bodyHeight, Math.PI/2, 0, 0);
			graphics.beginGradientFill(GradientType.LINEAR, [0xDFE6F2, 0x10429D], [1, 1], [0, 255], gradientBoxMatrix);
			graphics.drawRect(0, HEADER_HEIGHT, w, bodyHeight); 
			graphics.endFill();
			
			// footer
			graphics.beginFill(0x1B1B1B);
			graphics.drawRoundRectComplex(0, h - FOOTER_HEIGHT, w, FOOTER_HEIGHT, 0, 0, 0, corner);
			graphics.endFill();
			
			_label.y = HEADER_HEIGHT/2 - _label.height/2;
		}
	}
}