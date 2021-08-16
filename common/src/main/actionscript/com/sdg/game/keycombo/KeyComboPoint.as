package com.sdg.game.keycombo
{
	import com.sdg.view.FluidView;
	
	import flash.display.Sprite;

	public class KeyComboPoint extends FluidView
	{
		private var _fillValue:Number;
		private var _back:Sprite;
		private var _fill:Sprite;
		private var _stroke:Sprite;
		private var _mask:Sprite;
		
		public function KeyComboPoint(width:Number, height:Number)
		{
			super(width, height);
			
			_fillValue = 0;
			_back = new Sprite();
			_stroke = new Sprite();
			_mask = new Sprite();
			_fill = new Sprite();
			_fill.mask = _mask;
			
			render();
			
			addChild(_back);
			addChild(_fill);
			addChild(_stroke);
			addChild(_mask);
		}
		
		////////////////////
		// PROTECTED FUNCTIONS
		////////////////////
		
		override protected function render():void
		{
			super.render();
			
			var hW:Number = _width / 2;
			
			_back.graphics.clear();
			_back.graphics.beginFill(0xefa412);
			_back.graphics.drawCircle(0, 0, hW);
			
			_mask.graphics.clear();
			_mask.graphics.beginFill(0x00ff00);
			_mask.graphics.drawCircle(0, 0, hW);
			
			renderFill(hW);
			
			_stroke.graphics.clear();
			_stroke.graphics.lineStyle(3, 0);
			_stroke.graphics.drawCircle(0, 0, hW);
		}
		
		////////////////////
		// PRIVATE FUNCTIONS
		////////////////////
		
		private function renderFill(hW:Number = 0):void
		{
			if (!hW) hW = _width / 2;
			_fill.graphics.clear();
			_fill.graphics.beginFill(0xffc432);
			_fill.graphics.drawRect(-hW, -hW, _width * _fillValue, _height);
		}
		
		////////////////////
		// GET/SET FUNCTIONS
		////////////////////
		
		public function get fillValue():Number
		{
			return _fillValue;
		}
		public function set fillValue(value:Number):void
		{
			if (value == _fillValue) return;
			_fillValue = value;
			renderFill();
		}
		
	}
}