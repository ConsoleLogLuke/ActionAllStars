package com.sdg.view.avatarcard
{
	import com.good.goodui.FluidView;
	import com.sdg.events.AvatarApparelEvent;
	import com.sdg.model.Avatar;
	import com.sdg.view.LayeredImage;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.GlowFilter;

	public class AvatarCardHeadShot extends FluidView
	{
		protected static const _avScaleFactor:Number = 1.7;
		protected static const _innerGlow:GlowFilter = new GlowFilter(0, 1, 18, 18, 2, 1, true);
		protected var _avatarImage:Sprite;
		protected var _back:Sprite;
		protected var _outline:Sprite;
		protected var _mask:Sprite;
		protected var _maskedContent:Sprite;
		protected var _isInit:Boolean;
		protected var _avatar:Avatar;
		protected var _backColor:uint;
		protected var _lineColor:uint;
		
		public function AvatarCardHeadShot(avatar:Avatar, size:Number = 100, backgroundColor:uint = 0x0000ff, lineColor:uint = 0xffffff, autoInit:Boolean = false)
		{
			_isInit = false;
			_avatar = avatar;
			_backColor = backgroundColor;
			_lineColor = lineColor;
			
			_avatarImage = new Sprite();
			
			_back = new Sprite();
			_back.filters = [_innerGlow];
			
			_outline = new Sprite();
			
			_mask = new Sprite();
			
			_maskedContent = new Sprite();
			_maskedContent.mask = _mask;
			
			addChild(_maskedContent);
			addChild(_mask);
			addChild(_outline);
			_maskedContent.addChild(_back);
			_maskedContent.addChild(_avatarImage);
			
			super(size, size);
			
			if (autoInit == true) init();
		}
		
		public function init():void
		{
			if (_isInit == true) return;
			_isInit = true;
			
			updateAvatar();
			
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
			super.render();
			
			_back.graphics.clear();
			_back.graphics.beginFill(_backColor);
			_back.graphics.drawEllipse(0, 0, _width, _height);
			
			_mask.graphics.clear();
			_mask.graphics.beginFill(0x00ff00);
			_mask.graphics.drawEllipse(0, 0, _width, _height);
			
			_outline.graphics.clear();
			_outline.graphics.lineStyle(2, _lineColor);
			_outline.graphics.drawEllipse(0, 0, _width, _height);
			
			// Scale avatar image.
			var avScale:Number = _width / _avatarImage.width * _avScaleFactor;
			_avatarImage.width *= avScale;
			_avatarImage.height *= avScale;
			// Position avatar image depending on gender.
			var avX:Number = _width / 2 - _avatarImage.width / 2;
			if (_avatar.gender == 2) avX += _avatarImage.width * 0.05;
			_avatarImage.x = avX;
			_avatarImage.y = -_avatarImage.height * 0.07;
		}
		
		protected function updateAvatar():void
		{
			// Load avatar image.
			var layeredImage:LayeredImage = new LayeredImage();
			layeredImage.addEventListener(Event.COMPLETE, onComplete);
			layeredImage.loadItemImage(_avatar);
			
			function onComplete(e:Event):void
			{
				// Remove listener.
				layeredImage.removeEventListener(Event.COMPLETE, onComplete);
				
				// Remove previous image.
				if (_avatarImage.numChildren > 0) _avatarImage.removeChildAt(0);
				
				// Add to display.
				var imageCopy:Sprite = getBitmapCopy(layeredImage);
				_avatarImage.addChild(imageCopy);
				
				// Render.
				render();
				
				// Dispatch complete event.
				dispatchEvent(new Event(Event.COMPLETE));
			}
		}
		
		protected function getBitmapCopy(original:DisplayObject):Sprite
		{
			var bitmapData:BitmapData = new BitmapData(original.width, original.height, true, 0x00ff00);
			bitmapData.draw(original);
			var bitmap:Bitmap = new Bitmap(bitmapData, 'auto', true);
			
			var copy:Sprite = new Sprite();
			copy.addChild(bitmap);
			
			return copy;
		}
		
		////////////////////
		// EVENT HANDLERS
		////////////////////
		
		private function onAvatarApparelChanged(e:AvatarApparelEvent):void
		{
			updateAvatar();
		}
		
	}
}