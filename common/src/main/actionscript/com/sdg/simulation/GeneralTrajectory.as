package com.sdg.simulation
{
	import flash.geom.Point;
	
	public class GeneralTrajectory extends Object
	{
		public static const GRAVITY:Number = 9.8;
		
		public function GeneralTrajectory()
		{
			super();
		}
		
		public static function GetPosition(aX:Number, aY:Number, v0X:Number, v0Y:Number, t:Number, resolution:Number = 1):Point
		{
			/*
			 	/* use general trajectory equation
				/* take input parameters:
				/* acceleration X
				/* acceleration Y
				/* velocity initial X
				/* velocity initial Y
				/* time
				/* return a point (x, y)
				
				/* higher resolution gives higher granularity to the equation
				/* if 100 units of time yield 100 points in space at resolution of 1
				/* then 100 units of time yeild 1000 points in space at resolution of 10
			*/
			
			resolution = 1 / resolution;
			aX *= resolution;
			aY *= resolution;
			v0X *= resolution;
			v0Y *= resolution;
			t *= resolution;
			var x:Number = v0X * t + (1 / 2) * aX * Math.pow(t, 2);
			var y:Number = v0Y * t + (1 / 2) * aY * Math.pow(t, 2);
			return new Point(x / resolution, y / resolution);
		}
		
	}
}