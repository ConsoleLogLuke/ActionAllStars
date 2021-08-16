package com.sdg.control
{
	import com.sdg.components.controls.VerticalScrollBar;
	import com.sdg.events.ScrollEvent;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.geom.Rectangle;

	public class ScrollWindowController extends EventDispatcher
	{
		protected var _vScrollBar:VerticalScrollBar;
		protected var _window:DisplayObject;
		protected var _content:DisplayObject;
		protected var _windowRect:Rectangle;
		
		public function ScrollWindowController(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		////////////////////
		// INSTANCE METHODS
		////////////////////
		
		public function destroy():void
		{
			if (_vScrollBar != null) _vScrollBar.removeEventListener(ScrollEvent.SCROLL, onVScroll);
			if (_content != null) _content.removeEventListener(Event.RESIZE, onContentResize);
			if (_window != null) _window.removeEventListener(Event.RESIZE, onWindowResize);
		}
		
		protected function render():void
		{
			
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		public function get vScrollBar():VerticalScrollBar
		{
			return _vScrollBar;
		}
		public function set vScrollBar(value:VerticalScrollBar):void
		{
			// Remove listeners from old scroll bar.
			if (_vScrollBar != null)
			{
				_vScrollBar.removeEventListener(ScrollEvent.SCROLL, onVScroll);
			}
			// Set new scroll bar.
			_vScrollBar = value;
			// Set content and window size on new scroll bar.
			if (_content != null) _vScrollBar.contentSize = _content.height;
			if (_windowRect != null) _vScrollBar.windowSize = _windowRect.height;
			// Add listeners to new scroll bar.
			_vScrollBar.addEventListener(ScrollEvent.SCROLL, onVScroll);
			render();
		}
		
		public function get content():DisplayObject
		{
			return _content;
		}
		public function set content(value:DisplayObject):void
		{
			// Remove listeners from old content.
			if(_content != null)
			{
				_content.removeEventListener(Event.RESIZE, onContentResize);
			}
			// Set new content.
			_content = value;
			// Set content size on scroll bar.
			if (_vScrollBar != null) _vScrollBar.contentSize = _content.height;
			// Add listeners to new content.
			_content.addEventListener(Event.RESIZE, onContentResize);
			render();
		}
		
		public function get window():DisplayObject
		{
			return _window;
		}
		public function set window(value:DisplayObject):void
		{
			// Remove listeners from old window.
			if (_window != null)
			{
				_window.removeEventListener(Event.RESIZE, onWindowResize);
			}
			// Set new window.
			_window = value;
			
			// Add listeners to new window.
			_window.addEventListener(Event.RESIZE, onWindowResize);
			
			// Update window rect.
			windowRect = _window.getRect(_window);
		}
		
		public function set windowRect(rect:Rectangle):void
		{
			_windowRect = rect;
			
			// Set window size on scroll bar.
			if (_vScrollBar != null) _vScrollBar.windowSize = _windowRect.height;
			
			render();
		}
		
		////////////////////
		// EVENT HANDLERS
		////////////////////
		
		protected function onWindowResize(e:Event):void
		{
			// Update window rect.
			windowRect = _window.getRect(_window);
		}
		
		protected function onContentResize(e:Event):void
		{
			// Set content size on scroll bar.
			if (_vScrollBar != null) _vScrollBar.contentSize = _content.height;
		}
		
		protected function onVScroll(e:ScrollEvent):void
		{
			_content.y = -_content.height * e.scrollPosition;
			
			dispatchEvent(new ScrollEvent(ScrollEvent.SCROLL));
		}
		
	}
}