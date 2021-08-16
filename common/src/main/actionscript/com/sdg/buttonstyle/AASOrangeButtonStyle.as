package com.sdg.buttonstyle
{
	import com.sdg.display.BoxStyle;
	import com.sdg.display.GradientFillStyle;
	
	import flash.display.GradientType;

	public class AASOrangeButtonStyle extends Object implements IButtonStyle
	{
		private var _offStyle:BoxStyle;
		private var _overStyle:BoxStyle;
		private var _downStyle:BoxStyle;
		
		public function AASOrangeButtonStyle()
		{
			super();
			
			_offStyle = new BoxStyle(new GradientFillStyle(GradientType.LINEAR, [0xface6d, 0xdd8200], [1, 1], [1, 180], Math.PI/2), 0x904d00, 1, 4, 14);
			_overStyle = new BoxStyle(new GradientFillStyle(GradientType.LINEAR, [0xface6d, 0xe99e27], [1, 1], [1, 180], Math.PI/2), 0x904d00, 1, 4, 14);
			_downStyle = new BoxStyle(new GradientFillStyle(GradientType.LINEAR, [0xface6d, 0xc97500], [1, 1], [1, 180], Math.PI/2), 0x904d00, 1, 4, 14);
		}
		
		public function get offStyle():BoxStyle
		{
			return _offStyle;
		}
		
		public function get overStyle():BoxStyle
		{
			return _overStyle;
		}
		
		public function get downStyle():BoxStyle
		{
			return _downStyle;
		}
		
	}
}