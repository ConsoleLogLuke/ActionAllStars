package com.sdg.messageBoard.views
{
	import flash.display.Sprite;
	import flash.filters.GlowFilter;

	public class MessageOptionButton extends Sprite
	{
		protected var _value:Object;
		protected var _highlighted:Boolean;
		
		public function MessageOptionButton(value:Object)
		{
			super();
			
			_value = value;
			buttonMode = true;
		}
		
		public function setHighlight(value:Boolean):void
		{
			if (_highlighted == value) return;
			
			_highlighted = value;
			var bgFilter:Array = filters;
			if (_highlighted)
			{
				bgFilter.push(new GlowFilter(0xffffff, 1, 10, 10, 10));
			}
			else
			{
				bgFilter.pop();
			}
			filters = bgFilter;
		}
		
		public function get value():Object
		{
			return _value;
		}
	}
}