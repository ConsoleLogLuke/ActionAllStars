package com.sdg.display
{
	import flash.display.Sprite;
	import flash.geom.Matrix;

	public class Box extends Sprite implements IFluid
	{
		protected var _width:Number;
		protected var _height:Number;
		protected var _lineColor:uint;
		protected var _lineAlpha:Number;
		protected var _fillColor:uint;
		protected var _lineThickness:Number;
		protected var _cornerSize:Number;
		protected var _fillAlpha:Number;
		protected var _style:BoxStyle;
		
		/**
		 * The Box class is a base class for fluid rectangle elements.
		 */
		public function Box(width:Number = 0, height:Number = 0, cornerSize:Number = 0)
		{
			super();
			
			_width = width;
			_height = height;
			_lineColor = 0;
			_lineAlpha = 0;
			_lineThickness = 0;
			_cornerSize = cornerSize;
			_fillColor = 0xffffff;
			_fillAlpha = 0;
			_style = new BoxStyle(new FillStyle(_fillColor, _fillAlpha), _lineColor, _lineAlpha, lineThickness, _cornerSize);
		}
		
		////////////////////
		// INSTANCE METHODS
		////////////////////
		
		public function render():void
		{
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
			if (_cornerSize < 1)
			{
				graphics.drawRect(0, 0, _width, _height);
			}
			else
			{
				graphics.drawRoundRect(0, 0, _width, _height, _cornerSize, _cornerSize);
			}
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		override public function set scaleX(value:Number):void
		{
			throw(new Error('Box is a fluid element. You cannot set the scale of a Box.'));
		}
		
		override public function set scaleY(value:Number):void
		{
			throw(new Error('Box is a fluid element. You cannot set the scale of a Box.'));
		}
		
		override public function get width():Number
		{
			return _width;
		}
		override public function set width(value:Number):void
		{
			if (_width == value) return;
			_width = value;
			render();
		}
		
		override public function get height():Number
		{
			return _height;
		}
		override public function set height(value:Number):void
		{
			if (_height == value) return;
			_height = value;
			render();
		}
		
		public function get lineColor():uint
		{
			return _lineColor;
		}
		public function set lineColor(value:uint):void
		{
			if (_lineColor == value) return;
			_lineColor = value;
			render();
		}
		
		public function get lineAlpha():Number
		{
			return _lineAlpha;
		}
		public function set lineAlpha(value:Number):void
		{
			if (_lineAlpha == value) return;
			_lineAlpha = value;
			render();
		}
		
		public function get lineThickness():Number
		{
			return _lineThickness;
		}
		public function set lineThickness(value:Number):void
		{
			if (_lineThickness == value) return;
			_lineThickness = value;
			render();
		}
		
		public function get fillColor():uint
		{
			return _fillColor;
		}
		public function set fillColor(value:uint):void
		{
			if (_fillColor == value) return;
			_fillColor = value;
			render();
		}
		
		public function get fillAlpha():Number
		{
			return _fillAlpha;
		}
		public function set fillAlpha(value:Number):void
		{
			if (_fillAlpha == value) return;
			_fillAlpha = value;
			render();
		}
		
		public function get cornerSize():Number
		{
			return _cornerSize;
		}
		public function set cornerSize(value:Number):void
		{
			if (_cornerSize == value) return;
			_cornerSize = value;
			render();
		}
		
		public function get style():BoxStyle
		{
			return _style;
		}
		public function set style(value:BoxStyle):void
		{
			if (_style == value) return;
			_style = value;
			_fillColor = _style.fillStyle.color;
			_fillAlpha = _style.fillStyle.alpha;
			_lineColor = _style.lineColor;
			_lineAlpha = _style.lineAlpha;
			_lineThickness = _style.lineThickness;
			_cornerSize = _style.cornerSize;
			render();
		}
		
	}
}