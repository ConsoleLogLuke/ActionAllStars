package com.sdg.display.leaderboard
{
	import com.sdg.model.SdgItem;
	
	import flash.display.BitmapData;
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;

	public class InWorldLeaderboardFlicker extends InWorldLeaderboardDisplay
	{
		private var _flickDir:int;
		private var _minAlpha:Number;
		private var _maxAlpha:Number;
		private var _amount:Number;
		private var _textAlpha:Number;
		private var _back:Sprite;
		
		public function InWorldLeaderboardFlicker(item:SdgItem)
		{
			super(item);
			
			_flickDir = -1;
			_minAlpha = 0.7;
			_maxAlpha = 0.8;
			_amount = _maxAlpha - _minAlpha;
			_textAlpha = _maxAlpha;
			_localUserColor = 0xffffff;
			
			titleColor = 0xf6d003;
			nameColor = 0x178020;
			scoreColor = 0x178020;
			
			// Create screen texture.
			var bd:BitmapData = new BitmapData(8, 8, false, 0x000000);
			bd.fillRect(new Rectangle(3, 3, 5, 5), 0x178020);
			
			_back = new Sprite();
			_back.graphics.beginBitmapFill(bd, new Matrix(), true);
			_back.graphics.drawRect(0, 0, _width, _height);
			_back.graphics.endFill();
			var gradMatrix:Matrix = new Matrix();
			gradMatrix.createGradientBox(_width, _height);
			_back.graphics.beginGradientFill(GradientType.RADIAL, [0, 0], [0, 1], [0, 255], gradMatrix);
			_back.graphics.drawRect(0, 0, _width, _height);
			
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			
			addChildAt(_back, 0);
		}
		
		override public function destroy():void
		{
			// Cleanup.
			
			removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			
			super.destroy();
		}
		
		private function onEnterFrame(e:Event):void
		{
			// Change alpha across frames to give flicker effect.
			var newAlpha:Number = Math.max(_textAlpha + _amount * _flickDir, _minAlpha);
			newAlpha = Math.min(newAlpha, _maxAlpha);
			_textAlpha = newAlpha;
			_names.alpha = _scores.alpha = _titleField.alpha = _textAlpha;
			_back.alpha = _textAlpha / 3;
			
			if (_textAlpha <= _minAlpha)
			{
				_flickDir = 1;
			}
			else if (_textAlpha >= _maxAlpha)
			{
				_flickDir = -1;
			}
		}
		
	}
}