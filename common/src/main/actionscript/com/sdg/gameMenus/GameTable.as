package com.sdg.gameMenus
{
	import flash.display.Sprite;
	
	public class GameTable extends Sprite
	{
		protected var _width:Number;
		protected var _height:Number;
		protected var _header:Sprite;
		
		public function GameTable(width:Number = 858, height:Number = 350, headerHeight:Number = 37, borderThickness:Number = 4)
		{
			super();
			_width = width;
			_height = height;
			
			graphics.lineStyle(borderThickness, 0x718799);
			graphics.drawRect(borderThickness/2, borderThickness/2, _width - borderThickness, _height - borderThickness);
			
			_header = new Sprite();
			_header.graphics.lineStyle(1, 0x718799);
			_header.graphics.beginFill(0xB8C0C7);
			_header.graphics.drawRect(0, 0, _width - 2 * borderThickness, headerHeight);
			
			_header.x = _width/2 - _header.width/2;
			_header.y = borderThickness;
			addChild(_header);
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