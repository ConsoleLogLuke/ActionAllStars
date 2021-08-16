package com.sdg.display
{
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.filters.BevelFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	
	public class AASPanelBacking extends Box
	{
		protected var _fill:Sprite;
		protected var _doubleLine:Number;
		
		public function AASPanelBacking(width:Number=0, height:Number=0)
		{
			super(width, height);
			
			_lineColor = 0x074270;
			_lineThickness = 8;
			_cornerSize = 20;
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
			graphics.drawRoundRect(0, 0, _width, _height, _cornerSize, _cornerSize);
			graphics.endFill();
			
			_fill.graphics.clear();
			var gradMatrix:Matrix = new Matrix();
			gradMatrix.createGradientBox(_width, _height, Math.PI / 2);
			_fill.graphics.beginGradientFill(GradientType.LINEAR, [0x0f6fb9, 0xe4e2e5], [1, 1], [0, 180], gradMatrix);
			_fill.graphics.drawRoundRect(_lineThickness, _lineThickness, _width - _doubleLine, _height - _doubleLine, _cornerSize - _lineThickness, _cornerSize - _lineThickness);
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		/*public function set lineThickness(value:Number):void
		{
			if (value == _lineThickness) return;
			_lineThickness = value;
			render();
		}*/
		
	}
}