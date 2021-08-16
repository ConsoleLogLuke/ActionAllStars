package com.good.goodui
{
	import com.good.goodgraphics.GoodRect;
	
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	public class GoodMessage extends FluidView
	{
		protected var _backing:GoodRect;
		protected var _messageField:TextField;
		protected var _format:TextFormat;
		protected var _margin:Number;
		
		public function GoodMessage(width:Number, height:Number, message:String)
		{
			super(width, height);
			
			_format = new TextFormat('Arial', 14, 0, true, null, null, null, null, TextFormatAlign.CENTER);
			_margin = 40;
			
			_backing = new GoodRect(_width, height, 10, 0xdfdfdf);
			addChild(_backing);
			
			_messageField = new TextField();
			_messageField.defaultTextFormat = _format;
			_messageField.autoSize = TextFieldAutoSize.CENTER;
			_messageField.text = message;
			_messageField.multiline = true;
			_messageField.wordWrap = true;
			addChild(_messageField);
			
			render();
		}
		
		override protected function render():void
		{
			super.render();
			
			_messageField.width = _width - _margin * 2;
			_messageField.x = _width / 2 - _messageField.width / 2;
			_messageField.y = _height / 2 - _messageField.height / 2;
		}
		
		public function destroy():void
		{
			
		}
		
	}
}