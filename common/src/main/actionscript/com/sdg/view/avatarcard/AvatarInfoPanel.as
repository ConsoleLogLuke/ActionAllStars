package com.sdg.view.avatarcard
{
	import com.boostworthy.animation.easing.Transitions;
	import com.boostworthy.animation.management.AnimationManager;
	import com.boostworthy.animation.rendering.RenderMethod;
	import com.boostworthy.events.AnimationEvent;
	import com.sdg.view.FluidView;
	
	import flash.display.DisplayObject;
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	public class AvatarInfoPanel extends FluidView
	{
		protected static const _StrokeFilter:GlowFilter = new GlowFilter(0x000000, 1, 4, 4, 10);
		
		protected var _marginX:Number;
		protected var _marginY:Number;
		protected var _cornerSize:Number;
		protected var _spaceForControls:Number;
		protected var _back:Sprite;
		protected var _actionBtnField:TextField;
		
		private var _animMan:AnimationManager;
		private var _loadIndicator:TextField;
		private var _avImage:Sprite;
		private var _nameContainer:Sprite;
		private var _statContainer:Sprite;
		private var _nameField:TextField;
		private var _turfIcon:Sprite;
		private var _badgeIcon:Sprite;
		private var _turfField:TextField;
		private var _badgeField:TextField;
		private var _levelNumber:CircularLevelNumber;
		private var _starLevel:StarLevelMeter;
		private var _mvpIcon:Sprite;
		private var _isWaitingForInfo:Boolean;
		private var _isMvp:Boolean;
		private var _avImgMask:Sprite;
		private var _avImgOverlay:Sprite;
		private var _levelNameField:TextField;
		private var _imageCover:Sprite;
		private var _avImgLayer:Sprite;
		private var _teamLogo:DisplayObject;
		
		public function AvatarInfoPanel(width:Number, height:Number)
		{
			super(width, height);
			
			_animMan = new AnimationManager();
			_isWaitingForInfo = true;
			_isMvp = false;
			_marginX = 30;
			_marginY = 20;
			_cornerSize = 18;
			_spaceForControls = 40;
			
			_back = new Sprite();
			
			_loadIndicator = new TextField();
			_loadIndicator.defaultTextFormat = new TextFormat('EuroStyle', 22, 0xffffff, true);
			_loadIndicator.autoSize = TextFieldAutoSize.LEFT;
			_loadIndicator.mouseEnabled = false;
			_loadIndicator.selectable = false;
			_loadIndicator.embedFonts = true;
			_loadIndicator.text = 'Loading...';
			
			_avImage = new Sprite();
			
			_nameContainer = new Sprite();
			
			_statContainer = new Sprite();
			
			_nameField = new TextField();
			_nameField.defaultTextFormat = new TextFormat('EuroStyle', 20, 0xffffff, true);
			_nameField.autoSize = TextFieldAutoSize.LEFT;
			_nameField.mouseEnabled = false;
			_nameField.selectable = false;
			_nameField.embedFonts = true;
			_nameField.text = 'Avatar Name';
			_nameField.filters = [_StrokeFilter];
			
			_turfIcon = new HomeTurfIconGold();
			
			_badgeIcon = new BadgeIconSilver();
			
			_turfField = new TextField();
			_turfField.defaultTextFormat = new TextFormat('EuroStyle', 14, 0xffffff, true);
			_turfField.autoSize = TextFieldAutoSize.LEFT;
			_turfField.mouseEnabled = false;
			_turfField.selectable = false;
			_turfField.embedFonts = true;
			_turfField.text = '0';
			_turfField.filters = [_StrokeFilter];
			
			_badgeField = new TextField();
			_badgeField.defaultTextFormat = new TextFormat('EuroStyle', 14, 0xffffff, true);
			_badgeField.autoSize = TextFieldAutoSize.LEFT;
			_badgeField.mouseEnabled = false;
			_badgeField.selectable = false;
			_badgeField.embedFonts = true;
			_badgeField.text = '0';
			_badgeField.filters = [_StrokeFilter];
			
			_levelNumber = new CircularLevelNumber();
			_levelNumber.setLevel(1);
			
			_starLevel = new StarLevelMeter();
			_starLevel.setLevel(1);
			
			_mvpIcon = new MVPIconGold();
			_mvpIcon.filters = [_StrokeFilter];
			
			_levelNameField = new TextField;
			_levelNameField.defaultTextFormat = new TextFormat('EuroStyle', 14, 0xffffff, true);
			_levelNameField.autoSize = TextFieldAutoSize.LEFT;
			_levelNameField.mouseEnabled = false;
			_levelNameField.selectable = false;
			_levelNameField.embedFonts = true;
			_levelNameField.text = 'Rookie';
			_levelNameField.filters = [_StrokeFilter];
			
			_actionBtnField = new TextField();
			_actionBtnField.defaultTextFormat = new TextFormat('EuroStyle', 14, 0xffffff, true);
			_actionBtnField.autoSize = TextFieldAutoSize.LEFT;
			_actionBtnField.mouseEnabled = false;
			_actionBtnField.selectable = false;
			_actionBtnField.embedFonts = true;
			_actionBtnField.filters = [_StrokeFilter];
			
			_avImgMask = new Sprite();
			
			_avImgLayer = new Sprite();
			_avImgLayer.mask = _avImgMask;
			
			_avImgOverlay = new Sprite();
			
			_imageCover = new Sprite();
			
			addChild(_back);
			addChild(_loadIndicator);
			addChild(_avImgLayer);
			addChild(_avImgMask);
			addChild(_avImgOverlay);
			addChild(_statContainer);
			addChild(_nameContainer);
			addChild(_levelNumber);
			addChild(_starLevel);
			addChild(_mvpIcon);
			addChild(_levelNameField);
			addChild(_actionBtnField);
			_avImgLayer.addChild(_avImage);
			_nameContainer.addChild(_nameField);
			_statContainer.addChild(_turfIcon);
			_statContainer.addChild(_badgeIcon);
			_statContainer.addChild(_turfField);
			_statContainer.addChild(_badgeField);
			
			// Add roll over listeners to turf value & badge icons.
			_turfIcon.addEventListener(MouseEvent.ROLL_OVER, onTurfIconRollOver);
			_badgeIcon.addEventListener(MouseEvent.ROLL_OVER, onBadgeIconRollOver);
			
			render();
		}
		
		////////////////////
		// PUBLIC FUNCTIONS
		////////////////////
		
		public function destroy():void
		{
			// Handle clean up.
			
			_animMan.dispose();
			
			// Remove all children.
			removeChild(_back);
			removeChild(_loadIndicator);
			removeChild(_avImgLayer);
			removeChild(_avImgMask);
			removeChild(_avImgOverlay);
			removeChild(_statContainer);
			removeChild(_nameContainer);
			removeChild(_levelNumber);
			removeChild(_starLevel);
			removeChild(_mvpIcon);
			removeChild(_levelNameField);
			removeChild(_actionBtnField);
			
			// Remove listeners.
			_turfIcon.removeEventListener(MouseEvent.ROLL_OVER, onTurfIconRollOver);
			_badgeIcon.removeEventListener(MouseEvent.ROLL_OVER, onBadgeIconRollOver);
			
			// Remove references.
			_animMan = null;
			_back = null;
			_loadIndicator = null;
			_avImgLayer = null;
			_avImage = null;
			_nameContainer = null;
			_statContainer = null;
			_nameField = null;
			_turfIcon = null;
			_badgeIcon = null;
			_turfField = null;
			_badgeField = null;
			_levelNumber = null;
			_starLevel = null;
			_mvpIcon = null;
			_avImgMask = null;
			_avImgOverlay = null;
			_levelNameField = null;
			_actionBtnField = null;
			_teamLogo = null;
		}
		
		public function setInfo(majorLevel:int, minorLevel:int, levelName:String, image:Sprite, isMvp:Boolean, name:String, turfValue:int, badgeCount:int, teamLogo:DisplayObject = null):void
		{
			// Remove previous avatar image.
			_avImgLayer.removeChild(_avImage);
			
			// Add new avatar image.
			_avImage = image;
			_avImgLayer.addChildAt(_avImage, 0);
			
			// Team logo.
			_teamLogo = teamLogo;
			if (_teamLogo)
			{
				_teamLogo.filters = [new GlowFilter(0xffffff, 1, 2, 2, 10)];
				_avImgLayer.addChild(_teamLogo);
			}
			
			_nameField.text = name;
			_levelNumber.setLevel(minorLevel);
			_starLevel.setLevel(majorLevel);
			_turfField.text = turfValue.toString();
			_badgeField.text = badgeCount.toString();
			_isMvp = isMvp;
			_levelNameField.text = levelName;
			
			_isWaitingForInfo = false;
			
			renderName();
			renderStats();
			renderAvatarImage();
			
			updateVisibility();
		}
		
		public function setImage(image:Sprite):void
		{
			// Remove current avatar image.
			if (_avImage)
			{
				_avImgLayer.removeChild(_avImage);
			}
			
			_avImage = image;
			_avImgLayer.addChildAt(_avImage, 0);
			
			renderAvatarImage();
		}
		
		public function animateIn():void
		{
			// Animate displays.
			var duration:int = 300;
			
			_avImage.alpha = 0;
			_nameContainer.alpha = 0;
			_statContainer.alpha = 0;
			_levelNumber.alpha = 0;
			_starLevel.alpha = 0;
			_mvpIcon.alpha = 0;
			_avImgOverlay.alpha = 0;
			_levelNameField.alpha = 0;
			
			_animMan.alpha(_avImage, 1, duration, Transitions.CUBIC_OUT, RenderMethod.TIMER);
			_animMan.alpha(_nameContainer, 1, duration, Transitions.CUBIC_OUT, RenderMethod.TIMER);
			_animMan.alpha(_statContainer, 1, duration, Transitions.CUBIC_OUT, RenderMethod.TIMER);
			_animMan.alpha(_levelNumber, 1, duration, Transitions.CUBIC_OUT, RenderMethod.TIMER);
			_animMan.alpha(_starLevel, 1, duration, Transitions.CUBIC_OUT, RenderMethod.TIMER);
			if (_isMvp) _animMan.alpha(_mvpIcon, 1, duration, Transitions.CUBIC_OUT, RenderMethod.TIMER);
			_animMan.alpha(_avImgOverlay, 1, duration, Transitions.CUBIC_OUT, RenderMethod.TIMER);
			_animMan.alpha(_levelNameField, 1, duration, Transitions.CUBIC_OUT, RenderMethod.TIMER);
			
			var scaleInFrom:Number = 0.2;
			scaleInDisplay(_avImage, duration, scaleInFrom, scaleInFrom);
			scaleInDisplay(_avImgMask, duration, scaleInFrom, scaleInFrom);
			scaleInDisplay(_nameContainer, duration, scaleInFrom, scaleInFrom);
			scaleInDisplay(_statContainer, duration, scaleInFrom, scaleInFrom);
			scaleInDisplay(_levelNumber, duration, scaleInFrom, scaleInFrom);
			scaleInDisplay(_starLevel, duration, scaleInFrom, scaleInFrom);
			scaleInDisplay(_avImgOverlay, duration, scaleInFrom, scaleInFrom);
			scaleInDisplay(_levelNameField, duration, scaleInFrom, scaleInFrom);
			if (_teamLogo) scaleInDisplay(_teamLogo, duration, scaleInFrom, scaleInFrom);
		}
		
		public function coverImage():void
		{
			var duration:Number = 400;
			_imageCover.x = _avImgMask.x;
			_imageCover.y = _avImgMask.y - _imageCover.height;
			_avImgLayer.addChild(_imageCover);
			_animMan.move(_imageCover, _imageCover.x, _avImgMask.y, duration, Transitions.CUBIC_OUT, RenderMethod.TIMER);
		}
		
		public function unCoverImage():void
		{
			var duration:Number = 400;
			_imageCover.x = _avImgMask.x;
			var newY:Number = _avImgMask.y - _imageCover.height;
			_animMan.addEventListener(AnimationEvent.FINISH, onAnimFinish);
			_animMan.move(_imageCover, _imageCover.x, newY, duration, Transitions.CUBIC_OUT, RenderMethod.TIMER);
			
			function onAnimFinish(e:AnimationEvent):void
			{
				if (e.animTarget == _imageCover && _imageCover.y == newY)
				{
					_animMan.removeEventListener(AnimationEvent.FINISH, onAnimFinish);
					if (_avImgLayer.contains(_imageCover)) _avImgLayer.removeChild(_imageCover);
				}
			}
		}
		
		////////////////////
		// PROTECTED FUNCTIONS
		////////////////////
		
		override protected function render():void
		{
			super.render();
			
			// Draw back.
			renderBacking();
			
			// Position load indicator.
			_loadIndicator.x = _width / 2 - _loadIndicator.width / 2;
			_loadIndicator.y = _height / 2 - _loadIndicator.height / 2;
			
			// Stats.
			renderStats();
			
			// Name.
			renderName();
			
			// Level number.
			_levelNumber.x = _marginX;
			_levelNumber.y = _marginY / 2;
			
			// Star level.
			_starLevel.x = _width - _starLevel.width - _marginX;
			_starLevel.y = _marginY;
			
			// Level name.
			_levelNameField.x = _levelNumber.x + _levelNumber.width + 5;
			_levelNameField.y = _marginY;
			
			// Avatar image.
			renderAvatarImage();
			
			// Set visibility.
			updateVisibility();
		}
		
		protected function renderBacking():void
		{
			// Draw back.
			var gradMatrix:Matrix = new Matrix();
			gradMatrix.createGradientBox(_width, _height, Math.PI / 2);
			_back.graphics.clear();
			_back.graphics.beginGradientFill(GradientType.LINEAR, [0x6890b8, 0x213377], [1, 1], [1, 255], gradMatrix);
			_back.graphics.drawRoundRect(0, 0, _width, _height, _cornerSize, _cornerSize);
		}
		
		protected function renderActionButtonLabel():void
		{
			_actionBtnField.x = _width / 2 - _actionBtnField.width / 2;
			_actionBtnField.y = _statContainer.y + _statContainer.height + 5;
		}
		
		protected function setActionLabel(text:String):void
		{
			_actionBtnField.text = text;
			renderActionButtonLabel();
		}
		
		////////////////////
		// PRIVATE FUNCTIONS
		////////////////////
		
		private function renderName():void
		{
			// Name container.
			_nameContainer.graphics.clear();
			_nameContainer.graphics.beginFill(0xffffff, 0.3);
			_nameContainer.graphics.drawRoundRect(0, 0, _width - _marginX * 2, 30, 16, 16);
			_nameContainer.x = _marginX;
			_nameContainer.y = _statContainer.y - _nameContainer.height - 10;
			
			// Name field.
			_nameField.x = _nameContainer.width / 2 - _nameField.width / 2;
			_nameField.y = _nameContainer.height / 2 - _nameField.height / 2;
		}
		
		private function renderStats():void
		{
			// Stats.
			_statContainer.graphics.clear();
			_statContainer.graphics.beginFill(0xffffff, 0.3);
			_statContainer.graphics.drawRoundRect(0, 0, _width - _marginX * 2, 60, _cornerSize, _cornerSize);
			_statContainer.x = _marginX;
			_statContainer.y = _height - _marginY - _statContainer.height - _spaceForControls;
			
			// Turf icom.
			_turfIcon.x = 10;
			_turfIcon.y = _statContainer.height / 2 - _turfIcon.height / 2;
			
			// Turf field.
			_turfField.x = _turfIcon.x + _turfIcon.width + 10;
			_turfField.y = _statContainer.height / 2 - _turfField.height / 2;
			
			// Badge field.
			_badgeField.x = _statContainer.width - _badgeField.width - 10;
			_badgeField.y = _statContainer.height / 2 - _badgeField.height / 2;
			
			// Badge icon.
			_badgeIcon.x = _badgeField.x - _badgeIcon.width - 10;
			_badgeIcon.y = _statContainer.height / 2 - _badgeIcon.height / 2;
		}
		
		private function renderAvatarImage():void
		{
			var avImgArea:Rectangle = new Rectangle(_marginX, _marginY + _starLevel.height + 2, _width - _marginX * 2, _nameContainer.y - 10 - _marginY - _starLevel.height - 2);
			
			// Draw avatar image mask.
			_avImgMask.graphics.clear();
			_avImgMask.graphics.beginFill(0x00ff00);
			drawImageShape(_avImgMask.graphics);
			_avImgMask.x = avImgArea.x;
			_avImgMask.y = avImgArea.y;
			
			// Scale avatar image.
			var maxScale:Number = Math.max(avImgArea.width / _avImage.width, avImgArea.height / _avImage.height);
			_avImage.width *= maxScale;
			_avImage.height *= maxScale;
			// Position avatar image.
			_avImage.x = avImgArea.x + avImgArea.width / 2 - _avImage.width / 2;
			_avImage.y = avImgArea.y + avImgArea.height / 2 - _avImage.height / 2;
			
			// Draw avatar image overlay.
			_avImgOverlay.graphics.clear();
			_avImgOverlay.graphics.lineStyle(2, 0xffffff, 1, true);
			drawImageShape(_avImgOverlay.graphics);
			_avImgOverlay.x = avImgArea.x;
			_avImgOverlay.y = avImgArea.y;
			
			// Draw avatar cover.
			var gradMatrix:Matrix = new Matrix();
			gradMatrix.createGradientBox(avImgArea.width, avImgArea.height, Math.PI / 2);
			_imageCover.graphics.clear();
			_imageCover.graphics.beginGradientFill(GradientType.LINEAR, [0xa4151f, 0x67070f], [1, 1], [10, 245], gradMatrix);
			drawImageShape(_imageCover.graphics);
			
			// MVP icon.
			_mvpIcon.x = avImgArea.x + 10;
			_mvpIcon.y = avImgArea.bottom - _mvpIcon.height - 10;
			
			// Team logo.
			if (_teamLogo)
			{
				var tmLogoSize:Number = 80;
				var tmLogoScale:Number = Math.min(tmLogoSize / _teamLogo.width, tmLogoSize / _teamLogo.height);
				_teamLogo.width *= tmLogoScale;
				_teamLogo.height *= tmLogoScale;
				
				_teamLogo.x = avImgArea.right - _teamLogo.width - 5;
				_teamLogo.y = avImgArea.bottom - _teamLogo.height - 5;
			}
			
			function drawImageShape(graphics:Graphics):void
			{
				graphics.drawRoundRect(0, 0, avImgArea.width, avImgArea.height, _cornerSize, _cornerSize);
			}
		}
		
		private function updateVisibility():void
		{
			// Set visibility.
			_loadIndicator.visible = _isWaitingForInfo;
			_statContainer.visible = !_isWaitingForInfo;
			_nameContainer.visible = !_isWaitingForInfo;
			_levelNumber.visible = !_isWaitingForInfo;
			_starLevel.visible = !_isWaitingForInfo;
			_avImage.visible = !_isWaitingForInfo;
			_mvpIcon.visible = !_isWaitingForInfo;
			_avImgMask.visible = !_isWaitingForInfo;
			_avImgOverlay.visible = !_isWaitingForInfo;
			_levelNameField.visible = !_isWaitingForInfo;
			_mvpIcon.visible = (!_isWaitingForInfo && _isMvp);
			
			trace('AvatarInfoPanel.updateVisibility()');
			trace('_mvpIcon.visible = ' + _mvpIcon.visible.toString());
		}
		
		private function scaleInDisplay(display:DisplayObject, duration:int, fromScaleX:Number, fromScaleY:Number, transition:String = ''):void
		{
			var x1:Number = display.x;
			var y1:Number = display.y;
			var scaleX1:Number = display.scaleX;
			var scaleY1:Number = display.scaleY;
			var x2:Number = display.x + display.width / 2 - (display.width * fromScaleX) / 2;
			var y2:Number = display.y + display.height / 2 - (display.height * fromScaleY) / 2;
			transition = (transition == '') ? Transitions.CUBIC_OUT : transition;
			display.x = x2;
			display.y = y2;
			display.scaleX = fromScaleX;
			display.scaleY = fromScaleY;
			_animMan.scale(display, scaleX1, scaleY1, duration, transition, RenderMethod.TIMER);
			_animMan.move(display, x1, y1, duration, transition, RenderMethod.TIMER);
		}
		
		private function onTurfIconRollOver(e:MouseEvent):void
		{
			// Listen for roll out.
			_turfIcon.addEventListener(MouseEvent.ROLL_OUT, onRollOut);
			
			// Set action label.
			setActionLabel('Turf Value');
			
			function onRollOut(e:MouseEvent):void
			{
				// Remove listener.
				_turfIcon.removeEventListener(MouseEvent.ROLL_OUT, onRollOut);
				
				// Clear action field.
				_actionBtnField.text = '';
			}
		}
		
		private function onBadgeIconRollOver(e:MouseEvent):void
		{
			// Listen for roll out.
			_badgeIcon.addEventListener(MouseEvent.ROLL_OUT, onRollOut);
			
			// Set action label.
			setActionLabel('Badges');
			
			function onRollOut(e:MouseEvent):void
			{
				// Remove listener.
				_badgeIcon.removeEventListener(MouseEvent.ROLL_OUT, onRollOut);
				
				// Clear action field.
				_actionBtnField.text = '';
			}
		}
		
	}
}