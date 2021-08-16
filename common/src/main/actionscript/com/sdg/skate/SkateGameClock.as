package com.sdg.skate
{
	import com.sdg.view.CircleProgress;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Rectangle;

	public class SkateGameClock extends Sprite
	{
		private var _clock:StopWatchGraphic;
		private var _progress:CircleProgress;
		
		public function SkateGameClock()
		{
			super();
			
			_clock = new StopWatchGraphic();
			var clockFace:DisplayObject = _clock.face;
			var faceRect:Rectangle = clockFace.getRect(_clock);
			_progress = new CircleProgress(faceRect.width);
			_progress.backAlpha = 0;
			_progress.lineThickness = 0;
			_progress.x = faceRect.x;
			_progress.y = faceRect.y;
			_clock.addChildAt(_progress, _clock.getChildIndex(clockFace) + 1);
			
			addChild(_clock);
		}
		
		public function get value():Number
		{
			return _progress.value;
		}
		public function set value(v:Number):void
		{
			_progress.value = v;
		}
		
	}
}