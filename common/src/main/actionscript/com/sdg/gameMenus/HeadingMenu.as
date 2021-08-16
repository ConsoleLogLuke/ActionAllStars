package com.sdg.gameMenus
{
	import flash.display.Sprite;
	
	public class HeadingMenu extends Sprite
	{
		protected var _width:Number;
		protected var _height:Number;
		protected var _header:GameHeader;
		protected var _body:GameBody;
		
		public function HeadingMenu(width:Number, height:Number)
		{
			super();
			_width = width;
			_height = height;
		}
		
		protected function render():void
		{
			var headerHeight:Number = 0;
			
			if (_header)
			{
				_header.x = _width/2 - _header.width/2;
				headerHeight = _header.height;
			}
			
			if (_body)
			{
				_body.x = _width/2 - _body.width/2;
				_body.y = headerHeight;
			}
		}
		
		public function set header(value:GameHeader):void
		{
			if (_header == value) return;
			
			if (_header) removeChild(_header);
			
			_header = value;
			addChild(_header);
			
			render();
		}
		
		public function set body(value:GameBody):void
		{
			if (_body == value) return;
			
			if (_body) removeChild(_body);
			
			_body = value;
			addChild(_body);
			
			render();
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