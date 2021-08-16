package com.sdg.ui
{
	import flash.display.Sprite;
	import flash.media.Sound;

	public class InteractiveSoundMaker extends Sprite
	{
		protected var _overSound:Sound;
		protected var _outSound:Sound;
		protected var _clickSound:Sound;
		
		public function InteractiveSoundMaker()
		{
			super();
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		public function get overSound():Sound
		{
			return _overSound;
		}
		public function set overSound(value:Sound):void
		{
			_overSound = value;
		}
		
		public function get outSound():Sound
		{
			return _outSound;
		}
		public function set outSound(value:Sound):void
		{
			_outSound = value;
		}
		
		public function get clickSound():Sound
		{
			return _clickSound;
		}
		public function set clickSound(value:Sound):void
		{
			_clickSound = value;
		}
		
	}
}