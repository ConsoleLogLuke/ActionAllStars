package com.sdg.view.cursor
{
	import flash.display.Sprite;

	public class ArrowCursor extends Sprite
	{
		private var _display:Sprite;
		private var _angle:Number;
		private var _length:Number;
		private var _width:Number;
		private var _color1:uint;
		private var _color2:uint;
		private var _stretch:Number;
		private var _offsetPercent:Number;
		
		public function ArrowCursor(arrowLength:Number, arrowWidth:Number, fillColor:uint, lineColor:uint)
		{
			super();
			
			_angle = 0;
			_length = arrowLength;
			_width = arrowWidth;
			_color1 = fillColor;
			_color2 = lineColor;
			_stretch = 1;
			_offsetPercent = 0.5;
			_display = new Sprite();
			_display.mouseEnabled = false;
			
			render();
			
			// Add displays.
			addChild(_display);
		}
		
		////////////////////
		// PRIVATE FUNCTIONS
		////////////////////
		
		private function render():void
		{
			// Render an arrow, based on angle.
			var angle1:Number = _angle;
			var angle2:Number = angle1 + Math.PI / 2;
			var stretchedLength:Number = _length * _stretch;
			var offsetDis:Number = _length * _offsetPercent;
			var offX:Number = Math.cos(angle1) * offsetDis;
			var offY:Number = Math.sin(angle1) * offsetDis;
			var baseX:Number = -Math.cos(angle1) * _length + offX;
			var baseY:Number = -Math.sin(angle1) * _length + offY;
			var x1:Number = -Math.cos(angle2) * (_width / 2) + baseX;
			var y1:Number = -Math.sin(angle2) * (_width / 2) + baseY;
			var x2:Number = Math.cos(angle2) * (_width / 2) + baseX;
			var y2:Number = Math.sin(angle2) * (_width / 2) + baseY;
			var pointX:Number = Math.cos(angle1) * (stretchedLength) + baseX;
			var pointY:Number = Math.sin(angle1) * (stretchedLength) + baseY;
			
			_display.graphics.clear();
			_display.graphics.lineStyle(1, _color2);
			_display.graphics.beginFill(_color1);
			_display.graphics.moveTo(pointX, pointY);
			_display.graphics.lineTo(x1, y1);
			_display.graphics.lineTo(x2, y2);
			_display.graphics.lineTo(pointX, pointY);
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		public function get angle():Number
		{
			return _angle;
		}
		public function set angle(value:Number):void
		{
			if (value == _angle) return;
			_angle = value;
			render();
		}
		
		public function get fillColor():uint
		{
			return _color1;
		}
		public function set fillColor(value:uint):void
		{
			if (value == _color1) return;
			_color1 = value;
			render();
		}
		
		public function get lineColor():uint
		{
			return _color2;
		}
		public function set lineColor(value:uint):void
		{
			if (value == _color2) return;
			_color2 = value;
			render();
		}
		
		public function get arrowLength():Number
		{
			return _length;
		}
		public function set arrowLength(value:Number):void
		{
			if (value == _length) return;
			_length = value;
			render();
		}
		
		public function get stretchPercentage():Number
		{
			return _stretch;
		}
		public function set stretchPercentage(value:Number):void
		{
			if (value == _stretch) return;
			_stretch = value;
			render();
		}
		
	}
}