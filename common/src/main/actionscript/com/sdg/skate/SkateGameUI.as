package com.sdg.skate
{
	import com.boostworthy.animation.easing.Transitions;
	import com.boostworthy.animation.management.AnimationManager;
	import com.boostworthy.animation.rendering.RenderMethod;
	import com.boostworthy.animation.sequence.Timeline;
	import com.boostworthy.animation.sequence.tweens.Tween;
	import com.boostworthy.events.AnimationEvent;
	import com.sdg.audio.EmbeddedAudio;
	import com.sdg.components.controls.GameConsoleDelegate;
	import com.sdg.game.keycombo.IKeyComboController;
	import com.sdg.game.keycombo.KeyComboController;
	import com.sdg.net.QuickLoader;
	import com.sdg.util.AssetUtil;
	import com.sdg.util.Delay;
	import com.sdg.view.FluidView;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.media.Sound;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.Timer;

	public class SkateGameUI extends FluidView implements ISkateGameUI
	{
		public static const OPEN_TRICK_SHEET:String = 'opentricksheet';
		public static const CLOSE_TRICK_SHEET:String = 'closetricksheet';

		[Embed(source='swfs/skate/tricks_button.swf')]
		private static const TrickSheetButton:Class;

		private static const _SHADOW:DropShadowFilter = new DropShadowFilter(2, 45, 0, 1, 6, 6);
		private static const _ANIM_OUT_DURATION:int = 200;

		private var _animMan:AnimationManager;
		private var _currentMessage:Sprite;
		private var _messageTimer:Timer;
		private var _currentKeyCombo:IKeyComboController;
		private var _lastKeyCombo:IKeyComboController;
		private var _pointField:TextField;
		private var _points:int;
		private var _tricksBtn:Sprite;
		private var _scoreDisplay:Object;
		private var _persistentMessage:String;
		private var _currentMessageText:String;
		private var _placeUI:SkateGamePlaceView;
		private var _timeProgressUI:SkateGameClock;
		private var _trickBtnAnimTimeline:Timeline;
		private var _trickSheetShown:Boolean;
		private var _multiplierDisplay:Object;
		private var _scoreMultiplier:Number;
		private var _localUserGamePlayCount:int;
		private var _trickSheet:Sprite;

		public function SkateGameUI(animationManager:AnimationManager, width:Number = 925, height:Number = 665)
		{
			super(width, height);

			_points = 0;
			_trickSheetShown = false;
			_animMan = animationManager;
			_scoreMultiplier = 1;
			_localUserGamePlayCount = 0;

			_pointField = new TextField();
			_pointField.defaultTextFormat = new TextFormat('EuroStyle', 22, 0xffffff, true);
			_pointField.autoSize = TextFieldAutoSize.LEFT;
			_pointField.selectable = false;
			_pointField.mouseEnabled = false;
			_pointField.embedFonts = true;
			_pointField.text = 'Points: 0';
			_pointField.filters = [_SHADOW];
			_pointField.x = _width / 2 - _pointField.width / 2;
			_pointField.y = 10;

			_tricksBtn = new TrickSheetButton();
			_tricksBtn.buttonMode = true;
			_tricksBtn.addEventListener(MouseEvent.ROLL_OVER, onTricksButtonOver);

			_placeUI = new SkateGamePlaceView(40);

			_timeProgressUI = new SkateGameClock();

			// Load point display asset.
			var scoreDisplayLoader:QuickLoader = new QuickLoader('assets/swfs/skate/point_display.swf', onScoreDisplayComplete, null, 1, 5000);
			// Load multiplier display asset.
			var multiplierDisplayLoader:QuickLoader = new QuickLoader('assets/swfs/skate/skate_multiplier_display.swf', onMultiplierDisplayComplete, null, 1, 5000);
			// Load trick sheet.
			var trickSheetLoader:QuickLoader = new QuickLoader(AssetUtil.GetGameAssetUrl(67, 'trick_sheet.swf'), onTrickSheetComplete, null, 1, 5000);

			render();

			// Add displays.
			addChild(_pointField);
			addChild(_tricksBtn);
			addChild(_placeUI);
			addChild(_timeProgressUI);

			function onScoreDisplayComplete():void
			{
				// Get loaded point display asset.
				_scoreDisplay = scoreDisplayLoader.content;
				scoreDisplayLoader = null;

				// Remove generic text based point display.
				removeChild(_pointField);
				_pointField = null;

				_scoreDisplay.value = _points;
				_scoreDisplay.x = _width / 2 - _scoreDisplay.width / 2;
				_scoreDisplay.y = 5;
				addChild(DisplayObject(_scoreDisplay));

				// May need to reposition message.
				repositionCurrentMessage();
			}

			function onMultiplierDisplayComplete():void
			{
				// Get loaded multiplier display asset.
				_multiplierDisplay = multiplierDisplayLoader.content;
				multiplierDisplayLoader = null;

				// Set visibility.
				DisplayObject(_multiplierDisplay).visible = (_scoreMultiplier > 1) ? true : false;

				// Add to display.
				addChild(DisplayObject(_multiplierDisplay));
			}

			function onTrickSheetComplete():void
			{
				// Keep reference to loaded trick sheet.
				_trickSheet = Sprite(trickSheetLoader.content);
				trickSheetLoader = null;

				// Set game play count.
				Object(_trickSheet).gamesPlayed = _localUserGamePlayCount;
			}
		}

		//////////////////////
		// PUBLIC FUNCTIONS
		//////////////////////

		override protected function render():void
		{
			super.render();

			_tricksBtn.x = _width - _tricksBtn.width - 10;
			_tricksBtn.y = 10;

			_placeUI.x = 5;
			_placeUI.y = 180;

			_timeProgressUI.x = _tricksBtn.x - _timeProgressUI.width - 10;
			_timeProgressUI.y = 14;
		}

		public function destroy():void
		{
			// Remove listeners.
			_tricksBtn.removeEventListener(MouseEvent.ROLL_OVER, onTricksButtonOver);

			// Cleanup.
			_animMan.dispose();
			_placeUI.destroy();
			if (_trickBtnAnimTimeline) _trickBtnAnimTimeline.dispose();

			// Remove references.
			_animMan = null;
			_tricksBtn = null;
			_scoreDisplay = null;
			_placeUI = null;
		}

		public function showMessage(text:String, duration:int):void
		{
			// Config values.
			var mrgnX:Number = 10;
			var mrgnY:Number = 3;
			var animInDistance:Number = 60;
			var animInDuration:int = 400;

			// Make sure ui has not been destroyed, "_animMan" existing implies that.
			if (!_animMan) return;

			// If the current message is the same as the incomming message, don't show the incoming.
			if (text == _currentMessageText) return;

			// Remove previous message.
			if (_currentMessage) removeCurrentMessage();

			// Create new message.
			var maxMsgWidth:Number = 580;
			var field:TextField = new TextField();
			field.defaultTextFormat = new TextFormat('EuroStyle', 22, 0xffffff, true, null, null, null, null, TextFormatAlign.CENTER);
			field.autoSize = TextFieldAutoSize.LEFT;
			field.selectable = false;
			field.mouseEnabled = false;
			field.embedFonts = true;
			field.text = text;
			var multiline:Boolean = (field.width > maxMsgWidth);
			field.multiline = multiline;
			field.wordWrap = multiline;
			field.autoSize = (multiline) ? TextFieldAutoSize.CENTER : TextFieldAutoSize.LEFT;
			field.width = (multiline) ? maxMsgWidth : field.width;
			field.x = mrgnX;
			field.y = mrgnY;
			// Add filters to text to stylize.
			field.filters = [new GlowFilter(0, 1, 4, 4, 100, 1), new DropShadowFilter(2, 45, 0, 1, 0, 0, 1, 1)];
			_currentMessage = new Sprite();
			var msgW:Number = field.width + mrgnX * 2;
			var msgH:Number = field.height + mrgnY * 2;
			var gradMatrix:Matrix = new Matrix();
			gradMatrix.createGradientBox(msgW, msgH, Math.PI / 2);
			_currentMessage.graphics.beginGradientFill(GradientType.LINEAR, [0xff4804, 0xff4804], [0.4, 0.8], [0, 255], gradMatrix);
			_currentMessage.graphics.drawRoundRect(0, 0, msgW, msgH, 16, 16);
			_currentMessage.addChild(field);
			// Make bitmap copy of the message display, to improve rendering performance.
			var bD:BitmapData = new BitmapData(_currentMessage.width, _currentMessage.height, true, 0x00ff00);
			bD.draw(_currentMessage);
			var bitmap:Bitmap = new Bitmap(bD);
			var messageCopy:Sprite = new Sprite();
			messageCopy.addChild(bitmap);
			_currentMessage = messageCopy;
			// Position message and prepare for animation in.
			_currentMessage.x = _width / 2 - _currentMessage.width / 2;
			_currentMessage.y = getPrefferedMessageY();
			_currentMessage.alpha = 0;
			_currentMessage.y += animInDistance;
			// Add message display.
			addChild(_currentMessage);

			_currentMessageText = text;

			// Animate current message.
			_animMan.alpha(_currentMessage, 1, animInDuration, Transitions.CUBIC_OUT, RenderMethod.TIMER);
			_animMan.move(_currentMessage, _currentMessage.x, _currentMessage.y - animInDistance, animInDuration, Transitions.CUBIC_OUT, RenderMethod.TIMER);

			// If the duration is 0, show indefinitely.
			if (duration > 0)
			{
				_messageTimer = new Timer(duration);
				_messageTimer.addEventListener(TimerEvent.TIMER, onMessageTimer);
				_messageTimer.start();
			}
		}

		public function showStylizedMessage(text:String, color:uint = 0xff0000):void
		{
			var msg:TrickNameEffect = new TrickNameEffect();
			msg.color = color;
			msg.value = text;
			msg.x = _width / 2;
			msg.y = _height - msg.height - GameConsoleDelegate.gameConsole.height + 20;
			addChild(msg);

			// Use a timer to remove the message after 5 seconds.
			// THis is to help prevent memory leaks.
			var timer:Timer = new Timer(5000);
			timer.addEventListener(TimerEvent.TIMER, onTimer);
			timer.start();

			function onTimer(e:TimerEvent):void
			{
				timer.removeEventListener(TimerEvent.TIMER, onTimer);
				timer.reset();
				timer = null;

				removeChild(msg);
				msg = null;
			}
		}

		public function setPersistentMessage(text:String, showNow:Boolean = true):void
		{
			if (text == _persistentMessage) return;
			_persistentMessage = text;
			if (showNow) showMessage(_persistentMessage, 0);
		}

		public function removePersistentMessage():void
		{
			if (_currentMessageText == _persistentMessage) removeCurrentMessage();
			_persistentMessage = null;
		}

		public function startNewKeyCombo(initialValue:String, intervalDuration:int = 1000, maxIntervals:int = 4, triggerDuration:int = 200, intervalWidth:Number = 100):void
		{
			// Start a new key combo.
			var scoreDisplayRect:Rectangle = (_pointField) ? _pointField.getRect(this) : DisplayObject(_scoreDisplay).getRect(this);

			_currentKeyCombo = new KeyComboController(initialValue, intervalDuration, maxIntervals, triggerDuration, intervalWidth);
			_currentKeyCombo.x = _width / 2 - _currentKeyCombo.width / 2;
			_currentKeyCombo.y = scoreDisplayRect.y + scoreDisplayRect.height + 5;
			addChild(DisplayObject(_currentKeyCombo));
			_currentKeyCombo.addEventListener(KeyComboController.NEW_INTERVAL, onNewKeyInterval);
			_currentKeyCombo.start(initialValue);

			// We may have to reposition current message.
			repositionCurrentMessage();
		}

		public function attemptToSetNextValue(value:String):void
		{
			_currentKeyCombo.attemptToSetNextValue(value);
		}

		public function stopCurrentKeyCombo(leaveUpDelay:int):void
		{
			if (!_currentKeyCombo) return;

			var keyComboController:IKeyComboController = _currentKeyCombo;
			var keyComboDisplay:DisplayObject = DisplayObject(keyComboController);
			keyComboController.removeEventListener(KeyComboController.NEW_INTERVAL, onNewKeyInterval);
			keyComboController.stop();
			// Reposition key combo.
			repositionKeyComboUi();
			_lastKeyCombo = _currentKeyCombo;
			_currentKeyCombo = null;

			// Make sure the UI has not been destroyed.
			// We can assume that if animation manager is null.
			if (!_animMan) return;

			// Remove current key combo controller after a set amount of time.
			var timer:Timer = new Timer(leaveUpDelay);
			timer.addEventListener(TimerEvent.TIMER, onTimer);
			timer.start();

			function onTimer(e:TimerEvent):void
			{
				timer.removeEventListener(TimerEvent.TIMER, onTimer);
				timer.reset();
				timer = null;

				_lastKeyCombo = null;

				// Make sure the UI has not been destroyed.
				// We can assume that if animation manager is null.
				if (!_animMan) return;

				// Animate out last key combo UI.
				_animMan.addEventListener(AnimationEvent.FINISH, onAnimFinish);
				_animMan.alpha(keyComboDisplay, 0, _ANIM_OUT_DURATION, Transitions.CUBIC_OUT, RenderMethod.TIMER);

				// We may have to reposition current message.
				repositionCurrentMessage();
			}

			function onAnimFinish(e:AnimationEvent):void
			{
				// Make sure key combo controller is finished animating out.
				if (e.animTarget == keyComboController && keyComboDisplay.alpha == 0)
				{
					// Remove key combo for good.
					removeChild(keyComboDisplay);
				}
			}
		}

		public function addAvatar(avatarId:int, score:int, color:uint):void
		{
			_placeUI.addItem(avatarId, score, color);
		}

		public function removeAvatar(avatarId:int):void
		{
			_placeUI.removeItem(avatarId);
		}

		public function setAvatarScore(avatarId:int, score:int):void
		{
			_placeUI.setScore(avatarId, score);
		}

		public function getLeadingScoreAvatarId():int
		{
			return _placeUI.getLeaderId();
		}

		public function highlightTrickSheet(highlight:Boolean):void
		{
			// Setup an animation sequence for the trick sheet button.
			if (!_trickBtnAnimTimeline)
			{
				var scale:Number = 1.2
				var scaledW:Number = _tricksBtn.width * scale;
				var scaledH:Number = _tricksBtn.height * scale;
				_trickBtnAnimTimeline = new Timeline(RenderMethod.TIMER);
				_trickBtnAnimTimeline.loop = true;
				_trickBtnAnimTimeline.addTween(new Tween(_tricksBtn, 'scaleX', scale, 1, 15, Transitions.CUBIC_IN));
				_trickBtnAnimTimeline.addTween(new Tween(_tricksBtn, 'scaleY', scale, 1, 15, Transitions.CUBIC_IN));
				_trickBtnAnimTimeline.addTween(new Tween(_tricksBtn, 'x', _tricksBtn.x - (scaledW - _tricksBtn.width) / 2, 1, 15, Transitions.CUBIC_IN));
				_trickBtnAnimTimeline.addTween(new Tween(_tricksBtn, 'y', _tricksBtn.y - (scaledH - _tricksBtn.height) / 2, 1, 15, Transitions.CUBIC_IN));
				_trickBtnAnimTimeline.addTween(new Tween(_tricksBtn, 'scaleX', 1, 16, 30, Transitions.CUBIC_OUT));
				_trickBtnAnimTimeline.addTween(new Tween(_tricksBtn, 'scaleY', 1, 16, 30, Transitions.CUBIC_OUT));
				_trickBtnAnimTimeline.addTween(new Tween(_tricksBtn, 'x', _tricksBtn.x, 16, 30, Transitions.CUBIC_OUT));
				_trickBtnAnimTimeline.addTween(new Tween(_tricksBtn, 'y', _tricksBtn.y, 16, 30, Transitions.CUBIC_OUT));
			}

			if (highlight)
			{
				_trickBtnAnimTimeline.play();
			}
			else
			{
				_trickBtnAnimTimeline.gotoAndStop(1);
			}

		}

		public function showWinEffect():void
		{
			// Load a swf that tells the user they won.
			var winEffect:DisplayObject;
			var winEffectLoader:QuickLoader = new QuickLoader(AssetUtil.GetGameAssetUrl(67, 'you_win_effect.swf'), onComplete);

			function onComplete():void
			{
				// The SWF has been loaded.
				// Show it.
				winEffect = winEffectLoader.content;
				winEffectLoader = null;
				winEffect.x = _width / 2;
				winEffect.y = _height / 2;
				addChild(winEffect);
				// Remove after 4 seconds.
				Delay.CallFunctionAfterDelay(4000, removeEffect);
			}

			function removeEffect():void
			{
				removeChild(winEffect);
				winEffect = null;
			}
		}

		//////////////////////
		// PRIVATE FUNCTIONS
		//////////////////////

		private function repositionKeyComboUi():void
		{
			if (!_currentKeyCombo || !_animMan) return;
			var newX:Number = _width / 2 - _currentKeyCombo.width / 2;
			_animMan.move(DisplayObject(_currentKeyCombo), newX, _currentKeyCombo.y, 500, Transitions.CUBIC_OUT, RenderMethod.TIMER);
		}

		private function removeCurrentMessage():void
		{
			if (!_currentMessage) return;

			_currentMessageText = null;

			if (_messageTimer)
			{
				_messageTimer.removeEventListener(TimerEvent.TIMER, onMessageTimer);
				_messageTimer.reset();
				_messageTimer = null;
			}

			// Make sure the UI has not been destroyed.
			// We can assume that if animation manager is null.
			if (!_animMan) return;

			// Animate out the old message.
			var oldMessage:Sprite = _currentMessage;
			_currentMessage = null;
			_animMan.addEventListener(AnimationEvent.FINISH, onAnimFinish);
			_animMan.alpha(oldMessage, 0, _ANIM_OUT_DURATION, Transitions.CUBIC_OUT, RenderMethod.TIMER);

			function onAnimFinish(e:AnimationEvent):void
			{
				// Make sure the old message has finished animation out.
				if (e.animTarget == oldMessage && oldMessage.alpha == 0)
				{
					// Remove old message.
					_animMan.removeEventListener(AnimationEvent.FINISH, onAnimFinish);
					removeChild(oldMessage);
				}
			}
		}

		private function showTrickSheet():void
		{
			// Make sure the trick sheet is not already shown.
			if (_trickSheetShown) return;
			// Make sure the trick sheet has been loaded.
			if (!_trickSheet) return;

			// Position and prepare for animating in.
			_trickSheet.x = _width;
			_trickSheet.y = _tricksBtn.y + _tricksBtn.height + 10;
			// Set game play count.
			Object(_trickSheet).gamesPlayed = _localUserGamePlayCount;

			// Listen for mouse down so we can remove the trick sheet.
			_tricksBtn.addEventListener(MouseEvent.CLICK, onClick);

			// Play open sound.
			Sound(new EmbeddedAudio.OpenSound()).play();

			// Set flag.
			_trickSheetShown = true;

			// Animate in trick sheet.
			addChild(_trickSheet);
			var duration:int = 300;
			_animMan.move(_trickSheet, _width - _trickSheet.width, _trickSheet.y, duration, Transitions.ELASTIC_OUT, RenderMethod.TIMER);

			dispatchEvent(new Event(OPEN_TRICK_SHEET));

			function onClick(e:MouseEvent):void
			{
				// Remove listener.
				_tricksBtn.removeEventListener(MouseEvent.CLICK, onClick);

				// Animate out trick sheet.
				_animMan.addEventListener(AnimationEvent.FINISH, onAnimFinish);
				_animMan.move(_trickSheet, _width, _trickSheet.y, duration, Transitions.EXPO_IN, RenderMethod.TIMER);

				// Dispatch event.
				dispatchEvent(new Event(CLOSE_TRICK_SHEET));
			}

			function onAnimFinish(e:AnimationEvent):void
			{
				if (e.animTarget == _trickSheet && _trickSheet.x == _width)
				{
					_animMan.removeEventListener(AnimationEvent.FINISH, onAnimFinish);
					// Remove trick sheet.
					removeChild(_trickSheet);
					_trickSheetShown = false;
				}
			}
		}

		private function getPrefferedMessageY():Number
		{
			// Check if there is a key combo UI.
			// Position the message relative to the key combo UI.
			var keyComboUI:IKeyComboController = (_lastKeyCombo);
			if (_currentKeyCombo) keyComboUI = _currentKeyCombo;
			var scoreDisplay:DisplayObject = DisplayObject(_scoreDisplay);
			return (keyComboUI) ? keyComboUI.y + keyComboUI.height + 5 : (scoreDisplay) ? scoreDisplay.y + scoreDisplay.height + 5 : 5;
		}

		private function repositionCurrentMessage():void
		{
			if (!_currentMessage) return;
			_animMan.move(_currentMessage, _currentMessage.x, getPrefferedMessageY(), 300, Transitions.CUBIC_OUT, RenderMethod.TIMER);
		}

		//////////////////////
		// GET/SET FUNCTIONS
		//////////////////////

		public function get points():int
		{
			return _points;
		}
		public function set points(value:int):void
		{
			if (value == _points) return;
			_points = value;

			// Animate displayed points.
			_animMan.property(this, 'displayedPoints', _points, 1000, Transitions.CUBIC_OUT, RenderMethod.TIMER);
		}

		public function get displayedPoints():int
		{
			return (_pointField) ? int(_pointField.text) : _scoreDisplay.value;
		}
		public function set displayedPoints(value:int):void
		{
			// Update point display.
			// Either the generic text based score display or the asset based display.
			if (_pointField)
			{
				// Generic text based display.
				_pointField.text = 'Points: ' + value;
				_pointField.x = _width / 2 - _pointField.width / 2;
			}
			else
			{
				// Asset based score display.
				_scoreDisplay.value = value;
				_scoreDisplay.x = _width / 2 - _scoreDisplay.width / 2;
			}

			if (_multiplierDisplay) _multiplierDisplay.x = scoreDisplay.x - _multiplierDisplay.width - 10;
		}

		public function get timeProgressValue():Number
		{
			return _timeProgressUI.value;
		}
		public function set timeProgressValue(value:Number):void
		{
			_timeProgressUI.value = value;
		}

		public function get scoreMultiplier():Number
		{
			return _scoreMultiplier;
		}
		public function set scoreMultiplier(value:Number):void
		{
			if (value == _scoreMultiplier) return;
			_scoreMultiplier = value;
			if (_multiplierDisplay)
			{
				_multiplierDisplay.value = _scoreMultiplier;
				_multiplierDisplay.color = (_scoreMultiplier <= 2) ? 0x00d241 : 0xff4788;
				var scoreDis:DisplayObject = scoreDisplay;
				_multiplierDisplay.x = scoreDis.x - _multiplierDisplay.width - 10;
				_multiplierDisplay.y = scoreDis.y;
				// Set visibility.
				DisplayObject(_multiplierDisplay).visible = (_scoreMultiplier > 1) ? true : false;
			}
		}

		private function get scoreDisplay():DisplayObject
		{
			return (_scoreDisplay) ? DisplayObject(_scoreDisplay) : _pointField;
		}

		public function get localUserGamePlayCount():int
		{
			return _localUserGamePlayCount;
		}
		public function set localUserGamePlayCount(value:int):void
		{
			_localUserGamePlayCount = value;
		}

		public function get numAvatars():int
		{
			return _placeUI.length;
		}

		public function get timeDisplayVisible():Boolean
		{
			return _timeProgressUI.visible;
		}
		public function set timeDisplayVisible(value:Boolean):void
		{
			_timeProgressUI.visible = value;
		}

		public function get trickButtonVisible():Boolean
		{
			return _tricksBtn.visible;
		}
		public function set trickButtonVisible(value:Boolean):void
		{
			_tricksBtn.visible = value;
		}

		//////////////////////
		// EVENT HANDLERS
		//////////////////////

		private function onMessageTimer(e:TimerEvent):void
		{
			// Remove current message.
			removeCurrentMessage();

			// If there is a persistent message set, show it.
			if (_persistentMessage) showMessage(_persistentMessage, 0);
		}

		private function onNewKeyInterval(e:Event):void
		{
			// Repositions key combo ui.
			repositionKeyComboUi();
		}

		private function onTricksButtonOver(e:MouseEvent):void
		{
			_tricksBtn.filters = [new GlowFilter(0xffffff, 1, 10, 10)];

			_tricksBtn.addEventListener(MouseEvent.ROLL_OUT, onRollOut);
			_tricksBtn.addEventListener(MouseEvent.CLICK, onClick);

			// Play over sound.
			Sound(new EmbeddedAudio.OverSound()).play();

			function onRollOut(e:MouseEvent):void
			{
				clean();
			}

			function onClick(e:MouseEvent):void
			{
				showTrickSheet();
			}

			function clean():void
			{
				if (!_tricksBtn) return;
				_tricksBtn.removeEventListener(MouseEvent.ROLL_OUT, onRollOut);
				_tricksBtn.removeEventListener(MouseEvent.CLICK, onClick);

				_tricksBtn.filters = [];
			}
		}

	}
}
