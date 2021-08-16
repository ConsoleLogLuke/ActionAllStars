package com.sdg.pickem
{
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	public class PickDetailsBubble extends Sprite
	{
		private var _questionField:TextField;
		private var _width:Number;
		private var _height:Number;
		private var _padding:Number;
		private var _backing:Sprite;
		
		public function PickDetailsBubble(width:Number=0)
		{
			super();
			
			_width = width;
			_padding = 4;
			
			// Create backing.
			_backing = new Sprite();
			addChild(_backing);
			
			_questionField = new TextField();
			_questionField.defaultTextFormat = new TextFormat('EuroStyle', 11, 0xffffff, false, false, false, null, null, TextFormatAlign.CENTER);
			_questionField.embedFonts = true;
			_questionField.autoSize = TextFieldAutoSize.CENTER;
			_questionField.multiline = _questionField.wordWrap = true;
			_questionField.text = 'This is some question text.';
			addChild(_questionField);
			
			render();
		}
		
		////////////////////
		// INSTANCE METHODS
		////////////////////
		
		private function render():void
		{
			_questionField.x = _questionField.y = _padding;
			_questionField.width = _width - _padding * 2;
			
			// Draw backing.
			_backing.graphics.clear();
			_backing.graphics.beginFill(0x000000, 0.9);
			_backing.graphics.drawRoundRect(0, 0, _width, _questionField.height + _padding * 2, 10, 10);
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		public function set questionText(value:String):void
		{
			if (value == _questionField.text) return;
			_questionField.text = value;
			render();
		}
	}
}