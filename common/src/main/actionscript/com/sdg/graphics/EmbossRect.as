package com.sdg.graphics
{
	import com.good.goodui.FluidView;
	
	import flash.display.GradientType;
	import flash.geom.Matrix;

	public class EmbossRect extends FluidView
	{
		protected var _color:uint;
		protected var _corner:Number;
		
		public function EmbossRect(width:Number, height:Number, color:uint = 0x999999, corner:Number = 10)
		{
			_color = color;
			_corner = corner;
			
			super(width, height);
			
			render();
		}
		
		override protected function render():void
		{
			super.render();
			
			var corner:Number = _corner;
			
			var gradMatrix:Matrix = new Matrix();
			gradMatrix.createGradientBox(_width, _height, -Math.PI / 4);
			
			graphics.clear();
			graphics.beginGradientFill(GradientType.LINEAR, [0x222222, 0xaaaaaa], [1, 1], [1, 255], gradMatrix);
			graphics.drawRoundRect(0, 0, _width, _height, corner, corner);
			graphics.endFill();
			
			var off:Number = 2;
			graphics.beginFill(0xffffff);
			graphics.drawRoundRect(off, off, _width - off * 2, _height - off * 2, corner, corner);
			graphics.endFill();
			
			off = 4;
			graphics.beginFill(_color);
			graphics.drawRoundRect(off, off, _width - off * 2, _height - off * 2, corner, corner);
			graphics.endFill();
		}
		
	}
}