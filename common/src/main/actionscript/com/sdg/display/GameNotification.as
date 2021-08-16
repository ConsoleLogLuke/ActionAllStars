package com.sdg.display
{
	import com.sdg.controls.AASCloseButton;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	public class GameNotification extends Container
	{
		public static const CLOSE_CLICK:String = 'close click';
		
		private var _textField:TextField;
		private var _closebtn:AASCloseButton;
		
		public function GameNotification(width:Number)
		{
			super();
			
			// Create text field.
			_textField = new TextField();
			_textField.defaultTextFormat = new TextFormat('EuroStyle', 12, 0xffffff, false, false, null, null, null, TextFormatAlign.CENTER);
			_textField.autoSize = TextFieldAutoSize.CENTER;
			_textField.multiline = true;
			_textField.wordWrap = true;
			_textField.embedFonts = true;
			_textField.mouseEnabled = false;
			
			// Create close button.
			_closebtn = new AASCloseButton(16, 16);
			_closebtn.addEventListener(MouseEvent.CLICK, onCloseClick);
			_addChild(_closebtn);
			
			// Create backing.
			var box:Box = new Box();
			box.style = new BoxStyle(new FillStyle(0x000000, 0.8), 0, 0, 0, 12);
			backing = box;
			
			padding = 20;
			
			_textField.width = width - _paddingLeft - _paddingRight;
			
			content = _textField;
		}
		
		////////////////////
		// INSTANCE METHODS
		////////////////////
		
		override protected function _render():void
		{
			super._render();
			
			_closebtn.x = _width - _closebtn.width - 4;
			_closebtn.y = 4;
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		public function set text(value:String):void
		{
			if (value == _textField.text) return;
			_textField.text = value;
			_render();
		}
		
		////////////////////
		// EVENT HANDLERS
		////////////////////
		
		private function onCloseClick(e:MouseEvent):void
		{
			dispatchEvent(new Event(CLOSE_CLICK));
		}
		
	}
}