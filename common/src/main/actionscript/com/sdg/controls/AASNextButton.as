package com.sdg.controls
{
	import com.sdg.display.BoxStyle;
	import com.sdg.display.GradientFillStyle;
	import com.sdg.display.ShapeBox;
	import com.sdg.shape.PointRightBox;
	
	import flash.display.GradientType;
	import flash.filters.BevelFilter;
	import flash.filters.BitmapFilterType;
	import flash.geom.Matrix;
	import flash.text.TextFormat;
	
	public class AASNextButton extends BasicButton
	{
		public function AASNextButton(label:String = 'Next', width:Number = 100, height:Number = 34)
		{
			super(label, width, height);
			
			_label.setTextFormat(new TextFormat('GillSans', 14, 0xffffff, true));
			_label.filters = [new  BevelFilter(1, 45, 0, 0.5, 0xffffff, 0.5, 2, 2, 1, 1, BitmapFilterType.OUTER)];
			
			_offStyle = new BoxStyle(new GradientFillStyle(GradientType.LINEAR, [0xface6d, 0xdd8200], [1, 1], [1, 180], Math.PI/2), 0x904d00, 1, 3, 0);
			_overStyle = new BoxStyle(new GradientFillStyle(GradientType.LINEAR, [0xface6d, 0xe99e27], [1, 1], [1, 180], Math.PI/2), 0x904d00, 1, 3, 0);
			_downStyle = new BoxStyle(new GradientFillStyle(GradientType.LINEAR, [0xface6d, 0xc97500], [1, 1], [1, 180], Math.PI/2), 0x904d00, 1, 3, 0);
			
			_buttonBacking = new ShapeBox(new PointRightBox(0, 0, _width, _height, 12), _width, _height);
			_buttonBacking.style = _offStyle;
			backing = _buttonBacking;
		}
		
	}
}