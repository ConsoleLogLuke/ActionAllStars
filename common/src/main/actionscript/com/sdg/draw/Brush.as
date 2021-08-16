package com.sdg.draw
{
	public class Brush
	{
		
		protected var _size:Number;
		
		public function Brush(size:Number = 1)
		{
			_size = size;
		}
		
		public function get size():Number
		{
			return _size;
		}
		public function set size(value:Number):void
		{
			if (value >= 0)
			{
				_size = value;
			}
		}

	}
}