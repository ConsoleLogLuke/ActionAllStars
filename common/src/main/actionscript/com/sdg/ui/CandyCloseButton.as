package com.sdg.ui
{
	import com.good.goodgraphics.GoodPlus;
	import com.good.goodgraphics.GoodRect;
	import com.good.goodui.FluidView;
	
	import flash.display.Sprite;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;

	public class CandyCloseButton extends FluidView
	{
		protected var _back:GoodRect;
		protected var _x:Sprite;
		protected var _xSizeRatio:Number;
		
		public function CandyCloseButton(size:Number)
		{
			_xSizeRatio = 0.6;
			
			_back = new GoodRect(size, size, size);
			_back.filters = [new GlowFilter(0xffffff, 1, 3, 3, 10, 1)];
			
			_x = new Sprite();
			var plus:GoodPlus = new GoodPlus(size * _xSizeRatio, size * _xSizeRatio, 0xffffff, 0.23);
			plus.x = -plus.width / 2;
			plus.y = -plus.height / 2;
			_x.addChild(plus);
			_x.rotation = 45;
			_x.filters = [new DropShadowFilter(1, 45, 0, 1, 3, 3)];
			
			super(size, size);
			
			addChild(_back);
			addChild(_x);
			
			render();
		}
		
		override protected function render():void
		{
			_x.x = _width / 2;
			_x.y = _height / 2;
		}
		
		override public function set width(value:Number):void
		{
			_width = value;
			_height = value;
			
			render();
		}
		
		override public function set height(value:Number):void
		{
			_width = value;
			_height = value;
			
			render();
		}
		
	}
}