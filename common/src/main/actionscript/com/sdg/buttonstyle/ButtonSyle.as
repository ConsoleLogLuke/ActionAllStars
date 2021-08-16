package com.sdg.buttonstyle
{
	import com.sdg.display.BoxStyle;

	public class ButtonSyle extends Object implements IButtonStyle
	{
		protected var _off:BoxStyle;
		protected var _over:BoxStyle;
		protected var _down:BoxStyle;
		
		public function ButtonSyle(off:BoxStyle, over:BoxStyle, down:BoxStyle)
		{
			super();
			
			_off = off;
			_over = over;
			_down = down;
		}
		
		public function get offStyle():BoxStyle
		{
			return _off;
		}
		
		public function get overStyle():BoxStyle
		{
			return _over;
		}
		
		public function get downStyle():BoxStyle
		{
			return _down;
		}
		
	}
}