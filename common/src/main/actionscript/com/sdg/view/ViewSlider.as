package com.sdg.view
{
	import com.boostworthy.animation.easing.Transitions;
	import com.boostworthy.animation.management.AnimationManager;
	import com.boostworthy.animation.rendering.RenderMethod;
	import com.boostworthy.events.AnimationEvent;
	import com.good.goodui.FluidView;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;

	public class ViewSlider extends FluidView
	{
		protected var _views:Array;
		protected var _animManager:AnimationManager;
		protected var _selectedIndex:uint;
		protected var _mask:Sprite;
		protected var _viewContainer:Sprite;
		
		public function ViewSlider(width:Number, height:Number, views:Array)
		{
			_selectedIndex = 0;
			_views = views;
			_animManager = new AnimationManager();
			
			_mask = new Sprite();
			
			_viewContainer = new Sprite();
			_viewContainer.mask = _mask;
			
			var defaultView:DisplayObject = _views[0] as DisplayObject;
			if (defaultView) _viewContainer.addChild(defaultView);
			
			super(width, height);
			
			addChild(_mask);
			addChild(_viewContainer);
			
			render();
		}
		
		override protected function render():void
		{
			super.render();
			
			_mask.graphics.clear();
			_mask.graphics.beginFill(0x00ff00);
			_mask.graphics.drawRect(0, 0, _width, _height);
		}
		
		////////////////////
		// PROTECTED METHODS
		////////////////////
		
		protected function swapViews(oldView:DisplayObject, newView:DisplayObject, direction:Boolean):void
		{
			// Position the view that will be selected.
			newView.y = 0;
			newView.x = (!direction) ? _width : -newView.width;
			_viewContainer.addChild(newView);
			
			// Slide the views into position.
			var oldViewX:Number = (!direction) ? -oldView.width : _width;
			_animManager.addEventListener(AnimationEvent.FINISH, onAnimFinish);
			_animManager.addEventListener(AnimationEvent.CHANGE, onAnimChange);
			_animManager.move(oldView, oldViewX, 0, 1000, Transitions.CUBIC_OUT, RenderMethod.ENTER_FRAME);
			_animManager.move(newView, 0, 0, 1000, Transitions.CUBIC_OUT, RenderMethod.ENTER_FRAME);
			
			function onAnimFinish(e:AnimationEvent):void
			{
				if (e.animTarget != oldView) return;
				
				// Remove event listener.
				_animManager.removeEventListener(AnimationEvent.FINISH, onAnimFinish);
				_animManager.removeEventListener(AnimationEvent.CHANGE, onAnimChange);
				
				// Remove old view.
				_viewContainer.removeChild(oldView);
			}
			
			function onAnimChange(e:AnimationEvent):void
			{
				if (e.animTarget != oldView) return;
				
				// Remove event listener.
				_animManager.removeEventListener(AnimationEvent.FINISH, onAnimFinish);
				_animManager.removeEventListener(AnimationEvent.CHANGE, onAnimChange);
			}
		}
		
		////////////////////
		// PUBLIC METHODS
		////////////////////
		
		public function selectViewDirectly(view:DisplayObject):void
		{
			// Get index of view.
			var index:int = _views.indexOf(view);
			if (index < 0) return;
			if (index == _selectedIndex) return;
			
			// Swap views.
			var oldView:DisplayObject = _views[_selectedIndex];
			swapViews(oldView, view, (_selectedIndex > index));
			
			_selectedIndex = index;
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		public function get selectedIndex():uint
		{
			return _selectedIndex;
		}
		public function set selectedIndex(value:uint):void
		{
			if (value == _selectedIndex) return;
			
			// Swap views.
			var newView:DisplayObject = _views[value];
			var oldView:DisplayObject = _views[_selectedIndex];
			if (newView == null || oldView == null) return;
			swapViews(oldView, newView, (_selectedIndex > value));
			
			_selectedIndex = value;
		}
		
	}
}