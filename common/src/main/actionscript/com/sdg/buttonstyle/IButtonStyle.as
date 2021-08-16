package com.sdg.buttonstyle
{
	import com.sdg.display.BoxStyle;
	
	public interface IButtonStyle
	{
		function get offStyle():BoxStyle;
		function get overStyle():BoxStyle;
		function get downStyle():BoxStyle;
	}
}