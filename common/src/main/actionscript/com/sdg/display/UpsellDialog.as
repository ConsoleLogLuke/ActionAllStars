package com.sdg.display
{
	import com.sdg.buttonstyle.AASButtonStyles;
	import com.sdg.controls.AASDialogButton;
	import com.sdg.ui.UI3PartWindow;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	public class UpsellDialog extends UI3PartWindow
	{
		public static const GO_PRO:String = 'go pro';
		public static const NO_THANKS:String = 'no thanks';
		
		private var _message:String;
		private var _messageField:TextField;
		
		public function UpsellDialog(message:String)
		{
			super();
			
			_message = message;
			
			// Create a message text field.
			_messageField = new TextField();
			_messageField.defaultTextFormat = new TextFormat('GillSans', 24, 0x1a3968, true, null, null, null, null, TextFormatAlign.CENTER);
			_messageField.autoSize = TextFieldAutoSize.CENTER;
			_messageField.multiline = true;
			_messageField.wordWrap = true;
			_messageField.width = 400;
			_messageField.text = _message;
			_middle.content = _messageField;
			_middle.alignX = AlignType.MIDDLE;
			
			// Create new buttons for upsell.
			var btnStack:Stack = new Stack(AlignType.HORIZONTAL, 20);
			var upsellBtn:AASDialogButton = new AASDialogButton('Go Pro', 140, 40, AASButtonStyles.BLUE_BUTTON);
			upsellBtn.label.embedFonts = true;
			upsellBtn.addEventListener(MouseEvent.CLICK, _onUpsellClick);
			btnStack.addContainer(upsellBtn);
			var noThanksBtn:AASDialogButton = new AASDialogButton('No Thanks');
			noThanksBtn.label.embedFonts = true;
			noThanksBtn.addEventListener(MouseEvent.CLICK, _onNoThanksClick);
			btnStack.addContainer(noThanksBtn);
			_bottom.content = btnStack;
			
			backing = new AASPanelBacking();
			
			padding = 28;
		}
		
		////////////////////
		// EVENT HANDLERS
		////////////////////
		
		private function _onUpsellClick(e:MouseEvent):void
		{
			dispatchEvent(new Event(GO_PRO));
		}
		
		private function _onNoThanksClick(e:MouseEvent):void
		{
			dispatchEvent(new Event(NO_THANKS));
		}
		
	}
}