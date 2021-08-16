package com.sdg.display
{
	import flash.display.DisplayObject;
	import flash.filters.GlowFilter;
	
	public class AdBlock extends Container
	{
		protected var _contentMask:Box;
		protected var _cornerSize:Number;
		
		public function AdBlock(width:Number = 100, height:Number = 100, fitContent:Boolean=false)
		{
			super(width, height, fitContent);
			
			// Create initial values.
			_cornerSize = 0;
			_contentMask = new Box(_width, _height);
			
			// Add the content mask to the display list.
			_addChild(_contentMask);
			
			filters = [new GlowFilter(0x63acf0, 0.4, 32, 32, 2, 1, true), new GlowFilter(0x63acf0, 0.5, 2, 2, 8)];
			
			_render();
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		override protected function _render():void
		{
			super._render();
			_contentMask.width = _width;
			_contentMask.height = _height;
			_contentMask.cornerSize = _cornerSize;
		}
		
		override public function set content(object:DisplayObject):void
		{
			super.content = object;
			_content.mask = _contentMask;
		}
		
		public function get cornerSize():Number
		{
			return _cornerSize;
		}
		public function set cornerSize(value:Number):void
		{
			if (_cornerSize == value) return;
			_cornerSize = value;
			_render();
		}
		
	}
}