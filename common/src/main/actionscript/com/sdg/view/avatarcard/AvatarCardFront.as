package com.sdg.view.avatarcard
{
	import com.good.goodui.FluidView;
	import com.sdg.display.AvatarSprite;
	import com.sdg.events.AvatarApparelEvent;
	import com.sdg.model.Avatar;
	import com.sdg.model.Level;
	import com.sdg.net.QuickLoader;
	import com.sdg.util.AssetUtil;
	import com.sdg.utils.BitmapUtil;
	import com.sdg.utils.ItemUtil;
	import com.sdg.view.BadgeIcon;
	import com.sdg.view.LayeredImage;
	
	import flash.display.Bitmap;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	public class AvatarCardFront extends FluidView
	{
		public static const FLIP_CLICK:String = 'flip click';
		
		protected var _back:Sprite;
		protected var _flipBtn:Sprite;
		protected var _avatarImg:LayeredImage;
		protected var _avatarBack:Sprite;
		protected var _maskedContent:Sprite;
		protected var _mask:Sprite;
		protected var _avatar:Avatar;
		protected var _outline:Sprite;
		protected var _nameField:TextField;
		protected var _dropShadow:DropShadowFilter;
		protected var _teamLogo:Sprite;
		protected var _subLevelIndicator:SubLevelIndicator;
		protected var _stroke:GlowFilter;
		protected var _mvp:TextField;
		protected var _badge:Sprite;
		protected var _avatarBackgroundId:uint;
		
		public function AvatarCardFront(avatar:Avatar, width:Number, height:Number)
		{
			_avatar = avatar;
			_dropShadow = new DropShadowFilter(1, 45, 0, 0.7, 4, 4);
			_stroke = new GlowFilter(0xffffff, 1, 2, 2, 10);
			
			_back = new Sprite();
			_back.cacheAsBitmap = true;
			
			_avatarImg = new LayeredImage();
			_avatarImg.mouseEnabled = false;
			_avatarImg.mouseChildren = false;
			_avatarImg.filters = AvatarSprite.DefaultAvatarPreviewFilters;
			_avatarImg.cacheAsBitmap = true;
			
			_flipBtn = new Sprite();
			_flipBtn.buttonMode = true;
			_flipBtn.cacheAsBitmap = true;
			
			_mask = new Sprite();
			
			_maskedContent = new Sprite();
			_maskedContent.mask = _mask;
			
			_avatarBack = new Sprite();
			
			_outline = new Sprite();
			
			_nameField = new TextField();
			_nameField.defaultTextFormat = new TextFormat('EuroStyle', 18, 0xffffff, true, true);
			_nameField.embedFonts = true;
			_nameField.selectable = false;
			_nameField.autoSize = TextFieldAutoSize.LEFT;
			_nameField.text = _avatar.name;
			_nameField.filters = [_dropShadow];
			_nameField.cacheAsBitmap = true;
			
			_mvp = new TextField();
			_mvp.defaultTextFormat = new TextFormat('EuroStyle', 12, 0xffffff, true, true);
			_mvp.embedFonts = true;
			_mvp.selectable = false;
			_mvp.autoSize = TextFieldAutoSize.LEFT;
			_mvp.text = 'MVP';
			_mvp.cacheAsBitmap = true;
			
			_subLevelIndicator = new SubLevelIndicator(28, _avatar.subLevel, Level.GetLevelColor(_avatar.level));
			_subLevelIndicator.cacheAsBitmap = true;
			
			_teamLogo = new Sprite();
			_teamLogo.cacheAsBitmap = true;
			
			_badge = new Sprite();
			
			super(width, height);
		}
		
		public function init():void
		{
			var flipBtnUrl:String = AssetUtil.GetGameAssetUrl(99, 'card_flip_button.swf');
			var flipBtn:Sprite = new QuickLoader(flipBtnUrl, render, null, 2);
			flipBtn.mouseChildren = false;
			_flipBtn.addChild(flipBtn);
			_flipBtn.addEventListener(MouseEvent.CLICK, onFlipClick);
			
			addChild(_back);
			addChild(_mask);
			addChild(_maskedContent);
			addChild(_outline);
			addChild(_subLevelIndicator);
			addChild(_badge);
			addChild(_teamLogo);
			addChild(_mvp);
			addChild(_nameField);
			addChild(_flipBtn);
			_maskedContent.addChild(_avatarBack);
			
			update();
			
			// Add event listeners.
			_avatar.addEventListener(AvatarApparelEvent.AVATAR_APPAREL_CHANGED, onAvatarApparelChanged);
		}
		
		public function destroy():void
		{
			// Remove event listeners.
			_avatar.removeEventListener(AvatarApparelEvent.AVATAR_APPAREL_CHANGED, onAvatarApparelChanged);
		}
		
		override protected function render():void
		{
			_back.width = _width;
			_back.height = _height;
			
			_flipBtn.x = _width - _flipBtn.width;
			_flipBtn.y = _height - _flipBtn.height;
			
			_mask.graphics.clear();
			_mask.graphics.beginFill(0x00ff00);
			drawInnerRect(_mask.graphics);
			_mask.x = 10;
			_mask.y = _height * 0.125;
			
			_maskedContent.x = _mask.x;
			_maskedContent.y = _mask.y;
			
			var avScale:Number = Math.min(_mask.width / _avatarImg.width, _mask.height / _avatarImg.height);
			_avatarImg.width *= avScale;
			_avatarImg.height *= avScale;
			_avatarImg.x = _mask.width / 2 - _avatarImg.width / 2;
			_avatarImg.y = _mask.height / 2 - _avatarImg.height / 2;
			
			_avatarBack.width = _mask.width;
			_avatarBack.height = _mask.height;
			
			_outline.graphics.clear();
			_outline.graphics.lineStyle(2, 0xffffff);
			drawInnerRect(_outline.graphics);
			_outline.x = _mask.x;
			_outline.y = _mask.y;
			
			var maskBottom:Number = _mask.y + _mask.height;
			_nameField.x = _width / 2 - _nameField.width / 2;
			_nameField.y = maskBottom + ((_height - maskBottom) / 2 - _nameField.height / 2);
			
			_subLevelIndicator.x = _mask.x + 10;
			_subLevelIndicator.y = _mask.y + 10;
			
			var tmLogoScale:Number = 65 / _teamLogo.width;
			_teamLogo.width *= tmLogoScale;
			_teamLogo.height *= tmLogoScale;
			_teamLogo.x = _mask.x + _mask.width - _teamLogo.width - 10;
			_teamLogo.y = _mask.y + 10;
			
			_mvp.x = _mask.x;
			_mvp.y = _mask.y + _mask.height + 2;
			
			var badgeScale:Number = 65 / _badge.height;
			_badge.width *= badgeScale;
			_badge.height *= badgeScale;
			_badge.x = _mask.x + 10;
			_badge.y = _mask.y + _mask.height - _badge.height - 10;
		}
		
		protected function drawInnerRect(gfx:Graphics):void
		{
			gfx.drawRoundRect(0, 0, _width - 20, _height * 0.75, 20, 20);
		}
		
		protected function update():void
		{
			updateAvatarInventory();
			
			if (_back.numChildren > 0) _back.removeChildAt(0);
			var cardBackUrl:String = AssetUtil.GetGameAssetUrl(99, 'avatar_card_front_' + _avatar.level.toString() + '.swf');
			var cardBack:Sprite = new QuickLoader(cardBackUrl, render, null, 2);
			_back.addChild(cardBack);
			
			if (_avatar.equippedBadgeId > 0) var badge:BadgeIcon = new BadgeIcon(_avatar.equippedBadgeId, _avatar.equippedBadgeLevelIndex, onBadgeComplete);
			
			// Load logo.
			if (_teamLogo.numChildren > 0) _teamLogo.removeChildAt(0);
			var logoUrl:String = AssetUtil.GetTeamLogoUrl(_avatar.favoriteTeamId);
			var logo:Sprite = new QuickLoader(logoUrl, render);
			_teamLogo.addChild(logo);
			_teamLogo.filters = [_stroke];
			
			_mvp.visible = (_avatar.membershipStatus == 2); // Visible if avatar is premium.
			
			render();
			
			function onBadgeComplete():void
			{
				// Add the badge and render.
				if (_badge.numChildren > 0) _badge.removeChildAt(0);
				_badge.addChild(badge);
				render();
			}
		}
		
		protected function updateAvatarInventory():void
		{
			dispatchEvent(new Event('load new avatar'));
			var loadComplete:Boolean = false;
			addEventListener('load new avatar', onLoadNewAvatar);
			
			_avatarImg.addEventListener(Event.COMPLETE, onAvatarImageComplete);
			if (_maskedContent.contains(_avatarImg)) _maskedContent.removeChild(_avatarImg);
			_avatarImg.loadItemImage(_avatar);
			
			var backgroundId:uint = (_avatar.background) ? _avatar.background.itemId : 4167;
			if (backgroundId != _avatarBackgroundId)
			{
				// Set new ID.
				_avatarBackgroundId = backgroundId;
				// Remove previous background.
				if (_avatarBack.numChildren > 0) _avatarBack.removeChildAt(0);
				// Get URL for new background.
				var backgroundUrl:String = ItemUtil.GetPreviewUrl(_avatarBackgroundId);
				// Load new background.
				var avBack:Sprite = new QuickLoader(backgroundUrl, render, null, 2);
				_avatarBack.addChild(avBack);
			}
			
			function onLoadNewAvatar(e:Event):void
			{
				// If a new avatar is gonna be loaded before this one has finished loading,
				// cancel this load in favor of the new one.
				if (loadComplete == false)
				{
					// Remove event listeners.
					_avatarImg.removeEventListener(Event.COMPLETE, onAvatarImageComplete);
					removeEventListener('load new avatar', onLoadNewAvatar);
					// Cancel load.
					_avatarImg.close();
				}
			}
			
			function onAvatarImageComplete(e:Event):void
			{
				// Remove event listener.
				_avatarImg.removeEventListener(Event.COMPLETE, onAvatarImageComplete);
				
				// Add to display.
				_maskedContent.addChild(_avatarImg);
				
				render();
				
				// Dispatch complete event.
				dispatchEvent(new Event(Event.COMPLETE));
			}
		}
		
		public function getScaledBitmap(scale:Number,smooth:Boolean=false):Bitmap
		{
			
			var cardMap:Bitmap = BitmapUtil.spriteToBitmap(this,smooth);
			cardMap.scaleX *= scale;
			cardMap.scaleY *= scale;
			
			return cardMap;
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		
		
		////////////////////
		// EVENT HANDLERS
		////////////////////
		
		private function onFlipClick(e:MouseEvent):void
		{
			dispatchEvent(new Event(FLIP_CLICK, true));
		}
		
		private function onAvatarApparelChanged(e:AvatarApparelEvent):void
		{
			// Reload the avatar image.
			updateAvatarInventory();
		}
		
	}
}