package com.sdg.pickem
{
	import com.boostworthy.animation.management.AnimationManager;
	
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	public class InQueScreen extends Sprite
	{
		private var _width:Number;
		private var _height:Number;
		private var _backing:Sprite;
		private var _messageField:TextField;
		private var _animationManager:AnimationManager;
		private var _countdownField:TextField;
		
		public function InQueScreen(width:Number, height:Number, animationManager:AnimationManager)
		{
			super();
			
			_width = width;
			_height = height;
			_animationManager = animationManager;
			
			// Backing.
			_backing = new Sprite();
			addChild(_backing);
			
			// Message field.
			_messageField = new TextField();
			_messageField.defaultTextFormat = new TextFormat('GillSans', 38, 0x0D2453, true, null, null, null, null, TextFormatAlign.CENTER);
			_messageField.embedFonts = true;
			_messageField.autoSize = TextFieldAutoSize.CENTER;
			_messageField.text = 'Game will begin in:';
			addChild(_messageField);
			
			// Countdown field.
			_countdownField = new TextField();
			_countdownField.defaultTextFormat = new TextFormat('EuroStyle', 56, 0x0D2453, true);
			_countdownField.embedFonts = true;
			_countdownField.autoSize = TextFieldAutoSize.CENTER;
			_countdownField.text = '10';
			addChild(_countdownField)
			
			render();
		}
		
		private function render():void
		{
			// Draw backing.
			_backing.graphics.clear();
			_backing.graphics.beginFill(0x8FBDDF);
			_backing.graphics.drawRect(0, 0, _width, _height);
			
			var spacing:Number = 20;
			var objsTotalHeight:Number = _messageField.height + _countdownField.height + spacing;
			
			// Position message field.
			_messageField.x = _width / 2 - _messageField.width / 2;
			_messageField.y = _height / 2 - objsTotalHeight / 2;
			
			// Position countdown field.
			_countdownField.x = _width / 2 - _countdownField.width / 2;
			_countdownField.y = _messageField.y + _messageField.height + spacing;
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		override public function get width():Number
		{
			return _width;
		}
		override public function set width(value:Number):void
		{
			if (value == _width) return;
			_width = value;
			render();
		}
		
		override public function get height():Number
		{
			return _height;
		}
		override public function set height(value:Number):void
		{
			if (value == _height) return;
			_height = value;
			render();
		}
		
		public function set countdownTime(value:int):void
		{
			if (_countdownField.text as int == value) return;
			_countdownField.text = value.toString();
			render();
		}
	}
}