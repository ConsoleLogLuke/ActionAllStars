package com.sdg.display
{
	import flash.geom.Matrix;
	
	public class GradientFillStyle extends FillStyle
	{
		protected var _gradientType:String;
		protected var _colors:Array;
		protected var _alphas:Array;
		protected var _ratios:Array;
		protected var _angle:Number;
		
		public function GradientFillStyle(type:String, colors:Array, alphas:Array, ratios:Array, angle:Number)
		{
			super(color, alpha);
			
			_type = FillType.GRADIENT;
			_gradientType = type;
			_colors = colors;
			_alpha = alpha;
			_ratios = ratios;
			_angle = angle;
		}
		
		public function get gradientType():String
		{
			return _gradientType;
		}
		public function set gradientType(value:String):void
		{
			_gradientType = value;
		}
		
		public function get colors():Array
		{
			return _colors;
		}
		public function set colors(value:Array):void
		{
			_colors = value;
		}
		
		public function get alphas():Array
		{
			return _alphas;
		}
		public function set alphas(value:Array):void
		{
			_alphas = value;
		}
		
		public function get ratios():Array
		{
			return _ratios;
		}
		public function set ratios(value:Array):void
		{
			_ratios = value;
		}
		
		public function get angle():Number
		{
			return _angle;
		}
		public function set angle(value:Number):void
		{
			_angle = value;
		}
		
	}
}