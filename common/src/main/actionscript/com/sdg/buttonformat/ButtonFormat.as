package com.sdg.buttonformat
{
	import flash.text.TextFormat;
	import com.sdg.buttonformat.IButtonFormat;

	public class ButtonFormat extends Object implements IButtonFormat
	{
		protected var _off:TextFormat;
		protected var _over:TextFormat;
		protected var _down:TextFormat;
		
		public function ButtonFormat(off:TextFormat, over:TextFormat, down:TextFormat)
		{
			super();

			_off = off;
			_over = over;
			_down = down;
		}
		
		public function get offFormat():TextFormat
		{
			return _off;
		}
		
		public function get overFormat():TextFormat
		{
			return _over;
		}
		
		public function get downFormat():TextFormat
		{
			return _down;
		}
		
	}
}