package com.sdg.graphics
{
	import flash.display.GradientType;
	import flash.geom.Matrix;
	
	public class GradientStyle
	{
		public var type:String;
		public var colors:Array;
		public var alphas:Array;
		public var ratios:Array;
		public var matrix:Matrix;
		public var spreadMethod:String;
		public var interpolationMethod:String;
		public var focalPointRatio:Number;
		
		public function GradientStyle(_type:String,_colors:Array,_alphas:Array,_ratios:Array,_matrix:Matrix = null,_spreadMethod:String = "pad", _interpolationMethod:String = "rgb", _focalPointRatio:Number = 0)
		{
			type = _type;
            colors = _colors;
			alphas = _alphas;
			ratios = _ratios;
			matrix = _matrix;
			spreadMethod = _spreadMethod;
			interpolationMethod = _interpolationMethod;
			focalPointRatio = _focalPointRatio;
		}
		
	}
}