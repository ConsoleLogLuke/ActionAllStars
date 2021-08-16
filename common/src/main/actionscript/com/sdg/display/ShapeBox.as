package com.sdg.display
{
	import com.sdg.shape.IShape;
	
	import flash.geom.Matrix;
	
	public class ShapeBox extends Box
	{
		protected var _shape:IShape;
		
		public function ShapeBox(shape:IShape, width:Number=0, height:Number=0)
		{
			super(width, height);
			
			_shape = shape;
		}
		
		override public function render():void
		{
			// Re-define shape.
			_shape.width = _width;
			_shape.height = _height;
			
			graphics.clear();
			
			// Set fill type and style.
			if (_style.fillStyle.type == FillType.SOLID)
			{
				// Setup a solid fill.
				graphics.beginFill(_fillColor, _fillAlpha);
			}
			else if (_style.fillStyle.type == FillType.GRADIENT)
			{
				// Setup a gradient fill.
				var fillStyle:GradientFillStyle = GradientFillStyle(_style.fillStyle);
				var gradientMatrix:Matrix = new Matrix();
				gradientMatrix.createGradientBox(_width, _height, fillStyle.angle);
				graphics.beginGradientFill(fillStyle.gradientType, fillStyle.colors, fillStyle.alphas, fillStyle.ratios, gradientMatrix);
			}
			
			graphics.lineStyle(_lineThickness, _lineColor, _lineAlpha);
			_shape.draw(graphics);
		}
		
	}
}