package com.sdg.leaderboard.view
{
	import com.boostworthy.animation.management.AnimationManager;
	import com.good.goodui.FluidView;
	import com.sdg.model.Avatar;
	import com.sdg.model.ISetAvatar;
	import com.sdg.view.avatarcard.AvatarCardTwoSide;
	import com.sdg.view.avatarcard.IntegratedAvatarInfoPanel;
	
	import flash.display.Sprite;
	import flash.events.Event;

	public class LeaderboardUserCard extends FluidView implements ISetAvatar
	{
		public static const NEW_CARD:String = 'new card';
		public static const NEW_CARD_TIMEOUT:String = 'new card timeout';
		
		protected var _avatar:Avatar;
		protected var _card:IntegratedAvatarInfoPanel;
		protected var _animManager:AnimationManager;
		
		public function LeaderboardUserCard(width:Number, height:Number)
		{
			_animManager = new AnimationManager();
			
			super(width, height);
		}
		
		////////////////////
		// PROTECTED METHODS
		////////////////////
		
		override protected function render():void
		{
			super.render();
			
			graphics.clear();
			graphics.beginFill(0, 0.5);
			graphics.drawRect(0, 0, _width, _height);
			
			if (_card)
			{
				var cardMargin:Number = _width * 0.1;
				_card.width = _width - cardMargin
				_card.height = _height - cardMargin;
				_card.x = cardMargin / 2;
				_card.y = cardMargin / 2;
			}
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		public function get avatar():Avatar
		{
			return _avatar;
		}
		public function set avatar(value:Avatar):void
		{
			// Make sure it's not the same avatar.
			if (_avatar != null && value.id == _avatar.id) return;
			_avatar = value;
			
			var oldCard:Sprite = _card;
			var newCard:AvatarCardTwoSide;
			var oldCardRemoved:Boolean = false;
			var newCardShown:Boolean = false;
			
			// Swap out old card.
			if (_card)
			{
				removeChild(_card);
				_card.destroy();
			}
			
			// Set new card.
			_card = new IntegratedAvatarInfoPanel(_avatar, 340, 520, false, false, false, true);
			var cardMargin:Number = _width * 0.1;
			_card.width = _width - cardMargin
			_card.height = _height - cardMargin;
			_card.x = cardMargin / 2;
			_card.y = cardMargin / 2;
			addChild(_card);
			
			dispatchEvent(new Event(NEW_CARD));
		}
		
	}
}