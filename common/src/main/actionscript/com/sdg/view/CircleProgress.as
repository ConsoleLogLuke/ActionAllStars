package com.sdg.view
{
	import flash.display.Sprite;
	
	public class CircleProgress extends FluidView
	{
		private var _value:Number;
		private var _back:Sprite;
		private var _fill:Sprite;
		private var _mask:Sprite;
		private var _color:uint;
		private var _lineColor:uint;
		private var _backAlpha:Number;
		private var _lineThickness:int;
		
		public function CircleProgress(size:Number)
		{
			super(size, size);
			
			_value = 0;
			_color = 0xeeeeee;
			_lineColor = 0xffffff;
			_backAlpha = 0.7;
			_lineThickness = 4;
			
			_back = new Sprite();
			_mask = new Sprite();
			_fill = new Sprite();
			_fill.mask = _mask;
			
			addChild(_back);
			addChild(_fill);
			addChild(_mask);
			
			render();
		}
		
		override protected function render():void
		{
			super.render();
			
			var radius:Number = _width / 2;
			
			_back.graphics.clear();
			_back.graphics.lineStyle(_lineThickness, _lineColor);
			_back.graphics.beginFill(0x000000, _backAlpha);
			_back.graphics.drawCircle(radius, radius, radius);
			
			_mask.graphics.clear();
			_mask.graphics.beginFill(0x00ff00);
			_mask.graphics.drawCircle(radius, radius, radius);
			
			renderFill();
		}
		
		private function renderFill():void
		{
			var radius:Number = _width / 2;
			
			// Fill is drawn based on value.
			_fill.graphics.clear();
			if (!_value) return;
			// Convert value to radians.
			var radians:Number = (Math.PI * 2 * _value) - Math.PI;
			var length:Number = radius * 1.5;
			_fill.graphics.beginFill(_color);
			_fill.graphics.moveTo(radius, 0);
			_fill.graphics.lineTo(radius, radius);
			_fill.graphics.lineTo(Math.sin(radians) * length + radius, Math.cos(radians) * length + radius);
			if (_value > 0.875) _fill.graphics.lineTo(_width, 0);
			if (_value > 0.625) _fill.graphics.lineTo(_width, _height);
			if (_value > 0.375) _fill.graphics.lineTo(0, _height);
			if (_value > 0.125) _fill.graphics.lineTo(0, 0);
			_fill.graphics.lineTo(radius, 0);
		}
		
		public function get value():Number
		{
			return _value;
		}
		public function set value(v:Number):void
		{
			if (v == _value) return;
			_value = v;
			renderFill();
		}
		
		public function get backAlpha():Number
		{
			return _backAlpha;
		}
		public function set backAlpha(value:Number):void
		{
			if (value == _backAlpha) return;
			_backAlpha = value;
			render();
		}
		
		public function get lineThickness():Number
		{
			return _lineThickness;
		}
		public function set lineThickness(value:Number):void
		{
			if (value == _lineThickness) return;
			_lineThickness = value;
			render();
		}
		
	}
}