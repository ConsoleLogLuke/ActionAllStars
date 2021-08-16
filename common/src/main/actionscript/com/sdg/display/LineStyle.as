package com.sdg.display
{
	public class LineStyle extends Object
	{
		private var _thickness:Number;
		private var _alpha:Number;
		private var _color:uint;
		
		public function LineStyle(color:uint = 0x000000, alpha:Number = 0, thickness:Number = 0)
		{
			super();
			
			_thickness = thickness;
			_alpha = alpha;
			_color = color;
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		public function get thickness():Number
		{
			return _thickness;
		}
		public function set thickness(value:Number):void
		{
			_thickness = value;
		}
		
		public function get alpha():Number
		{
			return _alpha;
		}
		public function set alpha(value:Number):void
		{
			_alpha = value;
		}
		
		public function get color():uint
		{
			return _color;
		}
		public function set color(value:uint):void
		{
			_color = value;
		}
		
	}
}