package com.sdg.gameMenus
{
	import com.sdg.net.QuickLoader;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	
	public class BackgroundMenu extends Sprite
	{
		protected var _width:Number;
		protected var _height:Number;
		protected var _body:GameBody;
		
		public function BackgroundMenu(backgroundUrl:String, width:Number, height:Number)
		{
			super();
			_width = width;
			_height = height;
			var background:DisplayObject = new QuickLoader(backgroundUrl, onComplete);
			addChild(background);
			
			function onComplete():void
			{
				background.x = _width/2 - background.width/2;
				background.y = _height/2 - background.height/2;
			}
		}
		
		public function set body(value:GameBody):void
		{
			if (_body == value) return;
			
			if (_body) removeChild(_body);
			
			_body = value;
			addChild(_body);
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