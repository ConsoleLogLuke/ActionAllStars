package com.sdg.ui
{
	import com.sdg.view.FluidView;
	
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	public class TextBox extends FluidView
	{
		private var _field:TextField;
		private var _backColor:uint;
		
		public function TextBox(text:String, backColor:uint, width:Number, height:Number)
		{
			_backColor = backColor;
			
			_field = new TextField();
			_field.defaultTextFormat = new TextFormat('EuroStyle', 18, 0xffffff, true);
			_field.autoSize = TextFieldAutoSize.LEFT;
			_field.selectable = false;
			_field.mouseEnabled = false;
			_field.embedFonts = true;
			_field.text = text;
			
			super(width, height);
			
			render();
			
			addChild(_field);
		}
		
		override protected function render():void
		{
			super.render();
			
			renderBack();
			
			_field.x = _width / 2 - _field.width / 2;
			_field.y = _height / 2 - _field.height / 2;
		}
		
		private function renderBack():void
		{
			graphics.clear();
			graphics.beginFill(_backColor);
			graphics.drawRect(0, 0, _width, _height);
		}
		
		public function get field():TextField
		{
			return _field;
		}
		
		public function get backColor():uint
		{
			return _backColor;
		}
		public function set backColor(value:uint):void
		{
			if (value == _backColor) return;
			_backColor = value;
			renderBack();
		}
		
	}
}