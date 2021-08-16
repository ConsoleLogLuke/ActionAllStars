package com.sdg.trivia
{
	import com.sdg.display.AlignType;
	import com.sdg.display.Box;
	import com.sdg.display.BoxStyle;
	import com.sdg.display.Container;
	import com.sdg.display.FillStyle;
	import com.sdg.display.Stack;

	import flash.display.DisplayObject;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	public class TokenCountHUD extends Container
	{
		private var _stack:Stack;
		private var _text:TextField;
		private var _textContainer:Container;
		private var _tokens:int;
		private var _tokenImg:DisplayObject;

		[Embed(source="images/iconTokens.png")]
		[Bindable]
		private var _tokenImgClass:Class;

		public function TokenCountHUD(width:Number = 280, height:Number = 22)
		{
			super(width, height);

			// Set initial values.
			_tokens = 0;

			// Create text field.
			_textContainer = new Container();
			_textContainer.alignY = AlignType.MIDDLE;
			_textContainer.paddingTop = 2;
			_text = new TextField();
			_text.defaultTextFormat = new TextFormat('GillSans', 14, 0xffffff, true);
			_text.embedFonts = true;
			_text.autoSize = TextFieldAutoSize.LEFT;
			_updateText();
			_textContainer.content = _text;

			// Create token image.
			_tokenImg = new _tokenImgClass();
			_tokenImg.scaleX = _tokenImg.scaleY = 0.5;
			var imgContainer:Container = new Container();
			imgContainer.content = _tokenImg;

			// Create stack.
			_stack = new Stack(AlignType.HORIZONTAL, 12);
			_stack.equalizeSize = true;
			_stack.addContainer(imgContainer);
			_stack.addContainer(_textContainer);

			// Set padding.
			_paddingTop = _paddingBottom = 4;
			_paddingLeft = _paddingRight = 10;

			// Set horizontal alignment.
			alignX = AlignType.MIDDLE;

			// Create and stylize backing.
			backing = new Box();
			_backing.style = new BoxStyle(new FillStyle(0x000000, 0.7), 0, 0, 0, 12);

			content = _stack;
		}

		////////////////////
		// INSTANCE METHODS
		////////////////////

		private function _updateText():void
		{
			_text.text = 'You have earned ' + _tokens + ' tokens!';
			_textContainer.content = _text;
			_render();
		}

		////////////////////
		// GET/SET METHODS
		////////////////////

		public function set tokens(value:int):void
		{
			if (_tokens == value) return;
			_tokens = value;
			_updateText();
		}

	}
}
