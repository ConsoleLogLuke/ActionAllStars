package com.sdg.components.controls
{
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	public class VerticalScrollBar extends ScrollBar
	{
		public function VerticalScrollBar()
		{
			super();
		}
		
		////////////////////
		// INSTANCE METHODS
		////////////////////
		
		override protected function render():void
		{
			super.render();
			if (_renderEnabled != true) return;
			
			// Render each piece one by one.
			renderScrollButton1();
			
			renderScrollButton2();
			
			renderScrollBarBacking();
			
			renderScrollBarGrabber();
		}
		
		protected function renderScrollButton1():void
		{
			if (_scrollButton1 != null)
			{
				_scrollButton1.x = 0;
				_scrollButton1.y = 0;
				_scrollButton1.width = _scrollButton1.height = _width;
			}
		}
		
		protected function renderScrollButton2():void
		{
			if (_scrollButton2 != null)
			{
				_scrollButton2.width = _scrollButton2.height = _width;
				_scrollButton2.x = 0;
				_scrollButton2.y = _height - _scrollButton2.height;
			}
		}
		
		protected function renderScrollBarBacking():void
		{
			// Create locals.
			var backingHeight:Number = _height - _width * 2;
			
			if (_scrollBarBacking != null)
			{
				_scrollBarBacking.width = _width;
				_scrollBarBacking.height = backingHeight;
				_scrollBarBacking.x = 0;
				_scrollBarBacking.y = _width;
			}
		}
		
		protected function renderScrollBarGrabber():void
		{
			// Create locals.
			var backingHeight:Number = _height - _width * 2;
			
			if (_scrollBarGrabber != null)
			{
				_scrollBarGrabber.visible = (_contentSize < _windowSize) ? false : true;
				_scrollBarGrabber.width = _width;
				var grabberPortion:Number = (_windowSize > 0 && _windowSize < _contentSize) ? _windowSize / _contentSize : 0;
				_scrollBarGrabber.height = grabberPortion * backingHeight;
				_scrollBarGrabber.x = 0;
				_scrollBarGrabber.y = _width + backingHeight * _scrollPosition;
			}
		}
		
		////////////////////
		// EVENT HANDLERS
		////////////////////
		
		override protected function onScrollGrabberDown(e:MouseEvent):void
		{
			super.onScrollGrabberDown(e);
			
			// Start dragging the scroll grabber.
			var rootContainer:DisplayObject = getRootContainer();
			var offset:Number = _scrollBarGrabber.y - mouseY;
			var backingHeight:Number = _height - _width * 2;
			var backingTop:Number = _width;
			rootContainer.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			rootContainer.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			
			function onMouseMove(e:MouseEvent):void
			{
				// Determine a new scroll position.
				var newPos:Number = mouseY + offset;
				var scrollPos:Number = (newPos - backingTop) / backingHeight;
				scrollPosition = scrollPos;
			}
			
			function onMouseUp(e:MouseEvent):void
			{
				// Stop dragging the scroll bar grabber.
				rootContainer.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
				rootContainer.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			}
		}
		
		override protected function onScrollBackingDown(e:MouseEvent):void
		{
			// Determine a scroll position based on the location of the mouse.
			var mY:Number = mouseY - scrollBarBacking.y;
			var scrollPos:Number = mY / scrollBarBacking.height;
			scrollPosition = scrollPos;
		}
		
	}
}