package com.sdg.graphics
{
	import flash.display.Sprite;

	public class RayBurst extends Sprite
	{
		protected var _distance:Number;
		protected var _rayCount:uint;
		protected var _rayColor:uint;
		protected var _rayAlpha:Number;
		
		public function RayBurst(distance:Number, rayCount:uint = 2, rayColor:uint = 0xffffff, rayAlpha:Number = 1)
		{
			super();
			
			_distance = distance;
			_rayCount = Math.max(rayCount, 2);;
			_rayColor = rayColor;
			_rayAlpha = rayAlpha;
			
			render();
		}
		
		public function render():void
		{
			graphics.clear();
			
			var i:int = 0;
			for (i; i < _rayCount; i++)
			{
				// Determine ray coordinates.
				var rayAngleRange:Number = ((Math.PI * 2) / _rayCount) / 2;
				var angleA:Number = i * (rayAngleRange * 2);
				var angleB:Number = angleA + rayAngleRange;
				var pointAX:Number = Math.cos(angleA) * _distance;
				var pointAY:Number = Math.sin(angleA) * _distance;
				var pointBX:Number = Math.cos(angleB) * _distance;
				var pointBY:Number = Math.sin(angleB) * _distance;
				
				// Draw ray.
				graphics.beginFill(_rayColor, _rayAlpha);
				graphics.moveTo(0, 0);
				graphics.lineTo(pointAX, pointAY);
				graphics.lineTo(pointBX, pointBY);
				graphics.lineTo(0, 0);
				graphics.endFill();
			}
		}
		
		public function set distance(value:Number):void
		{
			if (value == _distance) return;
			_distance = value;
			render();
		}
		
	}
}