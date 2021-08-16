package com.sdg.display
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	/**
	 * The ContainerGeneric class contains 1 display object.
	 */
	public class ContainerGeneric extends Sprite
	{
		protected var _content:DisplayObject;
		protected var _width:Number;
		protected var _height:Number;
		protected var _alignX:String;
		protected var _alignY:String;
		protected var _fitType:String;
		protected var _fitContent:Boolean;
		protected var _backing:Sprite;
		protected var _paddingTop:Number;
		protected var _paddingRight:Number;
		protected var _paddingBottom:Number;
		protected var _paddingLeft:Number;
		
		public function ContainerGeneric(width:Number = 0, height:Number = 0, fitContent:Boolean = false)
		{
			super();
			
			_width = width;
			_height = height;
			_alignX = AlignType.LEFT;
			_alignY = AlignType.TOP;
			_fitType = FitType.FIT_WITHIN;
			_fitContent = fitContent;
			_paddingTop = 0;
			_paddingRight = 0;
			_paddingBottom = 0;
			_paddingLeft = 0;
		}
		
		////////////////////
		// INSTANCE METHODS
		////////////////////
		
		override public function addChild(child:DisplayObject):DisplayObject
		{
			throw(new Error('Container can only contain 1 child. Set the content property of Container.'));
		}
		
		override public function addChildAt(child:DisplayObject, index:int):DisplayObject
		{
			throw(new Error('Container can only contain 1 child. Set the content property of Container.'));
		}
		
		override public function removeChild(child:DisplayObject):DisplayObject
		{
			throw(new Error('You cannot call removeChild directly on Container. Use the clearContent method of Container.'));
		}
		
		override public function removeChildAt(index:int):DisplayObject
		{
			throw(new Error('You cannot call removeChildAt directly on Container. Use the clearContent method of Container.'));
		}
		
		protected function _addChild(child:DisplayObject):DisplayObject
		{
			return super.addChild(child);
		}
		
		protected function _removeChild(child:DisplayObject):DisplayObject
		{
			return super.removeChild(child);
		}
		
		public function clearContent():void
		{
			if (_content != null)
			{
				_content.removeEventListener(Event.RESIZE, _onContentResize);
				super.removeChild(_content);
			}
			
			_content = null;
		}
		
		protected function _render():void
		{
			if (_content == null) return;
			
			// Create local vars for total horizontal and vertical padding.
			var padX:Number = _paddingLeft + _paddingRight;
			var padY:Number = _paddingTop + _paddingBottom;
			
			if (_fitContent == true)
			{
				// Fit content.
				FitUtil.FitDisplayObject(_content, new Rectangle(_paddingLeft, _paddingTop, _width - padX, _height - padY), FitType.FIT_WITHIN);
			}
			else
			{
				// Expand container to fit content.
				_width = Math.max(_content.width + padX, _width);
				_height = Math.max(_content.height + padY, _height);
				dispatchEvent(new Event(Event.RESIZE));
			}
			
			// Stretch the backing to fit the entire container.
			if (_backing != null)
			{
				_backing.width = _width;
				_backing.height = _height;
			}
			
			// Align content.
			switch (_alignX)
			{
				case AlignType.MIDDLE :
					_content.x = _width / 2 - _content.width / 2;
					break;
				case AlignType.RIGHT :
					_content.x = _width - _content.width - paddingRight;
					break;
				default:
					// Default left align.
					_content.x = _paddingLeft;
					break;
			}
			
			switch (_alignY)
			{
				case AlignType.MIDDLE :
					_content.y = _height / 2 - _content.height / 2;
					break;
				case AlignType.BOTTOM :
					_content.y = _height - _content.height - _paddingBottom;
					break;
				default:
					// Default top align.
					_content.y = _paddingTop;
					break;
			}
		}
		
		public function removeBacking():void
		{
			if (_backing == null) return;
			super.removeChild(Sprite(_backing));
			_backing = null;
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		public function set content(object:DisplayObject):void
		{
			if (_content == object) return _render();
			clearContent();
			
			_content = object;
			super.addChild(_content);
			_content.addEventListener(Event.RESIZE, _onContentResize);
			
			_render();
		}
		
		override public function get width():Number
		{
			return _width;
		}
		override public function set width(value:Number):void
		{
			if (_width == value) return;
			_width = value;
			_render();
			dispatchEvent(new Event(Event.RESIZE));
		}
		
		override public function get height():Number
		{
			return _height;
		}
		override public function set height(value:Number):void
		{
			if (_height == value) return;
			_height = value;
			_render();
			dispatchEvent(new Event(Event.RESIZE));
		}
		
		public function get alignX():String
		{
			return _alignX;
		}
		public function set alignX(value:String):void
		{
			if (_alignX == value) return;
			_alignX = value;
			_render();
		}
		
		public function get alignY():String
		{
			return _alignY;
		}
		public function set alignY(value:String):void
		{
			if (_alignY == value) return;
			_alignY = value;
			_render();
		}
		
		public function get fitType():String
		{
			return _fitType;
		}
		public function set fitType(value:String):void
		{
			if (_fitType == value) return;
			_fitType = value;
			_render();
		}
		
		public function get backing():Sprite
		{
			return _backing;
		}
		public function set backing(value:Sprite):void
		{
			if (_backing != null) super.removeChild(_backing);
			_backing = value;
			super.addChildAt(_backing, 0);
			_render();
		}
		
		public function get paddingTop():Number
		{
			return _paddingTop;
		}
		public function set paddingTop(value:Number):void
		{
			if (_paddingTop == value) return;
			_paddingTop = value;
			_render();
		}
		
		public function get paddingRight():Number
		{
			return _paddingRight;
		}
		public function set paddingRight(value:Number):void
		{
			if (_paddingRight == value) return;
			_paddingRight = value;
			_render();
		}
		
		public function get paddingBottom():Number
		{
			return _paddingBottom;
		}
		public function set paddingBottom(value:Number):void
		{
			if (_paddingBottom == value) return;
			_paddingBottom = value;
			_render();
		}
		
		public function get paddingLeft():Number
		{
			return _paddingLeft;
		}
		public function set paddingLeft(value:Number):void
		{
			if (_paddingLeft == value) return;
			_paddingLeft = value;
			_render();
		}
		
		public function set padding(value:Number):void
		{
			_paddingTop = _paddingRight = _paddingBottom = _paddingLeft = value;
			_render();
		}
		
		
		private function _onContentResize(e:Event):void
		{
			if (_fitContent == false) _render();
		}
		
	}
}