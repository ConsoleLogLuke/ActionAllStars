package com.sdg.view
{
	import com.good.goodui.FluidView;
	
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	public class IndexBlock extends FluidView
	{
		protected var _index:uint;
		protected var _color:uint;
		protected var _glow:GlowFilter;
		protected var _maxIndex:uint;
		
		protected var _back:Sprite;
		protected var _field:TextField;
		
		public function IndexBlock(index:uint, width:Number, height:Number, color:uint = 0x1b5175)
		{
			_index = index;
			_color = color;
			_glow = new GlowFilter(color, 1, 18, 18);
			_maxIndex = 0;
			
			_back = new Sprite();
			
			_field = new TextField();
			_field.defaultTextFormat = new TextFormat('EuroStyle', 36, 0xffffff, true);
			_field.autoSize = TextFieldAutoSize.LEFT;
			_field.selectable = false;
			_field.filters = [_glow];
			_field.text = _index.toString();
			_field.embedFonts = true;
			if (_maxIndex > 0 && _index >= _maxIndex) _field.text = '+' + _maxIndex.toString();
			
			addChild(_back);
			addChild(_field);
			
			super(width, height);
			
			render();
		}
		
		override protected function render():void
		{
			var gradMatrix:Matrix = new Matrix();
			gradMatrix.createGradientBox(_width, _height, Math.PI / 2);
			
			_back.graphics.clear();
			_back.graphics.beginGradientFill(GradientType.LINEAR, [_color, _color], [0.7, 0.1], [1, 255], gradMatrix);
			_back.graphics.drawRect(0, 0, _width, _height);
			
			_field.x = _width / 2 - _field.width / 2;
			_field.y = _height / 2 - _field.height / 2;
		}
		
		public function get maxIndex():uint
		{
			return _maxIndex;
		}
		public function set maxIndex(value:uint):void
		{
			if (value == _maxIndex) return;
			_maxIndex = value;
			if (_maxIndex > 0 && _index >= _maxIndex) _field.text = '+' + _maxIndex.toString();
			
			render();
		}
		
	}
}