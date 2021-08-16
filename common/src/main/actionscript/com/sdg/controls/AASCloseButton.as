package com.sdg.controls
{
	import com.sdg.buttonstyle.AASButtonStyles;
	
	import flash.text.TextFormat;

	public class AASCloseButton extends BasicButton
	{
		public function AASCloseButton(width:Number = 20, height:Number = 20)
		{
			super('X', width, height, AASButtonStyles.CLOSE_BUTTON);
			
			_label.setTextFormat(new TextFormat('GillSans', 12, 0xffffff));
			_label.embedFonts = true;
		}
		
	}
}