package com.sdg.view.list
{
	import com.boostworthy.animation.easing.Transitions;
	import com.boostworthy.animation.management.AnimationManager;
	import com.boostworthy.animation.rendering.RenderMethod;
	import com.boostworthy.events.AnimationEvent;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	public class CircleListViewWithPages extends CircleListView
	{
		private var _animMan:AnimationManager;
		private var _itemsPerPage:int;
		private var _itemIndex:int;
		private var _leftBtn:DisplayObject;
		private var _rightBtn:DisplayObject;
		private var _queStart:int;
		private var _queEnd:int;
		private var _orginOffset:Number;
		private var _showButtonDuration:int;
		private var _hideButtonDuration:int;
		private var _animateOrginDuration:int;
		private var _paginationIncrement:int;
		private var _maxItemIndex:int;
		private var _back:Sprite;
		
		public function CircleListViewWithPages(radius:Number, itemsPerPage:int, leftButton:DisplayObject, rightButton:DisplayObject)
		{
			_animMan = new AnimationManager();
			
			_itemsPerPage = itemsPerPage;
			_itemIndex = 0;
			_leftBtn = leftButton;
			_rightBtn = rightButton;
			_queStart = _itemIndex - 1;
			_queEnd = _itemIndex + _itemsPerPage;
			_orginOffset = 0;
			_showButtonDuration = 200;
			_hideButtonDuration = 100;
			_animateOrginDuration = 200;
			_paginationIncrement = _itemsPerPage;
			_maxItemIndex = 0;
			_back = new Sprite();
			
			// Setup paging buttons.
			_leftBtn.visible = false;
			_rightBtn.visible = false;
			
			super(radius);
			
			// Add interaction listeners.
			_leftBtn.addEventListener(MouseEvent.MOUSE_DOWN, onLeftMouseDown);
			_rightBtn.addEventListener(MouseEvent.MOUSE_DOWN, onRightMouseDown);
			
			addChild(_back);
			addChild(_leftBtn);
			addChild(_rightBtn);
		}
		
		////////////////////
		// PUBLIC FUNCTIONS
		////////////////////
		
		override public function destroy():void
		{
			// Clean animation manager.
			_animMan.removeAll();
			_animMan.dispose();
			_animMan = null;
			
			// Remove interaction listeners.
			_leftBtn.removeEventListener(MouseEvent.MOUSE_DOWN, onLeftMouseDown);
			_rightBtn.removeEventListener(MouseEvent.MOUSE_DOWN, onRightMouseDown);
			
			// Remove back sprite.
			removeChild(_back);
			_back = null;
			
			super.destroy();
		}
		
		override public function addItem(item:DisplayObject):void
		{
			super.addItem(item);
			
			updateQue();
		}
		
		override public function removeItem(item:DisplayObject):void
		{
			super.removeItem(item);
			
			updateQue();
		}
		
		override public function removeItemAt(index:int):void
		{
			super.removeItemAt(index);
			
			updateQue();
		}
		
		////////////////////
		// PROTECTED FUNCTIONS
		////////////////////
		
		override protected function render():void
		{
			super.render();
			
			// Render left and right paging butons.
			// Left button.
			var rad:Number = _start + _interval / _itemsPerPage;
			_leftBtn.x = getItemXInCircle(rad);
			_leftBtn.y = getItemYInCircle(rad)
			// Right button.
			rad = _end - _interval / _itemsPerPage;
			_rightBtn.x = getItemXInCircle(rad);
			_rightBtn.y = getItemYInCircle(rad)
			
			// Draw into the "_back" sprite so that a "mouse out" is not triggered when the left/right arrows become hidden.
			_back.graphics.clear();
			_back.graphics.beginFill(0, 0);
			_back.graphics.drawCircle(_leftBtn.x, _leftBtn.y, 16);
			_back.graphics.drawCircle(_rightBtn.x, _rightBtn.y, 16);
		}
		
		override protected function calculateRadiansAtIndex(index:int):Number
		{
			return (_start + _orginOffset) + _interval * (index + 1);
		}
		
		override protected function calculateInterval():void
		{
			// The interval is the distance between the items (in radians).
			// Use the lesser of the total button length or the items per page value.
			_interval = _span / (Math.min(_len, _itemsPerPage) + 1);
		}
		
		////////////////////
		// PRIVATE FUNCTIONS
		////////////////////
		
		private function updateQue():void
		{
			// Calculate max item index for pagination.
			_maxItemIndex = Math.max(_len - _itemsPerPage, 0);
			
			// Update visibility of items based on whether or not they are within the que range.
			var i:int = 0;
			var len:int = _len;
			for (i; i < len; i++)
			{
				var item:DisplayObject = _items[i];
				
				// Check if this index is within the que range.
				if (isIndexWithinQueRange(i))
				{
					// This is in the que range.
					// Show the item.
					showItem(item);
				}
				else
				{
					// This is not in the que range.
					// Hide it.
					hideItem(item);
				}
			}
			
			// Update visibility of left button.
			if (_itemIndex == 0)
			{
				hideItem(_leftBtn);
			}
			else
			{
				showItem(_leftBtn);
			}
			
			// Update visibility of right button.
			if (_itemIndex == _maxItemIndex)
			{
				hideItem(_rightBtn);
			}
			else
			{
				showItem(_rightBtn);
			}
		}
		
		private function showItem(item:DisplayObject):void
		{
			if (item.visible && item.alpha == 1) return;
			
			item.alpha = 0;
			item.visible = true;
			_animMan.alpha(item, 1, _showButtonDuration, Transitions.CUBIC_OUT, RenderMethod.TIMER);
		}
		
		private function hideItem(item:DisplayObject):void
		{
			if (!item.visible) return;
			
			_animMan.addEventListener(AnimationEvent.FINISH, onAnimFinish);
			_animMan.alpha(item, 0, _hideButtonDuration, Transitions.CUBIC_OUT, RenderMethod.TIMER);
			
			function onAnimFinish(e:AnimationEvent):void
			{
				if (e.animTarget == item && e.animProperty == 'alpha' && item.alpha == 0)
				{
					_animMan.removeEventListener(AnimationEvent.FINISH, onAnimFinish);
					item.visible = false;
				}
			}
		}
		
		private function isIndexWithinQueRange(index:int):Boolean
		{
			return (index > _queStart && index < _queEnd);
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		public function get itemIndex():int
		{
			return _itemIndex;
		}
		public function set itemIndex(value:int):void
		{
			// Item index CANT be less than 0.
			// Also CANT be beyond the the range of total items.
			value = Math.max(value, 0);
			value = Math.min(value, _maxItemIndex);
			if (value == _itemIndex) return;
			_itemIndex = value;
			_queStart = _itemIndex - 1;
			_queEnd = _itemIndex + _itemsPerPage;
			updateQue();
			
			// Animate orgin off set.
			_animMan.property(this, 'orginOffset', -_itemIndex * _interval, _animateOrginDuration, Transitions.CUBIC_OUT, RenderMethod.TIMER);
		}
		
		public function get orginOffset():Number
		{
			return _orginOffset;
		}
		public function set orginOffset(value:Number):void
		{
			if (value == _orginOffset) return;
			_orginOffset = value;
			render();
		}
		
		////////////////////
		// EVENT HANDLERS
		////////////////////
		
		private function onLeftMouseDown(e:MouseEvent):void
		{
			itemIndex -= _paginationIncrement;
		}
		
		private function onRightMouseDown(e:MouseEvent):void
		{
			itemIndex += _paginationIncrement;
		}
		
	}
}