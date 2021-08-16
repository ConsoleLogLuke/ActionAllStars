package com.sdg.game.keycombo
{
	import com.boostworthy.animation.easing.Transitions;
	import com.boostworthy.animation.management.AnimationManager;
	import com.boostworthy.animation.rendering.RenderMethod;
	
	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.utils.Timer;
	
	internal class KeyComboView extends Sprite implements IKeyComboView
	{
		private var _animMan:AnimationManager;
		private var _intervalWidth:Number;
		private var _keyPointSize:Number;
		private var _barMargin:Number;
		private var _fillMargin:Number;
		private var _valueIcons:Array;
		private var _intervalProgress:Number;
		
		private var _base:Sprite;
		private var _fill:Sprite;
		private var _fillMask:Sprite;
		private var _keyPointOverlay:Sprite;
		private var _icons:Sprite;
		private var _baseKps:Array;
		private var _fillMaskKps:Array;
		private var _overlayKps:Array;
		private var _fillSpace:Number;
		private var _fillVisible:Boolean;
		
		public function KeyComboView(intervalWidth:Number, keyPointSize:Number)
		{
			_animMan = new AnimationManager();
			_intervalWidth = intervalWidth;
			_keyPointSize = keyPointSize;
			_barMargin = 6;
			_fillMargin = 4;
			_intervalProgress = 0;
			_fillSpace = 8;
			_fillVisible = true;
			_valueIcons = [];
			_baseKps = [];
			_fillMaskKps = [];
			_overlayKps = [];
			_base = new Sprite();
			_base.cacheAsBitmap = true;
			_fillMask = new Sprite();
			_fillMask.cacheAsBitmap = true;
			_fill = new Sprite();
			_fill.mask = _fillMask;
			_fill.filters = [new GlowFilter(0xffffff, 1, 2, 2, 100, BitmapFilterQuality.MEDIUM)];
			_keyPointOverlay = new Sprite();
			_icons = new Sprite();
			
			render();
			
			// Prepare to animate in.
			alpha = 0;
			
			// Add displays.
			addChild(_base);
			addChild(_fillMask);
			addChild(_fill);
			addChild(_keyPointOverlay);
			addChild(_icons);
			
			// Animate in.
			_animMan.alpha(this, 1, 300, Transitions.CUBIC_OUT, RenderMethod.TIMER);
		}
		
		////////////////////
		// PUBLIC FUNCTIONS
		////////////////////
		
		public function destroy():void
		{
			// Remove displays.
			removeChild(_base);
			removeChild(_fill);
			removeChild(_fillMask);
			removeChild(_keyPointOverlay);
			removeChild(_icons);
			
			// Clean animation manager.
			_animMan.dispose();
			_animMan = null;
			
			// Remove references.
			_base = null;
			_fill = null;;
			_fillMask = null;
			_keyPointOverlay = null;
			_icons = null;
		}
		
		public function addKeyPoint(slackFactor:Number = 1):void
		{
			var halfKeyPointSize:Number = _keyPointSize / 2;
			var slackSize:Number = _keyPointSize * slackFactor;
			var space:Number = _fillSpace;
			var baseKpGradMatrix:Matrix = new Matrix();
			baseKpGradMatrix.createGradientBox(_keyPointSize, _keyPointSize, Math.PI / 2);
			
			var baseKp:Sprite = new Sprite();
			if (slackSize > _keyPointSize)
			{
				baseKp.graphics.beginFill(0xffffff, 0.5);
				baseKp.graphics.drawCircle(halfKeyPointSize, halfKeyPointSize, slackSize / 2);
				baseKp.graphics.endFill();
			}
			baseKp.graphics.beginGradientFill(GradientType.LINEAR, [0x7f8184, 0x3d3d3d], [1, 1], [0, 255], baseKpGradMatrix);
			baseKp.graphics.drawCircle(halfKeyPointSize, halfKeyPointSize, halfKeyPointSize);
			// Cache as bitmap to improve rendering performance.
			baseKp.cacheAsBitmap = true;
			
			var fillMaskKp:Sprite = new Sprite();
			fillMaskKp.graphics.beginFill(0x00ff00);
			fillMaskKp.graphics.drawCircle(halfKeyPointSize, halfKeyPointSize, halfKeyPointSize - space);
			
			var overlayKp:Sprite = new Sprite();
			var blendFill:Sprite = new Sprite();
			var blendFill2:Sprite = new Sprite();
			var line:Sprite = new Sprite();
			blendFill.graphics.beginFill(0x000000);
			blendFill.graphics.drawCircle(halfKeyPointSize, halfKeyPointSize, halfKeyPointSize);
			blendFill.blendMode = BlendMode.INVERT;
			blendFill2.graphics.beginFill(0xffffff, 0.2);
			blendFill2.graphics.drawCircle(halfKeyPointSize, halfKeyPointSize, halfKeyPointSize);
			blendFill2.blendMode = BlendMode.ADD;
			line.graphics.lineStyle(3, 0);
			line.graphics.drawCircle(halfKeyPointSize, halfKeyPointSize, halfKeyPointSize);
			overlayKp.addChild(blendFill);
			overlayKp.addChild(blendFill2);
			overlayKp.addChild(line);
			
			// Keep references in an array.
			_baseKps.push(baseKp);
			_fillMaskKps.push(fillMaskKp);
			_overlayKps.push(overlayKp);
			
			// Position the key points.
			var len:int = _baseKps.length - 1;
			baseKp.x = _intervalWidth * len;
			fillMaskKp.x = baseKp.x;
			overlayKp.x = baseKp.x;
			
			// Add to display.
			_base.addChild(baseKp);
			_fillMask.addChild(fillMaskKp);
			_keyPointOverlay.addChild(overlayKp);
			
			render();
			
			// Animate in.
			//kP.scaleX = kP.scaleY = 0;
			//_animMan.scale(kP, 1, 1, 300, Transitions.CUBIC_OUT, RenderMethod.TIMER);
		}
		
		public function setNextKeyPointValue(value:String):void
		{
			// Make sure that all key point values have not already been set.
			if (_valueIcons.length > keyPointCount - 1) return;
			
			// Get reference to key point.
			var keyPoint:DisplayObject = _baseKps[_valueIcons.length];
			
			// Create value icon.
			var icon:Sprite = getKeyValueIcon(value);
			icon.x = keyPoint.x + _keyPointSize / 2;
			icon.y = keyPoint.y + _keyPointSize / 2;
						
			_valueIcons.push(icon);
			_icons.addChild(icon);
			
			// Show an effect over the key point.
			var kpEffect:KeyComboBurst = new KeyComboBurst();
			kpEffect.x = icon.x;
			kpEffect.y = icon.y;
			addChild(kpEffect);
			// Use timer to remove effect after period of time.
			// This is to prevent memory leaks.
			var timer:Timer = new Timer(1000);
			timer.addEventListener(TimerEvent.TIMER, onTimer);
			timer.start();
			
			function onTimer(e:TimerEvent):void
			{
				timer.removeEventListener(TimerEvent.TIMER, onTimer);
				timer.reset();
				timer = null;
				// Remove effect.
				removeChild(kpEffect);
				kpEffect = null;
			}
		}
		
		public function setIntervalProgress(value:Number):void
		{
			_intervalProgress = value;
			renderFill(_intervalProgress);
		}
		
		////////////////////
		// PRIVATE FUNCTIONS
		////////////////////
		
		private function render():void
		{
			var len:int = keyPointCount - 1;
			var barW:Number = len * _intervalWidth;
			var barH:Number = _keyPointSize - _barMargin * 2;
			
			// Render base.
			var gradMatrix:Matrix = new Matrix();
			gradMatrix.createGradientBox(len * _intervalWidth, barH, Math.PI / 2);
			_base.graphics.clear();
			_base.graphics.beginGradientFill(GradientType.LINEAR, [0x7f8184, 0x3d3d3d], [1, 1], [0, 255], gradMatrix);
			_base.graphics.drawRect(_keyPointSize / 2, _barMargin, barW, barH);
			
			// Render fill mask.
			var space:Number = _fillSpace;
			_fillMask.graphics.clear();
			_fillMask.graphics.beginFill(0x00ff00);
			_fillMask.graphics.drawRect(_keyPointSize / 2, _barMargin + space, barW, barH - space * 2);
			
			// Render fill.
			renderFill(_intervalProgress);
		}
		
		private function renderFill(intervalFill:Number):void
		{
			if (!_fillVisible)
			{
				_fill.graphics.clear();
				return;
			}
			
			var intervalCount:int = keyPointCount - 1;
			if (intervalCount < 1) return;
			var halfKeyPointSize:Number = _keyPointSize / 2;
			var space:Number = _fillSpace;
			var totalFillPercent:Number = 1 - (1 / intervalCount) + (intervalFill / intervalCount);
			var fillH:Number = _keyPointSize;
			var fillW:Number = (_intervalWidth * intervalCount - space * 2) * totalFillPercent + halfKeyPointSize;
			
			var gradMatrix:Matrix = new Matrix();
			gradMatrix.createGradientBox(fillW, fillH, Math.PI / 2);
			_fill.graphics.clear();
			_fill.graphics.beginGradientFill(GradientType.LINEAR, [0x47d4e1, 0x332ce5], [1, 1], [0, 255], gradMatrix);
			_fill.graphics.drawRect(space, 0, fillW, fillH);
		}
		
		private function getKeyValueIcon(value:String):Sprite
		{
			var icon:Sprite;
			
			switch (value)
			{
				case '37':
					icon = new CircleArrowDark();
					icon.rotation = 180;
					break;
				case '38':
					icon = new CircleArrowDark();
					icon.rotation = 270;
					break;
				case '39':
					icon = new CircleArrowDark();
					break;
				case '40':
					icon = new CircleArrowDark();
					icon.rotation = 90;
					break;
				default:
					icon = new Sprite();
					icon.graphics.beginFill(0);
					icon.graphics.drawCircle(0, 0, 10);
			}
			
			// Skate icon.
			var size:Number = _keyPointSize - _fillSpace * 3;
			var scale:Number = Math.min(size / icon.width, size / icon.height);
			icon.scaleX = scale;
			icon.scaleY = scale;
			
			return icon;
		}
		
		////////////////////
		// GET/SET FUNCTIONS
		////////////////////
		
		override public function get height():Number
		{
			return Math.max(_keyPointSize, _keyPointOverlay.height);
		}
		
		public function get intervalWidth():Number
		{
			return _intervalWidth;
		}
		
		public function get keyPointSize():Number
		{
			return _keyPointSize;
		}
		
		public function get keyPointCount():int
		{
			return _baseKps.length;
		}
		
		public function get fillVisible():Boolean
		{
			return _fillVisible;
		}
		public function set fillVisible(value:Boolean):void
		{
			if (value == _fillVisible) return;
			_fillVisible = value;
			renderFill(_intervalProgress);
		}
		
	}
}