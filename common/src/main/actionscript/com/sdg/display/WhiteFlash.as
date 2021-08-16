package com.sdg.display
{
	import flash.display.BlendMode;
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.geom.Matrix;

	public class WhiteFlash extends Sprite
	{
		private var _width:Number;
		private var _height:Number;
		private var _intensity:Number;
		
		public function WhiteFlash(width:Number, height:Number)
		{
			super();
			
			_width = width;
			_height = height;
			_intensity = 0;
			
			render();
		}
		
		private function render():void
		{
			var gradMatrix:Matrix = new Matrix();
			gradMatrix.createGradientBox(_width * 2, _height * 2, 0, -_width / 2, -_height / 2);
			
			graphics.clear();
			graphics.beginGradientFill(GradientType.RADIAL, [0xffffff, 0xffffff], [_intensity, _intensity / 2], [255 * _intensity / 8, 255 * _intensity], gradMatrix);
			graphics.drawRect(0, 0, _width, _height);
		}
		
		public function get intensity():Number
		{
			return _intensity;
		}
		public function set intensity(value:Number):void
		{
			if (value == _intensity) return;
			if (value < 0 || value > 1) return;
			_intensity = value;
			render();
		}
		
	}
}