package com.sdg.view.emote
{
	import com.boostworthy.animation.easing.Transitions;
	import com.boostworthy.animation.management.AnimationManager;
	import com.boostworthy.animation.rendering.RenderMethod;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.utils.Timer;

	public class EmoteAnimated extends Sprite
	{
		public static const HIDE_FINISH:String = 'hide finish';
		
		private var _animMan:AnimationManager;
		private var _display:Sprite;
		
		public function EmoteAnimated(display:Sprite, width:Number, height:Number, duration:int)
		{
			super();
			
			_animMan = new AnimationManager();
			_display = display;
			
			// Scale display.
			var disRect:Rectangle = _display.getRect(_display);
			var scale:Number = Math.min(width / _display.width, height / _display.height);
			_display.width *= scale;
			_display.height *= scale;
			
			// Position display.
			disRect = _display.getRect(_display);
			_display.x = -disRect.width / 2;
			_display.y = -disRect.height;
			
			// Add display to view.
			// Make it invisible at first so we can animate it.
			_display.visible = false;
			addChild(_display);
			
			// Animate show the display.
			var inDur:Number = 200;
			var outDur:Number = 600;
			var outDistance:Number = 80;
			
			var hideTimer:Timer = new Timer(inDur + duration);
			hideTimer.addEventListener(TimerEvent.TIMER, onHideTimer);
			var killTimer:Timer = new Timer(inDur + duration + outDur + 100);
			killTimer.addEventListener(TimerEvent.TIMER, onKillTimer);
			
			_display.alpha = 0;
			_display.scaleX = 1.8;
			_display.scaleY = 0.2;
			_display.visible = true;
			
			_animMan.scale(_display, 1, 1, inDur, Transitions.BACK_OUT, RenderMethod.TIMER);
			_animMan.alpha(_display, 1, inDur, Transitions.CUBIC_OUT, RenderMethod.TIMER);
			hideTimer.start();
			killTimer.start();
			
			function onHideTimer(e:TimerEvent):void
			{
				// Stop hide timer.
				hideTimer.removeEventListener(TimerEvent.TIMER, onHideTimer);
				hideTimer.reset();
				hideTimer = null;
				
				// Hide chat bubble.
				_animMan.move(_display, _display.x, _display.y - outDistance, outDur, Transitions.CUBIC_IN, RenderMethod.TIMER);
				_animMan.alpha(_display, 0, outDur, Transitions.CUBIC_IN, RenderMethod.TIMER);
			}
			
			function onKillTimer(e:TimerEvent):void
			{
				// Stop kill timer.
				killTimer.removeEventListener(TimerEvent.TIMER, onKillTimer);
				killTimer.reset();
				killTimer = null;
				
				// Dispatch hide finish event.
				dispatchEvent(new Event(HIDE_FINISH));
			}
		}
		
		//////////////////////
		// PUBLIC FUNCTIONS
		//////////////////////
		
		public function destroy():void
		{
			// Clean up animation manager.
			_animMan.dispose();
			
			// Remove display.
			removeChild(_display);
			
			// Remove references.
			_animMan = null;
			_display = null;
		}
		
	}
}