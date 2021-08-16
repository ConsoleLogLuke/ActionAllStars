package com.sdg.view
{
	import flash.display.Sprite;

	public class QuestCardContainer extends Sprite
	{
		private var _width:Number;
		private var _height:Number;
		private var _backing:Sprite;
		private var _questCard:QuestCard;
		
		public function QuestCardContainer(width:Number, height:Number, questCard:QuestCard)
		{
			super();
			
			_width = width;
			_height = height;
			_questCard = questCard;
			
			// Backing.
			_backing = new Sprite();
			addChild(_backing);
			
			addChild(_questCard);
			
			render();
		}
		
		private function render():void
		{
			// Backing.
			_backing.graphics.clear();
			_backing.graphics.beginFill(0, 0.8);
			_backing.graphics.drawRect(0, 0, _width, _height);
			
			// Quest Card.
			_questCard.x = _width / 2 - _questCard.width / 2;
			_questCard.y = _height / 2 - _questCard.height / 2;
		}
		
	}
}