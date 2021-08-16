package com.sdg.gameMenus
{
	import com.sdg.graphics.customShapes.SlantedStarShape;
	
	import flash.display.Sprite;

	public class RankStars extends Sprite
	{
		// INPUTS
		private var _rank:uint;
		private var _fillColor:uint;
		private var _starWidth:Number;
		private var _starHeight:Number;
		private var _starSpacing:Number;
		// INTERNALS
		private var _calcStars:uint;
		//private var _starParent:Sprite = new Sprite();
		private var _star1:Sprite = new Sprite();
		private var _star2:Sprite = new Sprite();
		private var _star3:Sprite = new Sprite();
		private var _star4:Sprite = new Sprite();
		private var _star5:Sprite = new Sprite();
		
		protected var starShape:SlantedStarShape;
		
		//NOTE: For starWidth:starHeight, use a ratio of 13:10 in the values for the usual star
		public function RankStars(rank:uint,starWidth:Number,starHeight:Number,starSpacing:Number,fillColor:uint)
		{
			super();
			
			starShape = new SlantedStarShape(starWidth,starHeight);
			
			_rank = rank;
			_fillColor = fillColor;
			_starWidth = starWidth;
			_starHeight = starHeight;
			_starSpacing = starSpacing;
			
			this.addChild(_star1);
			this.addChild(_star2);
			this.addChild(_star3);
			this.addChild(_star4);
			this.addChild(_star5);
			
			this.calculateStarsFromRank();
			
			this.drawStars();
		}
		
		private function drawStars():void
		{
			// Init Linestyle
			_star1.graphics.lineStyle(1,_fillColor,1);
			
			if (_calcStars >= 1)
			{
				_star1.graphics.beginFill(_fillColor,1)
				starShape.draw(_star1.graphics);
				_star1.graphics.endFill();
			}
			else
			{
				starShape.draw(_star1.graphics);
			}
			
			_star2.x = _star1.x + _starWidth + _starSpacing;
			_star2.y = 0;
			_star2.graphics.lineStyle(1,_fillColor,1); 
			
			
			if (_calcStars >= 2)
			{
				_star2.graphics.beginFill(_fillColor,1)
				starShape.draw(_star2.graphics);
				_star2.graphics.endFill();
			}
			else
			{
				starShape.draw(_star2.graphics);
			}
			
			_star3.x = _star2.x + _starWidth + _starSpacing;
			_star3.y = 0;
			_star3.graphics.lineStyle(1,_fillColor,1); 
			
			if (_calcStars >= 3)
			{
				_star3.graphics.beginFill(_fillColor,1)
				starShape.draw(_star3.graphics);
				_star3.graphics.endFill();
			}
			else
			{
				starShape.draw(_star3.graphics);
			}
			
			_star4.x = _star3.x + _starWidth + _starSpacing;
			_star4.y = 0;
			_star4.graphics.lineStyle(1,_fillColor,1); 
			
			if (_calcStars >= 4)
			{
				_star4.graphics.beginFill(_fillColor,1)
				starShape.draw(_star4.graphics);
				_star4.graphics.endFill();
			}
			else
			{
				starShape.draw(_star4.graphics);
			}
			
			_star5.x = _star4.x + _starWidth + _starSpacing;
			_star5.y = 0;
			_star5.graphics.lineStyle(1,_fillColor,1); 
			
			if (_calcStars >= 5)
			{
				_star5.graphics.beginFill(_fillColor,1)
				starShape.draw(_star5.graphics);
				_star5.graphics.endFill();
			}
			else
			{
				starShape.draw(_star5.graphics);
			}
		}
		
		
		// UTILITY FUNCTIONS
		// Sets _calcStars to the right value based on _rank
		private function calculateStarsFromRank():void
		{
			var rawStars:Number = 30 - _rank;
			if (rawStars > 23)
			{
				_calcStars = 5;
			}
			else if (rawStars > 17)
			{
				_calcStars = 4;
			}
			else if (rawStars > 11)
			{
				_calcStars = 3;
			}
			else if (rawStars > 5)
			{
				_calcStars = 2;
			}
			else
			{
				_calcStars = 1;
			}
		}
	}
}