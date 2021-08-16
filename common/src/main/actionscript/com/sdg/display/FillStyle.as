package com.sdg.display
{
	public class FillStyle extends Object
	{
		protected var _type:String;
		protected var _color:uint;
		protected var _alpha:Number;
		
		public function FillStyle(color:uint, alpha:Number)
		{
			super();
			
			_type = FillType.SOLID;
			_color = color;
			_alpha = alpha;
		}
		
		public function get color():uint
		{
			return _color;
		}
		public function set color(value:uint):void
		{
			_color = value;
		}
		
		public function get alpha():Number
		{
			return _alpha;
		}
		public function set alpha(value:Number):void
		{
			_alpha = value;
		}
		
		public function get type():String
		{
			return _type;
		}
		public function set type(value:String):void
		{
			_type = value;
		}
		
	}
}