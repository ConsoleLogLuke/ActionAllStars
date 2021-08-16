package com.sdg.gameMenus
{
	import flash.display.Sprite;

	public class GameBody extends Sprite
	{
		protected var _width:Number;
		protected var _height:Number;
		protected var _menuName:String;
		
		public function GameBody(menuName:String, width:Number = 925, height:Number = 515)
		{
			super();
			_width = width;
			_height = height;
			_menuName = menuName;
		}
		
		public function get menuName():String
		{
			return _menuName;
		}
		
		override public function get width():Number
		{
			return _width;
		}
		
		override public function get height():Number
		{
			return _height;
		}
	}
}