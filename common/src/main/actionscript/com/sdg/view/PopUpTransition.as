package com.sdg.view
{
	import com.boostworthy.animation.easing.Transitions;
	import com.boostworthy.animation.management.AnimationManager;
	import com.boostworthy.animation.rendering.RenderMethod;
	import com.boostworthy.events.AnimationEvent;
	
	import flash.display.DisplayObject;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	public class PopUpTransition extends Object
	{
		public static const SHRINK_TO_CENTER:String = 'shrink to center';
		public static const GROW_FROM_CENTER:String = 'grow from center';
		public static const FADE_IN:String = 'fade in';
		public static const FADE_OUT:String = 'fade out';
		public static const SHRINK_TO_UPPER_CENTER:String = 'shrink to upper center';
		public static const GROW_FROM_UPPER_CENTER:String = 'grow from upper center';
		
		private static var _animManager:AnimationManager;
		private static var _popUpTransitionHandlers:Array;
		private static var _isInit:Boolean = false;
		private static var _initFunct:Function = init;
		
		public static function DoPopUpTransition(popUp:DisplayObject, transition:String, params:Object = null, onComplete:Function = null):void
		{
			// Make sure we have initialized.
			_initFunct();
			
			//
			// PARAMS
			//
			// Params is an abstract object. You can pass in
			// any value through the params object. Look at specific
			// transition handlers to determine how the params will
			// be used. An example is duration which would define the
			// duration of the transition animation in milliseconds.
			// (params.duration = 2000) would equal a 2 second duration.
			
			// Verify values and create defaults if necesary.
			onComplete = (onComplete != null) ? onComplete : new Function();
			params = (params != null) ? params : new Object();
			
			// Determine handler.
			var handler:Function = _popUpTransitionHandlers[transition] as Function;
			
			// Execute handler.
			if (handler != null) handler(popUp, params, onComplete);
		}
		
		private static function init():void
		{
			// Make sure we only init once.
			_initFunct = postInit;
			
			_animManager = new AnimationManager();
			
			// Setup pop up transition handlers.
			_popUpTransitionHandlers = [];
			_popUpTransitionHandlers[''] = defaultTransition;
			_popUpTransitionHandlers[PopUpTransition.SHRINK_TO_CENTER] = shrinkToCenter;
			_popUpTransitionHandlers[PopUpTransition.GROW_FROM_CENTER] = growFromCenter;
			_popUpTransitionHandlers[PopUpTransition.FADE_IN] = fadeIn;
			_popUpTransitionHandlers[PopUpTransition.FADE_OUT] = fadeOut;
			_popUpTransitionHandlers[PopUpTransition.SHRINK_TO_UPPER_CENTER] = shrinkToUpperCenter;
			_popUpTransitionHandlers[PopUpTransition.GROW_FROM_UPPER_CENTER] = growFromUpperCenter;
		}
		
		private static function postInit():void
		{
			return;
		}
		
		private static function createKillTimer(duration:uint, onKill:Function):Timer
		{
			var timer:Timer = new Timer(duration);
			timer.addEventListener(TimerEvent.TIMER, onTimer);
			timer.start();
			
			return timer;
			
			function onTimer(e:TimerEvent):void
			{
				timer.removeEventListener(TimerEvent.TIMER, onTimer);
				onKill();
			}
		}
		
		private static function defaultTransition(popUp:DisplayObject, params:Object, onComplete:Function):void
		{
			// Handle complete.
			onComplete();
		}
		
		private static function shrinkToCenter(popUp:DisplayObject, params:Object, onComplete:Function):void
		{
			var duration:uint = (params.duration != null) ? params.duration : 800;
			
			_animManager.addEventListener(AnimationEvent.FINISH, onAnimFinish);
			_animManager.scale(popUp, 0.001, 0.001, duration, Transitions.CUBIC_OUT, RenderMethod.ENTER_FRAME);
			_animManager.move(popUp, popUp.x + popUp.width / 2, popUp.y + popUp.height / 2, duration, Transitions.CUBIC_OUT, RenderMethod.ENTER_FRAME);
			var killTimer:Timer = createKillTimer(duration * 1.25, finish);
			
			function onAnimFinish(e:AnimationEvent):void
			{
				if (e.animTarget == popUp)
				{
					finish();
				}
			}
			
			function finish():void
			{
				killTimer.reset();
				
				// Remove listener.
				_animManager.removeEventListener(AnimationEvent.FINISH, onAnimFinish);
				
				// Handle complete.
				onComplete();
			}
		}
		
		private static function growFromCenter(popUp:DisplayObject, params:Object, onComplete:Function):void
		{
			var duration:uint = (params.duration != null) ? params.duration : 800;
			
			_animManager.addEventListener(AnimationEvent.FINISH, onAnimFinish);
			var iX:Number = popUp.x;
			var iY:Number = popUp.y;
			popUp.x = popUp.x + popUp.width / 2;
			popUp.y = popUp.y + popUp.height / 2;
			popUp.scaleX = 0;
			popUp.scaleY = 0;
			_animManager.scale(popUp, 1, 1, duration, Transitions.CUBIC_OUT, RenderMethod.ENTER_FRAME);
			_animManager.move(popUp, iX, iY, duration, Transitions.CUBIC_OUT, RenderMethod.ENTER_FRAME);
			var killTimer:Timer = createKillTimer(duration * 1.25, finish);
			
			function onAnimFinish(e:AnimationEvent):void
			{
				if (e.animTarget == popUp)
				{
					finish();
				}
			}
			
			function finish():void
			{
				killTimer.reset();
				
				// Remove listener.
				_animManager.removeEventListener(AnimationEvent.FINISH, onAnimFinish);
				
				// Handle complete.
				onComplete();
			}
		}
		
		private static function fadeIn(popUp:DisplayObject, params:Object, onComplete:Function):void
		{
			var duration:uint = (params.duration != null) ? params.duration : 1000;
			
			_animManager.addEventListener(AnimationEvent.FINISH, onAnimFinish);
			popUp.alpha = 0;
			_animManager.alpha(popUp, 1, duration, Transitions.CUBIC_OUT, RenderMethod.ENTER_FRAME);
			var killTimer:Timer = createKillTimer(duration * 1.25, finish);
			
			function onAnimFinish(e:AnimationEvent):void
			{
				if (e.animTarget == popUp)
				{
					finish();
				}
			}
			
			function finish():void
			{
				killTimer.reset();
				
				// Remove listener.
				_animManager.removeEventListener(AnimationEvent.FINISH, onAnimFinish);
				
				// Handle complete.
				onComplete();
			}
		}
		
		private static function fadeOut(popUp:DisplayObject, params:Object, onComplete:Function):void
		{
			var duration:uint = (params.duration != null) ? params.duration : 1000;
			
			_animManager.addEventListener(AnimationEvent.FINISH, onAnimFinish);
			_animManager.alpha(popUp, 0, duration, Transitions.CUBIC_OUT, RenderMethod.ENTER_FRAME);
			var killTimer:Timer = createKillTimer(duration * 1.25, finish);
			
			function onAnimFinish(e:AnimationEvent):void
			{
				if (e.animTarget == popUp)
				{
					finish();
				}
			}
			
			function finish():void
			{
				killTimer.reset();
				
				// Remove listener.
				_animManager.removeEventListener(AnimationEvent.FINISH, onAnimFinish);
				
				// Handle complete.
				onComplete();
			}
		}
		
		private static function shrinkToUpperCenter(popUp:DisplayObject, params:Object, onComplete:Function):void
		{
			var duration:uint = (params.duration != null) ? params.duration : 800;
			
			_animManager.addEventListener(AnimationEvent.FINISH, onAnimFinish);
			_animManager.scale(popUp, 0.001, 0.001, duration, Transitions.CUBIC_OUT, RenderMethod.ENTER_FRAME);
			_animManager.move(popUp, popUp.x + popUp.width / 2, popUp.y + popUp.height / 2 - 100, duration, Transitions.CUBIC_OUT, RenderMethod.ENTER_FRAME);
			var killTimer:Timer = createKillTimer(duration * 1.25, finish);
			
			function onAnimFinish(e:AnimationEvent):void
			{
				if (e.animTarget == popUp)
				{
					finish();
				}
			}
			
			function finish():void
			{
				killTimer.reset();
				
				// Remove listener.
				_animManager.removeEventListener(AnimationEvent.FINISH, onAnimFinish);
				
				// Handle complete.
				onComplete();
			}
		}
		
		private static function growFromUpperCenter(popUp:DisplayObject, params:Object, onComplete:Function):void
		{
			var duration:uint = (params.duration != null) ? params.duration : 800;
			
			_animManager.addEventListener(AnimationEvent.FINISH, onAnimFinish);
			var iX:Number = popUp.x;
			var iY:Number = popUp.y;
			popUp.x = popUp.x + popUp.width / 2;
			popUp.y = popUp.y + popUp.height / 2 - 100;
			popUp.scaleX = 0;
			popUp.scaleY = 0;
			_animManager.scale(popUp, 1, 1, duration, Transitions.CUBIC_OUT, RenderMethod.ENTER_FRAME);
			_animManager.move(popUp, iX, iY, duration, Transitions.CUBIC_OUT, RenderMethod.ENTER_FRAME);
			var killTimer:Timer = createKillTimer(duration * 1.25, finish);
			
			function onAnimFinish(e:AnimationEvent):void
			{
				if (e.animTarget == popUp)
				{
					finish();
				}
			}
			
			function finish():void
			{
				killTimer.reset();
				
				// Remove listener.
				_animManager.removeEventListener(AnimationEvent.FINISH, onAnimFinish);
				
				// Handle complete.
				onComplete();
			}
		}
		
	}
}