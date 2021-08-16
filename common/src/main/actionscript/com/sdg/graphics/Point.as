package com.sdg.graphics
{
	// Coordinate Storage Object
	public class Point extends Object
	{
		protected var _x:Number;
		protected var _y:Number;
		protected var _z:Number;
		
		public function Point(x:Number = 0,y:Number=0,z:Number = 0)
		{
			super();
			
			_x = x;
			_y = y;
			_z = z;
		}
		
		//////////////////////
		// GET / SET Methods
		//////////////////////
		
		public function get x():Number
		{
			return _x;
		}
		
		public function set x(value:Number):void
		{
			_x = value;
		}
		
		public function get y():Number
		{
			return _y;
		}
		
		public function set y(value:Number):void
		{
			_y = value;
		}
		
		public function get z():Number
		{
			return _z;
		}
		
		public function set z(value:Number):void
		{
			_z = value;
		}

	}
}