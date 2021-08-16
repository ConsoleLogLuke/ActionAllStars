package com.sdg.controls
{
	import com.sdg.buttonstyle.AASButtonStyles;
	import com.sdg.buttonstyle.IButtonStyle;
	import com.sdg.font.FontStyles;
	
	import flash.filters.BevelFilter;
	import flash.filters.BitmapFilterType;
	import flash.text.TextFormat;
	
	public class AASDialogButton extends BasicButton
	{
		public function AASDialogButton(label:String, width:Number = 140, height:Number = 40, style:IButtonStyle = null)
		{
			super(label, width, height);
			
			if (style == null) style = AASButtonStyles.ORANGE_BUTTON;
			
			_label.setTextFormat(new TextFormat('GillSans', 14, 0xffffff, true));
			_label.styleSheet = FontStyles.GILL_SANS;
			_label.filters = [new  BevelFilter(1, 45, 0, 0.5, 0xffffff, 0.5, 2, 2, 1, 1, BitmapFilterType.OUTER)];
			
			_offStyle = style.offStyle;
			_overStyle = style.overStyle;
			_downStyle = style.downStyle;
			
			_buttonBacking.style = _offStyle;
		}
		
	}
}