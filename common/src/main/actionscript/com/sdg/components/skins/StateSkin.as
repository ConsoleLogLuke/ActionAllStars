package com.sdg.components.skins
{
	import mx.core.FlexShape;
	import mx.core.IFlexDisplayObject;
	import mx.core.IStateClient;
	import mx.core.UIComponent;

	public class StateSkin extends FlexShape implements IFlexDisplayObject, IStateClient
	{
		private var _currentState:String;
		private var _width:Number = 0;
		private var _height:Number = 0;
		
		public function get currentState():String
		{
			return _currentState;
		}
	
		public function set currentState(value:String):void
		{
			if (value != _currentState)
			{
				_currentState = value;
				invalidateDisplayList();
			}
		}
		
		public function get measuredWidth():Number
		{
			return UIComponent.DEFAULT_MEASURED_MIN_WIDTH;
		}
		
		public function get measuredHeight():Number
		{
			return UIComponent.DEFAULT_MEASURED_MIN_HEIGHT;
		}
		
		override public function get width():Number
		{
			return _width;
		}
		
		override public function set width(value:Number):void
		{
			if (value != _width)
			{
				_width = value;
				invalidateDisplayList();
			}
		}
		
		override public function get height():Number
		{
			return _height;
		}
		
		override public function set height(value:Number):void
		{
			if (value != _height)
			{
				_height = value;
				invalidateDisplayList();
			}
		}
		
		public function StateSkin()
		{
			_width = measuredWidth;
			_height = measuredHeight;
		}
		
		public function move(x:Number, y:Number):void
		{
			this.x = x, this.y = y;
		}
		
		public function setActualSize(w:Number, h:Number):void
		{
			if (w != _width || h != _height)
			{
				_width = w, _height = h;
				invalidateDisplayList();
			}
		}
		
		public function invalidateDisplayList():void
		{
			updateDisplayList(_width, _height);
		}
		
		public function validateDisplayList():void
		{
			updateDisplayList(width, height);
		}
		
		public function getStyle(styleName:String):*
		{
			if (parent is UIComponent)
				return UIComponent(parent).getStyle(styleName);
			
			return null;
		}
		
		protected function updateDisplayList(w:Number, h:Number):void
		{
		}
	}
}