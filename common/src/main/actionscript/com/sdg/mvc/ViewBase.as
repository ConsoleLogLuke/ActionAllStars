package com.sdg.mvc
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;

	public class ViewBase extends Sprite implements IView
	{
		protected var _width:Number;
		protected var _height:Number;
		
		public function ViewBase()
		{
			super();
			
			_width = 0;
			_height = 0;
		}
		
		public function init(width:Number, height:Number):void
		{
			_width = width;
			_height = height;
		}
		
		public function destroy():void
		{
		}
		
		public function render():void
		{
		}
		
		public function get display():DisplayObject
		{
			return this;
		}
		
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
		
	}
}