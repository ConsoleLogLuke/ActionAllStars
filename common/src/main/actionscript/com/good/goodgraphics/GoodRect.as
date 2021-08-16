package com.good.goodgraphics
{
	import com.good.goodui.FluidView;
	
	import flash.display.GradientType;
	import flash.geom.Matrix;

	public class GoodRect extends FluidView
	{
		protected var _cornerSize:Number;
		protected var _color:uint;
		
		public function GoodRect(width:Number, height:Number, cornerSize:Number = 10, color:uint = 0x677192)
		{
			super(width, height);
			
			_cornerSize = cornerSize;
			_color = color;
			
			render();
		}
		
		override protected function render():void
		{
			super.render();
			
			var highLowAlpha:Number = 0.2;
			
			// Main fill.
			graphics.clear();
			graphics.beginFill(_color);
			graphics.drawRoundRect(0, 0, _width, _height, _cornerSize, _cornerSize);
			
			// Gradient matrix.
			var gradMatrix:Matrix = new Matrix();
			gradMatrix.createGradientBox(_width, _height, Math.PI / 2);
			
			// Highlight
			graphics.beginGradientFill(GradientType.LINEAR, [0xffffff, 0xffffff], [highLowAlpha, 0], [1, 255], gradMatrix);
			graphics.drawRoundRect(0, 0, _width, _height, _cornerSize, _cornerSize);
			
			// Shadow.
			graphics.beginGradientFill(GradientType.LINEAR, [0, 0], [0, highLowAlpha], [1, 255], gradMatrix);
			graphics.drawRoundRect(0, 0, _width, _height, _cornerSize, _cornerSize);
			
			// Line.
			graphics.endFill();
			graphics.lineStyle(1, 0, 0.5, true);
			graphics.drawRoundRect(0, 0, _width, _height, _cornerSize, _cornerSize);
		}
		
		//////////////////////
		// GET/SET METHODS
		//////////////////////
		
		public function get color():uint
		{
			return _color;
		}
		public function set color(value:uint):void
		{
			if (value == _color) return;
			_color = value;
			render();
		}
		
		public function get cornerSize():Number
		{
			return _cornerSize;
		}
		public function set cornerSize(value:Number):void
		{
			if (value == _cornerSize) return;
			_cornerSize = value;
			render();
		}
		
	}
}