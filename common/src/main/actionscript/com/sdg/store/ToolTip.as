package com.sdg.store
{
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	public class ToolTip extends Sprite
	{
		protected var _text:String;
		protected var _textField:TextField;
		protected var _margin:Number;
		
		public function ToolTip()
		{
			super();
			
			// Default.
			_margin = 5;
			
			_textField = new TextField();
			_textField.defaultTextFormat = new TextFormat('Arial', 10, 0xffffff, true);
			_textField.autoSize = TextFieldAutoSize.LEFT;
			addChild(_textField);
			
			render();
		}
		
		protected function render():void
		{
			var w:Number = _textField.width + _margin * 2;
			var h:Number = _textField.height + _margin * 2;
			
			// Draw backing.
			graphics.clear();
			graphics.beginFill(0x80002a);
			graphics.lineStyle(2, 0);
			graphics.drawRoundRect(0, 0, w, h, 10, 10);
			
			_textField.x = _margin;
			_textField.y = _margin;
		}
		
		public function set text(value:String):void
		{
			_textField.text = value;
			
			render();
		}
		
		public function get useEmbededFonts():Boolean
		{
			return _textField.embedFonts;
		}
		
		public function set useEmbededFonts(value:Boolean):void
		{
			_textField.embedFonts = value;
		}
		
		public function get textFormat():TextFormat
		{
			return _textField.defaultTextFormat;
		}
		public function set textFormat(value:TextFormat):void
		{
			_textField.defaultTextFormat = value;
		}
		
	}
}