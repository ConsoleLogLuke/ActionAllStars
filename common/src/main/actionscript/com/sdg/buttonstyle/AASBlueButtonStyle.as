package com.sdg.buttonstyle
{
	import com.sdg.display.BoxStyle;
	import com.sdg.display.GradientFillStyle;
	
	import flash.display.GradientType;
	import flash.geom.Matrix;

	public class AASBlueButtonStyle extends Object implements IButtonStyle
	{
		private var _offStyle:BoxStyle;
		private var _overStyle:BoxStyle;
		private var _downStyle:BoxStyle;
		
		public function AASBlueButtonStyle()
		{
			super();
			
			_offStyle = new BoxStyle(new GradientFillStyle(GradientType.LINEAR, [0x62b1fe, 0x1875bb], [1, 1], [1, 180], Math.PI/2), 0x065ea1, 1, 4, 14);
			_overStyle = new BoxStyle(new GradientFillStyle(GradientType.LINEAR, [0x9bcaf7, 0x4689bb], [1, 1], [1, 180], Math.PI/2), 0x065ea1, 1, 4, 14);
			_downStyle = new BoxStyle(new GradientFillStyle(GradientType.LINEAR, [0x4a98e5, 0x1a659d], [1, 1], [1, 180], Math.PI/2), 0x065ea1, 1, 4, 14);
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