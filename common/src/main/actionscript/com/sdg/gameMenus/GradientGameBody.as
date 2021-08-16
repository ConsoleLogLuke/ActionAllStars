package com.sdg.gameMenus
{
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	
	public class GradientGameBody extends GameBody
	{
		protected var _gradientBox:Sprite;
		protected const PADDING_TOP:Number = 20;
		
		public function GradientGameBody(menuName:String, width:Number = 925, height:Number = 515)
		{
			super(menuName);
			
			graphics.beginFill(0xffffff);
			graphics.drawRect(0, 0, _width, _height);
			
			_gradientBox = new Sprite();
			
			var gradientBoxMatrix:Matrix = new Matrix();
			gradientBoxMatrix.createGradientBox(_width, _height - PADDING_TOP, 0, 0, 0);
			
			_gradientBox.graphics.clear();
			_gradientBox.graphics.beginGradientFill(GradientType.LINEAR, [0x182C4E, 0xffffff], [1, 1], [95, 230], gradientBoxMatrix);
			_gradientBox.graphics.drawRect(0, 0, _width, _height - PADDING_TOP);
			
			addChild(_gradientBox);
			
			_gradientBox.y = PADDING_TOP;
		}
	}
}