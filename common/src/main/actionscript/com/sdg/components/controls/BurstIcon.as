package com.sdg.components.controls
{
	import com.sdg.model.Reward;
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;

	public class BurstIcon extends Sprite
	{
		private var _display:DisplayObject;
		private var _value:int;
		
		public function BurstIcon(assetClass:Class, value:int)
		{
			super();
			
			_value = value;
			
			_display = new assetClass();
			addChild(_display);
		}
		
		public function collect():void
		{
			if (_display == null) return;
			
			MovieClip(_display).gotoAndPlay("collect");
		}
		
		public function get value():int
		{
			return _value;
		}
		
		public function get burstType():uint
		{
			var type:uint;
			if (_display is BurstToken)
				type = Reward.CURRENCY;
			else if (_display is BurstPoint)
				type = Reward.EXPERIENCE;
			
			return type;
		}
	}
}