package com.sdg.components.controls
{
	import com.sdg.events.ScrollEvent;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;

	public class ScrollBar extends Sprite
	{
		protected var _width:Number;
		protected var _height:Number;
		protected var _contentSize:Number;
		protected var _windowSize:Number;
		protected var _scrollPosition:Number;
		protected var _maxScroll:Number;
		protected var _renderEnabled:Boolean;
		protected var _scrollButton1:Sprite;
		protected var _scrollButton2:Sprite;
		protected var _scrollBarBacking:Sprite;
		protected var _scrollBarGrabber:Sprite;
		protected var _scrollWheelTarget:IEventDispatcher;
		
		public function ScrollBar()
		{
			super();
			
			// Create default values.
			_width = 20;
			_height = 120;
			_contentSize = 0;
			_windowSize = 0;
			_scrollPosition = 0;
			
			var sprite:Sprite;
			_renderEnabled = false;
			// Create default button 1.
			sprite = new Sprite();
			sprite.graphics.beginFill(0);
			sprite.graphics.drawRect(0, 0, 10, 10);
			scrollButton1 = sprite;
			// Create default button 2.
			sprite = new Sprite();
			sprite.graphics.beginFill(0);
			sprite.graphics.drawRect(0, 0, 10, 10);
			scrollButton2 = sprite;
			// Create default scroll backing.
			sprite = new Sprite();
			sprite.graphics.beginFill(0xffffff);
			sprite.graphics.drawRect(0, 0, 10, 10);
			scrollBarBacking = sprite;
			// Create default scroll bar grabber.
			sprite = new Sprite();
			sprite.graphics.beginFill(0xcccccc);
			sprite.graphics.drawRect(0, 0, 10, 10);
			scrollBarGrabber = sprite;
			
			_renderEnabled = true;
			render();
		}
		
		////////////////////
		// INSTANCE METHODS
		////////////////////
		
		public function destroy():void
		{
			// Remove all event listeners.
			if (_scrollButton1 != null)
			{
				_scrollButton1.removeEventListener(MouseEvent.MOUSE_DOWN, onScrollButton1Down);
				_scrollButton1.removeEventListener(MouseEvent.MOUSE_UP, onScrollButton1Up);
				removeChild(_scrollButton1);
			}
			
			if (_scrollButton2 != null)
			{
				_scrollButton2.removeEventListener(MouseEvent.MOUSE_DOWN, onScrollButton2Down);
				_scrollButton2.removeEventListener(MouseEvent.MOUSE_UP, onScrollButton2Up);
				removeChild(_scrollButton2);
			}
			
			if (_scrollBarBacking != null)
			{
				_scrollBarBacking.removeEventListener(MouseEvent.MOUSE_DOWN, onScrollBackingDown);
				removeChild(_scrollBarBacking);
			}
			
			if (_scrollBarGrabber != null)
			{
				_scrollBarGrabber.removeEventListener(MouseEvent.MOUSE_DOWN, onScrollGrabberDown);
				removeChild(_scrollBarGrabber);
			}
			
			if (_scrollWheelTarget != null)
			{
				_scrollWheelTarget.removeEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
			}
			
			// Destroy references to help with garbage collection.
			_scrollButton1 = null;
			_scrollButton2 = null;
			_scrollBarBacking = null;
			_scrollBarGrabber = null;
			_scrollWheelTarget = null;
		}
		
		protected function render():void
		{
			if (_renderEnabled != true) return;
		}
		
		private function updateMaxScroll():void
		{
			_maxScroll = (_contentSize > _windowSize) ? (_contentSize - _windowSize) / _contentSize : 0;
		}
		
		protected function getRootContainer():DisplayObject
		{
			// Get a reference to the root display object.
			var root:DisplayObject = this.parent;
			var end:Boolean = false;
			var previousRoot:DisplayObject;
			while (end != true)
			{
				previousRoot = root;
				try
				{
					root = root.parent;
				}
				catch (e:Error)
				{
					root = previousRoot;
					end = true;
				}
				
				if (root == null)
				{
					root = previousRoot;
					end = true;
				}
			}
			
			return root;
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		override public function get width():Number
		{
			return _width;
		}
		override public function set width(value:Number):void
		{
			if (value == _width) return;
			_width = value;
			render();
		}
		
		override public function get height():Number
		{
			return _height;
		}
		override public function set height(value:Number):void
		{
			if (value == _height) return;
			_height = value;
			render();
		}
		
		public function get scrollButton1():Sprite
		{
			return _scrollButton1;
		}
		public function set scrollButton1(value:Sprite):void
		{
			if (value == _scrollButton1) return;
			// Remove the old one.
			if (_scrollButton1 != null)
			{
				_scrollButton1.removeEventListener(MouseEvent.MOUSE_DOWN, onScrollButton1Down);
				_scrollButton1.removeEventListener(MouseEvent.MOUSE_UP, onScrollButton1Up);
				removeChild(_scrollButton1);
			}
			// Add the new one.
			_scrollButton1 = value;
			_scrollButton1.addEventListener(MouseEvent.MOUSE_DOWN, onScrollButton1Down);
			_scrollButton1.addEventListener(MouseEvent.MOUSE_UP, onScrollButton1Up);
			_scrollButton1.buttonMode = true;
			addChild(_scrollButton1);
			render();
		}
		
		public function get scrollButton2():Sprite
		{
			return _scrollButton2;
		}
		public function set scrollButton2(value:Sprite):void
		{
			if (value == _scrollButton2) return;
			// Remove the old one.
			if (_scrollButton2 != null)
			{
				_scrollButton2.removeEventListener(MouseEvent.MOUSE_DOWN, onScrollButton2Down);
				_scrollButton2.removeEventListener(MouseEvent.MOUSE_UP, onScrollButton2Up);
				removeChild(_scrollButton2);
			}
			// Add the new one.
			_scrollButton2 = value;
			_scrollButton2.addEventListener(MouseEvent.MOUSE_DOWN, onScrollButton2Down);
			_scrollButton2.addEventListener(MouseEvent.MOUSE_UP, onScrollButton2Up);
			_scrollButton2.buttonMode = true;
			addChild(_scrollButton2);
			render();
		}
		
		public function get scrollBarBacking():Sprite
		{
			return _scrollBarBacking;
		}
		public function set scrollBarBacking(value:Sprite):void
		{
			if (value == _scrollBarBacking) return;
			// Remove the old one.
			if (_scrollBarBacking != null)
			{
				removeChild(_scrollBarBacking);
				_scrollBarBacking.removeEventListener(MouseEvent.MOUSE_DOWN, onScrollBackingDown);
			}
			// Add the new one.
			_scrollBarBacking = value;
			_scrollBarBacking.addEventListener(MouseEvent.MOUSE_DOWN, onScrollBackingDown);
			addChildAt(_scrollBarBacking, 0);
			render();
		}
		
		public function get scrollBarGrabber():Sprite
		{
			return _scrollBarGrabber;
		}
		public function set scrollBarGrabber(value:Sprite):void
		{
			if (value == _scrollBarGrabber) return;
			// Remove the old one.
			if (_scrollBarGrabber != null)
			{
				_scrollBarGrabber.removeEventListener(MouseEvent.MOUSE_DOWN, onScrollGrabberDown);
				removeChild(_scrollBarGrabber);
			}
			// Add the new one.
			_scrollBarGrabber = value;
			_scrollBarGrabber.addEventListener(MouseEvent.MOUSE_DOWN, onScrollGrabberDown);
			_scrollBarGrabber.buttonMode = true;
			addChild(_scrollBarGrabber);
			render();
		}
		
		public function get contentSize():Number
		{
			return _contentSize;
		}
		public function set contentSize(value:Number):void
		{
			if (value == _contentSize) return;
			// Can't have a negative.
			_contentSize = Math.max(value, 0);
			updateMaxScroll();
			render();
		}
		
		public function get windowSize():Number
		{
			return _windowSize;
		}
		public function set windowSize(value:Number):void
		{
			if (value == _windowSize) return;
			// Can't have a negative.
			_windowSize = Math.max(value, 0);
			updateMaxScroll();
			render();
		}
		
		public function get scrollPosition():Number
		{
			return _scrollPosition;
		}
		public function set scrollPosition(value:Number):void
		{
			if (value == _scrollPosition) return;
			// Can't have a negative.
			_scrollPosition = Math.max(value, 0);
			_scrollPosition = Math.min(_scrollPosition, _maxScroll);
			render();
			
			// Dispatch scroll event.
			var event:ScrollEvent = new ScrollEvent(ScrollEvent.SCROLL);
			event.scrollPosition = _scrollPosition;
			dispatchEvent(event);
		}
		
		public function get scrollWheelTarget():IEventDispatcher
		{
			return _scrollWheelTarget;
		}
		public function set scrollWheelTarget(value:IEventDispatcher):void
		{
			// Remove the previos one.
			if (_scrollWheelTarget != null)
			{
				_scrollWheelTarget.removeEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
			}
			
			// Set new one.
			_scrollWheelTarget = value;
			_scrollWheelTarget.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
		}
		
		////////////////////
		// EVENT HANDLERS
		////////////////////
		
		protected function onScrollButton1Down(e:MouseEvent):void
		{
			// Get scroll amount for 10 pixels.
			var amount:Number = (_contentSize > 0) ? _windowSize /_contentSize / 2 : 0;
			scrollPosition -= amount;
		}
		
		protected function onScrollButton1Up(e:MouseEvent):void
		{
			
		}
		
		protected function onScrollButton2Down(e:MouseEvent):void
		{
			// Get scroll amount for 10 pixels.
			var amount:Number = (_contentSize > 0) ? _windowSize /_contentSize / 2 : 0;
			scrollPosition += amount;
		}
		
		protected function onScrollButton2Up(e:MouseEvent):void
		{
			
		}
		
		protected function onScrollGrabberDown(e:MouseEvent):void
		{	
			
		}
		
		protected function onScrollBackingDown(e:MouseEvent):void
		{
			
		}
		
		protected function onMouseWheel(e:MouseEvent):void
		{
			// Determine wheel direction.
			var delta:int = e.delta;
			
			// Calculate scroll amount.
			var amount:Number = (_contentSize > 0) ? _windowSize /_contentSize / 16 * (-delta) : 0;
			scrollPosition += amount;
		}
		
	}
}