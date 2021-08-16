package com.sdg.display
{
	public class BoxStyle extends Object
	{
		protected var _lineColor:uint;
		protected var _lineAlpha:Number;
		protected var _lineThickness:Number;
		protected var _cornerSize:Number;
		protected var _fillStyle:FillStyle;
		
		public function BoxStyle(fillStyle:FillStyle, lineColor:uint = 0x000000, lineAlpha:Number = 0, lineThickness:Number = 0, cornerSize:Number = 0)
		{
			super();
			
			_fillStyle = fillStyle;
			_lineColor = lineColor;
			_lineAlpha = lineAlpha;
			_lineThickness = lineThickness;
			_cornerSize = cornerSize;
		}
		
		public function get lineColor():uint
		{
			return _lineColor;
		}
		public function set lineColor(value:uint):void
		{
			_lineColor = value;
		}
		
		public function get lineAlpha():Number
		{
			return _lineAlpha;
		}
		public function set lineAlpha(value:Number):void
		{
			_lineAlpha = value;
		}
		
		public function get lineThickness():Number
		{
			return _lineThickness;
		}
		public function set lineThickness(value:Number):void
		{
			_lineThickness = value;
		}
		
		public function get cornerSize():Number
		{
			return _cornerSize;
		}
		public function set cornerSize(value:Number):void
		{
			_cornerSize = value;
		}
		
		public function get fillStyle():FillStyle
		{
			return _fillStyle;
		}
		public function set fillStyle(value:FillStyle):void
		{
			_fillStyle = value;
		}
		
	}
}