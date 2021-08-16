package com.sdg.pickem
{
	import com.sdg.display.Box;
	
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.filters.BevelFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;

	public class PickCardBacking extends Box
	{
		protected var _fill:Sprite;
		protected var _doubleLine:Number;
		
		public function PickCardBacking(width:Number=0, height:Number=0)
		{
			super(width, height);
			
			lineColor = 0x000000;
			_lineThickness = 8;
			_cornerSize = 10;
			_doubleLine = _lineThickness * 2;
			_fill = new Sprite();
			_fill.filters = [new BevelFilter(6, 45, 0, 0.5, 0xffffff, 0.3, 8, 8, 0.5), new GlowFilter(0, 0.6, 8, 8, 2, 1, true)];
			addChild(_fill);
		}
		
		override public function render():void
		{
			_doubleLine = _lineThickness * 2;
			
			graphics.clear();
			graphics.beginFill(_lineColor);
			graphics.moveTo(0, _height);
			graphics.lineTo(0, _cornerSize);
			graphics.curveTo(0, 0, _cornerSize, 0);
			graphics.lineTo(_width - _cornerSize, 0);
			graphics.curveTo(_width, 0, _width, _cornerSize);
			graphics.lineTo(_width, _height);
			//graphics.drawRoundRect(0, 0, _width, _height, _cornerSize, _cornerSize);
			graphics.endFill();
			
			_fill.graphics.clear();
			var gradMatrix:Matrix = new Matrix();
			gradMatrix.createGradientBox(_width, _height, Math.PI / 2);
			_fill.graphics.beginGradientFill(GradientType.LINEAR, [0x000000, 0x8B8B8B], [1, 1], [0, 180], gradMatrix);
			_fill.graphics.drawRoundRect(_lineThickness, _lineThickness, _width - _doubleLine, _height - _doubleLine, _cornerSize - _lineThickness, _cornerSize - _lineThickness);
		}
		
	}
}