package com.sdg.view.chat
{
	import com.boostworthy.animation.easing.Transitions;
	import com.boostworthy.animation.management.AnimationManager;
	import com.boostworthy.animation.rendering.RenderMethod;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	public class ChatBubbleAnimated extends ChatBubble
	{
		public static const HIDE_FINISH:String = 'hide finish';
		
		private var _animMan:AnimationManager;
		
		public function ChatBubbleAnimated(text:String, color1:uint, color2:uint, maxWidth:Number=160)
		{
			_animMan = new AnimationManager();
			
			visible = false;
			
			super(text, color1, color2, maxWidth);
		}
		
		////////////////////
		// PUBLIC FUNCTIONS
		////////////////////
		
		public function show():void
		{
			// Calculate duration based on length of text.
			// This is what determines how long the chat bubble will display for.
			var duration:Number = (_text.length / 6) * 1000; // 1 second for every 6 characters.
			var minDuration:Number = 1000;
			duration = Math.max(duration, minDuration);
			var inDur:Number = 200;
			var outDur:Number = 600;
			var outDistance:Number = 80;
			var chatBubble:Sprite = this;
			
			var hideTimer:Timer = new Timer(inDur + duration);
			hideTimer.addEventListener(TimerEvent.TIMER, onHideTimer);
			var killTimer:Timer = new Timer(inDur + duration + outDur + 100);
			killTimer.addEventListener(TimerEvent.TIMER, onKillTimer);
			
			alpha = 0;
			visible = true;
			scaleX = 1.8;
			scaleY = 0.2;
			
			_animMan.scale(chatBubble, 1, 1, inDur, Transitions.BACK_OUT, RenderMethod.TIMER);
			_animMan.alpha(chatBubble, 1, inDur, Transitions.CUBIC_OUT, RenderMethod.TIMER);
			hideTimer.start();
			killTimer.start();
			
			function onHideTimer(e:TimerEvent):void
			{
				// Stop hide timer.
				hideTimer.removeEventListener(TimerEvent.TIMER, onHideTimer);
				hideTimer.reset();
				hideTimer = null;
				
				// Hide chat bubble.
				_animMan.move(chatBubble, chatBubble.x, chatBubble.y - outDistance, outDur, Transitions.CUBIC_IN, RenderMethod.TIMER);
				_animMan.alpha(chatBubble, 0, outDur, Transitions.CUBIC_IN, RenderMethod.TIMER);
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
		
		override public function destroy():void
		{
			_animMan.removeAll();
			_animMan.dispose();
			
			_animMan = null;
			
			super.destroy();
		}
		
	}
}