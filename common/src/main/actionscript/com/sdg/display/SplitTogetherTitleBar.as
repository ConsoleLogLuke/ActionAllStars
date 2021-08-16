package com.sdg.display
{
	import com.boostworthy.animation.easing.Transitions;
	import com.boostworthy.animation.management.AnimationManager;
	import com.boostworthy.animation.rendering.RenderMethod;
	import com.boostworthy.events.AnimationEvent;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.Timer;

	public class SplitTogetherTitleBar extends Sprite
	{	
		private var _color:uint;
		private var _textField:TextField;
		private var _box:Sprite;
		private var _animationManager:AnimationManager;
		private var _margin:Number;
		private var _renderLayer:Sprite;
		
		public function SplitTogetherTitleBar(title:String, textFormat:TextFormat, color:uint, animationManager:AnimationManager, margin:Number = 20)
		{
			super();
			
			_color = color;
			_animationManager = animationManager;
			_margin = margin;
			
			// Create box.
			_box = new Sprite();
			
			// Create textfield.
			_textField = new TextField();
			_textField.defaultTextFormat = textFormat;
			_textField.embedFonts = true;
			_textField.text = title;
			_textField.autoSize = TextFieldAutoSize.LEFT;
			_textField.filters = [new DropShadowFilter(1, 45, 0, 0.8, 2, 2, 1, 1, true)];
			_box.addChild(_textField);
			
			// Create render layer.
			_renderLayer = new Sprite();
			addChild(_renderLayer);
			
			render();
		}
		
		private function render():void
		{
			var w:Number = getWidth();
			var h:Number = getHeight();
			
			_box.graphics.clear();
			_box.graphics.beginFill(_color);
			_box.graphics.drawRoundRect(0, 0, w, h, _margin, _margin);
			_box.graphics.endFill();
			
			var gradMatrix:Matrix = new Matrix();
			gradMatrix.createGradientBox(w, h, Math.PI / 2);
			_box.graphics.beginGradientFill(GradientType.LINEAR, [0xffffff, 0xffffff, 0x000000, 0x000000], [0.6, 0.3, 0, 0.2], [0, 127, 128, 255], gradMatrix);
			_box.graphics.drawRoundRect(0, 0, w, h, _margin, _margin);
			_box.graphics.endFill();
			
			_textField.x = _margin;
			_textField.y = _margin / 2;
		}
		
		private function getWidth():Number
		{
			return _textField.width + _margin * 2;
		}
		
		private function getHeight():Number
		{
			return _textField.height + _margin;
		}
		
		public function animateIn(centerX:Number, centerY:Number, startDistance:Number, animateDuration:Number, stillDuration:Number):void
		{
			// Create bitmap copies of the top and the bottom half.
			
			var w:Number = getWidth();
			var h:Number = getHeight();
			
			var top:Bitmap;
			var bottom:Bitmap;
			
			// Draw top.
			var bitData:BitmapData = new BitmapData(w, Math.ceil(h / 2), true, 0x000000);
			bitData.draw(_box);
			top = new Bitmap(bitData);
			
			// Draw bottom.
			bitData = new BitmapData(w, Math.ceil(h / 2), true, 0x000000);
			bitData.draw(_box, new Matrix(1, 0, 0, 1, 0, -h / 2));
			bottom = new Bitmap(bitData);
			
			// Position top and bottom.
			var startLeftX:Number = centerX - startDistance - w;
			var startRightX:Number = centerX + startDistance;
			top.x = startLeftX;
			top.y = centerY - h / 2;
			bottom.x = startRightX;
			bottom.y = centerY;
			
			// Add to display.
			_renderLayer.addChild(top);
			_renderLayer.addChild(bottom);
			
			// Animate.
			var destX:Number = centerX - w / 2;
			_animationManager.addEventListener(AnimationEvent.FINISH, onAnimationFinish);
			_animationManager.move(top, destX, top.y, animateDuration, Transitions.CUBIC_IN, RenderMethod.TIMER);
			_animationManager.move(bottom, destX, bottom.y, animateDuration, Transitions.CUBIC_IN, RenderMethod.TIMER);
			
			// Create a fallback timer.
			var fallback:Timer = new Timer(animateDuration + 1000);
			fallback.addEventListener(TimerEvent.TIMER, onFallback);
			fallback.start();
			
			function onAnimationFinish(e:AnimationEvent):void
			{
				if (e.animTarget == bottom)
				{
					if (Math.floor(bottom.x) == Math.floor(destX))
					{
						// Animation in is finished.
						
						// Kill fallback timer.
						fallback.removeEventListener(TimerEvent.TIMER, onFallback);
						fallback.reset();
						
						stillPeriod();
					}
					else if (Math.floor(bottom.x) == Math.floor(startLeftX))
					{
						// Animation out is finished.
						
						// Remove the animation manager listener.
						_animationManager.removeEventListener(AnimationEvent.FINISH, onAnimationFinish);
						
						// Remove from display.
						_renderLayer.removeChild(top);
						_renderLayer.removeChild(bottom);
						
						// Dispatch a complete event.
						dispatchEvent(new Event(Event.COMPLETE));
					}
				}
			}
			
			function stillPeriod():void
			{
				// User a timer to hold the title bar where it is momentarily.
				var tmr:Timer = new Timer(stillDuration);
				tmr.addEventListener(TimerEvent.TIMER, onTimer);
				tmr.start();
				
				function onTimer(e:TimerEvent):void
				{
					// Kill timer.
					tmr.removeEventListener(TimerEvent.TIMER, onTimer);
					tmr.reset();
					
					// Animate out the title bar.
					_animationManager.move(top, startRightX, top.y, animateDuration, Transitions.CUBIC_IN, RenderMethod.TIMER);
					_animationManager.move(bottom, startLeftX, bottom.y, animateDuration, Transitions.CUBIC_IN, RenderMethod.TIMER);
				}
			}
			
			function onFallback(e:TimerEvent):void
			{
				// Kill fallback timer.
				fallback.removeEventListener(TimerEvent.TIMER, onFallback);
				fallback.reset();
				
				stillPeriod();
			}
		}
		
	}
}