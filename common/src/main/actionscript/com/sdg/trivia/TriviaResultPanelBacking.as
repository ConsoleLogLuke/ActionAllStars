package com.sdg.trivia
{
	import com.sdg.display.AASPanelBacking;
	
	import flash.display.BlendMode;
	import flash.display.Sprite;
	import flash.filters.BlurFilter;

	public class TriviaResultPanelBacking extends AASPanelBacking
	{
		private var _starLayer:Sprite;
		private var _starMask:Sprite;
		
		public function TriviaResultPanelBacking(width:Number=0, height:Number=0)
		{
			super(width, height);
			
			// Create random stars.
			_starLayer = new Sprite();
			_starMask = new Sprite();
			var i:int = 0;
			var len:int = 30;
			var star:Sprite;
			var scale:Number;
			var blur:Number;
			for (i; i < len; i++)
			{
				star = new AASStar();
				scale = Math.random() * 0.8 + 0.4;
				blur = Math.random() * 6 + 4;
				star.width *= scale;
				star.height *= scale;
				star.x = Math.random() * 800 - 400;
				star.y = Math.random() * 80 - 40;
				star.alpha = Math.random() * 0.3 + 0.1;
				star.filters = [new BlurFilter(blur, blur)];
				star.blendMode = BlendMode.ADD;
				_starLayer.addChild(star);
			}
			
			_fill.addChild(_starLayer);
			_fill.addChild(_starMask);
			_starLayer.mask = _starMask;
		}
		
		override public function render():void
		{
			super.render();
			
			_starLayer.x = _width / 2;
			_starLayer.y = 30;
			
			_starMask.graphics.clear();
			_starMask.graphics.beginFill(0);
			_starMask.graphics.drawRoundRect(_lineThickness, _lineThickness, _width - _doubleLine, _height - _doubleLine, _cornerSize - _lineThickness, _cornerSize - _lineThickness);
		}
		
	}
}