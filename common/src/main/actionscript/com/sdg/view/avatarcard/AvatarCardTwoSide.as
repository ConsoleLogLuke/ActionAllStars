package com.sdg.view.avatarcard
{
	import com.boostworthy.animation.easing.Transitions;
	import com.boostworthy.animation.management.AnimationManager;
	import com.boostworthy.animation.rendering.RenderMethod;
	import com.boostworthy.events.AnimationEvent;
	import com.good.goodui.FluidView;
	import com.sdg.model.Avatar;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;

	public class AvatarCardTwoSide extends FluidView
	{
		protected var _animManager:AnimationManager;
		protected var _front:Sprite;
		protected var _frontCard:AvatarCardFront;
		protected var _back:Sprite;
		protected var _backCard:AvatarCardBack;
		
		protected var _rotation:Number;
		protected var _rotationStep:Number;
		protected var _avatar:Avatar;
		protected var _isInit:Boolean;
		
		public function AvatarCardTwoSide(avatar:Avatar, width:Number, height:Number, autoInit:Boolean = false)
		{
			_animManager = new AnimationManager();
			_rotation = Math.PI / 2;
			_rotationStep = _rotation;
			_avatar = avatar;
			_isInit = false;
			
			_front = new Sprite();
			
			_back = new Sprite();
			
			super(width, height);
			
			if (autoInit == true) init();
		}
		
		////////////////////
		// PUBLIC METHODS
		////////////////////
		
		public function init():void
		{
			// Make sure we only init once.
			if (_isInit == true) return;
			_isInit = true;
			
			var frontComplete:Boolean = false;
			var backComplete:Boolean = false;
			
			_frontCard = new AvatarCardFront(_avatar, width, height);
			_frontCard.addEventListener(Event.COMPLETE, onFrontComplete);
			_frontCard.init();
			_frontCard.x = -_frontCard.width / 2;
			_frontCard.y = -_frontCard.height / 2;
			_front.addChild(_frontCard);
			_front.addEventListener(AvatarCardFront.FLIP_CLICK, onFlipClick);
			
			_backCard = new AvatarCardBack(_avatar, width, height);
			_backCard.addEventListener(Event.COMPLETE, onBackComplete);
			_backCard.init();
			_backCard.x = -_backCard.width / 2;
			_backCard.y = -_backCard.height / 2;
			_back.addChild(_backCard);
			_back.addEventListener(AvatarCardFront.FLIP_CLICK, onFlipClick);
			
			addEventListener(MouseEvent.CLICK, onClick);
			
			addChild(_front);
			addChild(_back);
			
			render();
			
			function onFrontComplete(e:Event):void
			{
				// Remove listener.
				_frontCard.removeEventListener(Event.COMPLETE, onFrontComplete);
				
				// Set flag.
				frontComplete = true;
				
				checkComplete();
			}
			
			function onBackComplete(e:Event):void
			{
				// Remove listener.
				_backCard.removeEventListener(Event.COMPLETE, onBackComplete);
				
				// Set flag.
				backComplete = true;
				
				checkComplete();
			}
			
			function checkComplete():void
			{
				if (frontComplete == true && backComplete == true)
				{
					// Dispatch complete event.
					dispatchEvent(new Event(Event.COMPLETE));
				}
			}
		}
		
		public function destroy():void
		{
			_front.removeEventListener(AvatarCardFront.FLIP_CLICK, onFlipClick);
			_back.removeEventListener(AvatarCardFront.FLIP_CLICK, onFlipClick);
			removeEventListener(MouseEvent.CLICK, onClick);
			
			_frontCard.destroy();
			_backCard.destroy();
		}
		
		public function flipCard():void
		{
			_rotationStep = _rotationStep + Math.PI;
			
			_animManager.property(this, 'sdgRotationY', _rotationStep, 1400, Transitions.BACK_OUT, RenderMethod.ENTER_FRAME);
		}
		
		////////////////////
		// PROTECTED METHODS
		////////////////////
		
		override protected function render():void
		{
			super.render();
			
			// Front transformation.
			var val:Number = Math.sin(_rotation);
			var val2:Number = Math.cos(_rotation);
			
			var matrix:Matrix = _front.transform.matrix;
			matrix.a = val;
			matrix.b = val2 * 0.3;
			//matrix.c = Math.abs(val) * 1;
			_front.transform.matrix = matrix;
			_front.visible = (val >= 0);
			
			// Back transformation.
			
			matrix = _back.transform.matrix;
			matrix.a = -val;
			matrix.b = -val2 * 0.3;
			_back.transform.matrix = matrix;
			_back.visible = (val < 0);
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		public function get sdgRotationY():Number
		{
			return _rotation;
		}
		
		public function set sdgRotationY(value:Number):void
		{
			_rotation = value;
			
			render();
		}
		
		////////////////////
		// EVENT HANDLERS
		////////////////////
		
		private function onFlipClick(e:Event):void
		{
			//flipCard();
		}
		
		private function onClick(e:MouseEvent):void
		{
			flipCard();
		}
		
	}
}