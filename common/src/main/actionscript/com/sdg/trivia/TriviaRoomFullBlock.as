package com.sdg.trivia
{
	import com.sdg.display.AlignType;
	import com.sdg.display.Box;
	import com.sdg.display.BoxStyle;
	import com.sdg.display.Container;
	import com.sdg.display.FillStyle;
	import com.sdg.font.AASFonts;
	
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	public class TriviaRoomFullBlock extends Container
	{
		public function TriviaRoomFullBlock(width:Number=0, height:Number=0, text:String = 'SOLD OUT')
		{
			super(width, height);
			
			_alignX = _alignY = AlignType.MIDDLE;
			
			var textField:TextField = new TextField();
			textField.autoSize = TextFieldAutoSize.LEFT;
			textField.defaultTextFormat = new TextFormat(AASFonts.GILL_SANS, 14, 0xffffff, true);
			textField.text = text;
			
			backing = new Box();
			_backing.style = new BoxStyle(new FillStyle(0x222222, 1), 0, 0, 0, 10);
			
			content = textField;
		}
		
	}
}