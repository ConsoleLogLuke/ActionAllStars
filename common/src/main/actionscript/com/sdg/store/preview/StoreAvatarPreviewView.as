package com.sdg.store.preview
{
	import com.boostworthy.animation.easing.Transitions;
	import com.boostworthy.animation.management.AnimationManager;
	import com.boostworthy.animation.rendering.RenderMethod;
	import com.boostworthy.events.AnimationEvent;
	import com.sdg.mvc.ViewBase;
	
	import flash.display.DisplayObject;
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.Timer;

	public class StoreAvatarPreviewView extends ViewBase implements IStoreAvatarPreviewView
	{
		protected var _nameField:TextField;
		protected var _avatarImage:DisplayObject;
		protected var _background:DisplayObject;
		protected var _animationManager:AnimationManager;
		protected var _avatarLayer:Sprite;
		protected var _userTokens:int;
		protected var _tokenIcon:DisplayObject;
		protected var _turfIcon:DisplayObject;
		protected var _tokenField:TextField;
		protected var _turfField:TextField;
		protected var _statContainer:Sprite;
		protected var _starMeter:StarLevelMeter;
		protected var _levelNumber:CircularLevelNumber;
		protected var _levelField:TextField;
		
		public function StoreAvatarPreviewView()
		{
			super();
		}
		
		override public function init(width:Number, height:Number):void
		{
			super.init(width, height);
			
			// Defaults.
			_animationManager = new AnimationManager();
			
			// Create background.
			_background = new Sprite();
			
			// Avatar layer.
			_avatarLayer = new Sprite();
			
			var stroke:GlowFilter = new GlowFilter(0, 1, 6, 6, 10);
			var textFormat:TextFormat = new TextFormat('EuroStyle', 18, 0xffffff, true);
			
			// Render out some test content.
			_nameField = new TextField();
			_nameField.defaultTextFormat = textFormat;
			_nameField.autoSize = TextFieldAutoSize.LEFT;
			_nameField.embedFonts = true;
			_nameField.selectable = false;
			_nameField.mouseEnabled = false;
			_nameField.filters = [stroke];
			
			_tokenField = new TextField();
			_tokenField.defaultTextFormat = textFormat;
			_tokenField.autoSize = TextFieldAutoSize.LEFT;
			_tokenField.embedFonts = true;
			_tokenField.selectable = false;
			_tokenField.mouseEnabled = false;
			_tokenField.text = '0';
			_tokenField.filters = [stroke];
			
			_turfField = new TextField();
			_turfField.defaultTextFormat = textFormat;
			_turfField.autoSize = TextFieldAutoSize.LEFT;
			_turfField.embedFonts = true;
			_turfField.selectable = false;
			_turfField.mouseEnabled = false;
			_turfField.text = '0';
			_turfField.filters = [stroke];
			
			_statContainer = new Sprite();
			
			var iconSize:int = 36;
			
			_tokenIcon = new ShopToken();
			var iconScale:Number = Math.min(iconSize / _tokenIcon.width, iconSize / _tokenIcon.height);
			_tokenIcon.width *= iconScale;
			_tokenIcon.height *= iconScale;
			
			_turfIcon = new HomeTurfIconGold();
			iconScale = Math.min(iconSize / _turfIcon.width, iconSize / _turfIcon.height);
			_turfIcon.width *= iconScale;
			_turfIcon.height *= iconScale;
			
			_levelNumber = new CircularLevelNumber();
			_levelNumber.width = 30;
			_levelNumber.height = 30;
			_levelNumber.setLevel(1);
			
			_levelField = new TextField();
			_levelField.defaultTextFormat = new TextFormat('EuroStyle', 14, 0xffffff, true);
			_levelField.autoSize = TextFieldAutoSize.LEFT;
			_levelField.embedFonts = true;
			_levelField.selectable = false;
			_levelField.mouseEnabled = false;
			_levelField.text = 'All Star';
			_levelField.filters = [new GlowFilter(0, 1, 4, 4, 10)];
			
			_starMeter = new StarLevelMeter();
			_starMeter.width *= 0.8;
			_starMeter.height *= 0.8;
			_starMeter.setLevel(1);
			
			render();
			
			// Add displays.
			addChild(_background);
			addChild(_avatarLayer);
			addChild(_statContainer);
			addChild(_nameField);
			addChild(_levelNumber);
			addChild(_levelField);
			addChild(_starMeter);
			_statContainer.addChild(_tokenIcon);
			_statContainer.addChild(_turfIcon);
			_statContainer.addChild(_tokenField);
			_statContainer.addChild(_turfField);
		}
		
		////////////////////
		// INSTANCE METHODS
		////////////////////
		
		override public function destroy():void
		{
			// Handle clean up.
			_animationManager.dispose();
			_animationManager = null;
		}
		
		////////////////////
		// RENDER METHODS
		////////////////////
		
		override public function render():void
		{
			super.render();
			
			// Draw backing.
			var gradMatrix:Matrix = new Matrix();
			gradMatrix.createGradientBox(_width, _height, Math.PI / 2);
			graphics.clear();
			graphics.beginGradientFill(GradientType.LINEAR, [0x87bff5, 0x27419e], [1, 1], [1, 255], gradMatrix);
			graphics.lineStyle(1, 0xffffff, 0.5);
			graphics.drawRoundRectComplex(0, 0, 220, 545, 0, 20, 0, 20);
			
			// Size background.
			_background.width = _width;
			_background.height = _height;
			
			// Stat container.
			_statContainer.graphics.clear();
			_statContainer.graphics.beginFill(0xffffff, 0.2);
			_statContainer.graphics.drawRoundRect(0, 0, _width - 40, 100, 20, 20);
			_statContainer.x = 20;
			_statContainer.y = _height - _statContainer.height - 20;
			
			// Level number.
			_levelNumber.x = 7;
			_levelNumber.y = 3;
			
			// Level field.
			_levelField.x = _levelNumber.x + _levelNumber.width + 3;
			_levelField.y = _levelNumber.y + _levelNumber.height / 2 - _levelField.height / 2;
			
			// Star meter.
			_starMeter.x = _width - _starMeter.width - 10;
			_starMeter.y = 10;
			
			renderAvatarImage();
			
			renderName();
			
			renderStats();
		}
		
		protected function renderName():void
		{
			_nameField.x = _width / 2 - _nameField.width / 2;
			_nameField.y  = _statContainer.y + - _nameField.height - 10;
		}
		
		protected function renderAvatarImage():void
		{
			if (_avatarImage == null) return;
			_avatarImage.x = _width / 2 - _avatarImage.width / 2;
			_avatarImage.y = 40;
		}
		
		protected function renderStats():void
		{
			_tokenIcon.x = 10;
			_tokenIcon.y = 10;
			
			_tokenField.x = _tokenIcon.x + _tokenIcon.width + 10;
			_tokenField.y = _tokenIcon.y + _tokenIcon.height / 2 - _tokenField.height / 2;
			
			_turfIcon.x = 10;
			_turfIcon.y = _tokenIcon.y + _tokenIcon.height + 10;
			
			_turfField.x = _turfIcon.x + _turfIcon.width + 10;
			_turfField.y = _turfIcon.y + _turfIcon.height / 2 - _turfField.height / 2;
		}
		
		public function animateTokens(newTokenValue:uint, duration:Number = 4000):void
		{
			var diff:Number = newTokenValue - _userTokens;
			var text:String;
			if (diff > 0)
			{
				text = '+' + diff.toString() + ' TOKENS';
			}
			else if (diff < 0)
			{
				text = '-' + diff.toString() + ' TOKENS';
			}
			else
			{
				// Do nothing.
				return;
			}
			
			// Set new value.
			tokens = newTokenValue;
			
			var textField:TextField = new TextField();
			textField.defaultTextFormat = new TextFormat('EuroStyle', 22, 0xffffff, true);
			textField.autoSize = TextFieldAutoSize.LEFT;
			textField.embedFonts = true;
			textField.text = text;
			textField.filters = [new GlowFilter(0xff0000, 1, 3, 3, 10)];
			textField.x = _width / 2 - textField.width / 2;
			textField.y = 100;
			
			
			// Animate.
			var destY:Number = _avatarLayer.y + 40;
			
			// They could have closed out before this was called.
			if(_animationManager != null)
			{
				addChild(textField);
				_animationManager.addEventListener(AnimationEvent.FINISH, onAnimFinish);
				_animationManager.move(textField, textField.x, destY, duration, Transitions.CUBIC_OUT, RenderMethod.ENTER_FRAME);
				
				function onAnimFinish(e:AnimationEvent):void
				{
					if (e.animTarget == textField)
					{
						// The animation has finished.
						_animationManager.removeEventListener(AnimationEvent.FINISH, onAnimFinish);
						
						// Handle clean up.
						removeChild(textField);
					}
				}
			}
		}
		
		public function animateXp(amount:uint, duration:Number = 4000):void
		{
			// Animate the amount of xp.
			// Have it slide up from the avatar image.
			
			var textField:TextField = new TextField();
			textField.defaultTextFormat = new TextFormat('EuroStyle', 22, 0xffffff, true);
			textField.autoSize = TextFieldAutoSize.LEFT;
			textField.embedFonts = true;
			textField.text = '+' + amount.toString() + ' POINTS';
			textField.alpha = 0;
			textField.filters = [new GlowFilter(0x33689c, 1, 3, 3, 10)];
			textField.x = _width / 2 - textField.width / 2;
			textField.y = _avatarLayer.y + _avatarLayer.height / 2 - textField.height / 2;
			
			
			// Animate the text.
			var destY:Number = _avatarLayer.y + 40;
			// They could have closed out before this was called.
			if(_animationManager != null)
			{
				addChild(textField);
				_animationManager.addEventListener(AnimationEvent.FINISH, onAnimFinish);
				_animationManager.move(textField, textField.x, destY, duration, Transitions.CUBIC_OUT, RenderMethod.ENTER_FRAME);
				_animationManager.alpha(textField, 1, duration / 4, Transitions.CUBIC_OUT, RenderMethod.ENTER_FRAME);
				
				function onAnimFinish(e:AnimationEvent):void
				{
					if (e.animTarget != textField) return;
					if (textField.y == destY)
					{
						// The animation has finished.
						_animationManager.removeEventListener(AnimationEvent.FINISH, onAnimFinish);
						
						// Handle clean up.
						removeChild(textField);
					}
				}
			}
		}
		
		public function animateTokensAndXp(tokenAmount:uint, tokenDuration:Number, xpAmount:uint, xpDuration:Number):void
		{
			// Animate tokens,
			// and when it finsihes,
			// animate xp.
			
			var timer:Timer = new Timer(tokenDuration);
			timer.addEventListener(TimerEvent.TIMER, onTimer);
			animateTokens(tokenAmount, tokenDuration);
			timer.start();
			
			function onTimer(e:TimerEvent):void
			{
				timer.removeEventListener(TimerEvent.TIMER, onTimer);
				timer.reset();
				timer = null;
				
				animateXp(xpAmount, xpDuration);
			}
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		public function set avatarName(value:String):void
		{
			_nameField.text = value;
			renderName();
		}
		
		public function set avatarImage(value:DisplayObject):void
		{
			// Remove the current avatar image.
			if (_avatarImage != null)
			{
				_avatarLayer.removeChild(_avatarImage);
			}
			
			// Set the new one.
			_avatarImage = value;
			_avatarLayer.addChild(_avatarImage);
			
			renderAvatarImage();
			
			renderStats();
		}
		
		public function set avatarImageLoadProgress(value:Number):void
		{
			
		}
		
		public function get tokens():int
		{
			return _userTokens;
		}
		public function set tokens(value:int):void
		{
			if (value == _userTokens) return;
			_userTokens = value;
			_tokenField.text = _userTokens.toString();
			renderStats();
		}
		
		public function set background(value:DisplayObject):void
		{
			if (value == _background) return;
			
			// Remove existing background.
			if (_background != null)
			{
				removeChild(_background);
			}
			
			// Set new one.
			_background = value;
			addChildAt(_background, 0);
			
			render();
		}
		
		public function set level(value:int):void
		{
			_starMeter.setLevel(value);
		}
		
		public function set levelName(value:String):void
		{
			_levelField.text = value;
		}
		
		public function set subLevel(value:int):void
		{
			_levelNumber.setLevel(value);
		}
		
		public function set turfValue(value:int):void
		{
			_turfField.text = value.toString();
		}
		
		////////////////////
		// EVENT HANDLERS
		////////////////////
		
		
	}
}