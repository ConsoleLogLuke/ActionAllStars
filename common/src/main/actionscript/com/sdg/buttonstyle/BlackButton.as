package com.sdg.buttonstyle
{
	import com.sdg.display.BoxStyle;
	import com.sdg.display.GradientFillStyle;
	
	import flash.display.GradientType;

	public class BlackButton extends Object implements IButtonStyle
	{
		private var _offStyle:BoxStyle;
		private var _overStyle:BoxStyle;
		private var _downStyle:BoxStyle;
		
		public function BlackButton()
		{
			super();
			
			_offStyle = new BoxStyle(new GradientFillStyle(GradientType.LINEAR, [0x222222, 0x000000], [1, 1], [1, 180], Math.PI/2), 0xffffff, 1, 2, 10);
			_overStyle = new BoxStyle(new GradientFillStyle(GradientType.LINEAR, [0x222222, 0x000000], [1, 1], [1, 180], Math.PI/2), 0xffffff, 1, 2, 10);
			_downStyle = new BoxStyle(new GradientFillStyle(GradientType.LINEAR, [0x222222, 0x000000], [1, 1], [1, 180], Math.PI/2), 0xffffff, 1, 2, 10);
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