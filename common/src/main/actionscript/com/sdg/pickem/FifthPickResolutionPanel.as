package com.sdg.pickem
{
	import com.sdg.buttonstyle.AASButtonStyles;
	import com.sdg.controls.AASDialogButton;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	public class FifthPickResolutionPanel extends Sprite
	{
		private var _width:Number;
		private var _height:Number;
		private var _backing:Sprite;
		private var _continueBtn:AASDialogButton;
		private var _exitBtn:AASDialogButton;
		private var _messageField:TextField;
		
		public function FifthPickResolutionPanel(width:Number, height:Number)
		{
			super();
			
			_width = width;
			_height = height;
			
			// Backing.
			_backing = new Sprite();
			addChild(_backing);
			
			// Message field.
			_messageField = new TextField();
			_messageField.defaultTextFormat = new TextFormat('GillSans', 28, 0x0D2453, true, null, null, null, null, TextFormatAlign.CENTER);
			_messageField.embedFonts = true;
			_messageField.autoSize = TextFieldAutoSize.CENTER;
			_messageField.text = 'Congrats! Your picks have been recorded.\nBe sure to check your scorecard tomorrow\nafter 4am PST to see how you did!';
			//_messageField.text = 'Your 5 picks have been recorded!\nPlay again or check your scorecard tomorrow\nat 11am PST to see how you did!';
			addChild(_messageField);
			
			// Continue button.
			_continueBtn = new AASDialogButton('Change Picks', 160, 40, AASButtonStyles.ORANGE_BUTTON);
			_continueBtn.label.embedFonts = true;
			_continueBtn.addEventListener(MouseEvent.CLICK, onContinueClick);
			addChild(_continueBtn);
			
			// Exit button.
			_exitBtn = new AASDialogButton('Exit Room', 160, 40, AASButtonStyles.ORANGE_BUTTON);
			_exitBtn.label.embedFonts = true;
			_exitBtn.addEventListener(MouseEvent.CLICK, onExitClick);
			addChild(_exitBtn);
			
			render();
		}
		
		public function destroy():void
		{
			// Remove event listeners.
			_continueBtn.removeEventListener(MouseEvent.CLICK, onContinueClick);
			_exitBtn.removeEventListener(MouseEvent.CLICK, onExitClick);
		}
		
		private function render():void
		{
			// Draw backing.
			_backing.graphics.clear();
			_backing.graphics.beginFill(0x8FBDDF);
			_backing.graphics.drawRect(0, 0, _width, _height);
			
			// Position message field.
			_messageField.x = _width / 2 - _messageField.width / 2;
			_messageField.y = _height / 2 - _messageField.height / 2 - 20;
			
			// Position buttons.
			_continueBtn.x = _width / 2 - _continueBtn.width - 10;
			_continueBtn.y = _messageField.y + _messageField.height + 20;
			_exitBtn.x = _width / 2 + 10;
			_exitBtn.y  = _continueBtn.y;
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
		
		////////////////////
		// EVENT HANDLERS
		////////////////////
		
		private function onContinueClick(e:MouseEvent):void
		{
			dispatchEvent(new Event('skip'));
		}
		
		private function onExitClick(e:MouseEvent):void
		{
			dispatchEvent(new Event('exit'));
		}
		
	}
}