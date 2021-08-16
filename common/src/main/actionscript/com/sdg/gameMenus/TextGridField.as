package com.sdg.gameMenus
{
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	public class TextGridField extends GridField
	{
		public function TextGridField(width:Number, height:Number, textString:String, fontSize:int = 16, centerAligned:Boolean=true, leftMargin:int=0)
		{
			var fieldText:TextField = new TextField();
			fieldText.defaultTextFormat = new TextFormat('EuroStyle', fontSize, 0x335580, true);
			fieldText.embedFonts = true;
			fieldText.autoSize = TextFieldAutoSize.LEFT;
			fieldText.selectable = false;
			fieldText.mouseEnabled = false;
			fieldText.text = textString;
			
			super(width, height, fieldText, centerAligned, leftMargin);
		}
	}
}