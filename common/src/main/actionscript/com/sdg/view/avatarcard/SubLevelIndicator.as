package com.sdg.view.avatarcard
{
	import com.good.goodui.FluidView;
	
	import flash.display.Sprite;
	import flash.filters.BevelFilter;
	import flash.filters.DropShadowFilter;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	public class SubLevelIndicator extends FluidView
	{
		protected var _field:TextField;
		protected var _format:TextFormat;
		protected var _back:Sprite;
		protected var _bevel:BevelFilter;
		protected var _shadow:DropShadowFilter;
		protected var _subLevel:uint;
		protected var _color:uint;
		
		public function SubLevelIndicator(size:Number, subLevel:uint, color:uint)
		{
			_subLevel = subLevel;
			_color = color;
			
			_shadow = new DropShadowFilter(1, 45, 0, 1, 3, 3);
			
			_bevel = new BevelFilter(1, 45, 0xffffff, 1, 0, 1, 2, 2);
			
			_format = new TextFormat('EuroStyle', 12, 0xffffff, true);
			
			_field = new TextField();
			_field.defaultTextFormat = _format;
			_field.autoSize = TextFieldAutoSize.LEFT;
			_field.embedFonts = true;
			_field.selectable = false;
			_field.text = _subLevel.toString();
			_field.filters = [_shadow];
			
			_back = new Sprite();
			_back.filters = [_bevel];
			
			super(size, size);
			
			addChild(_back);
			addChild(_field);
			
			render();
		}
		
		override protected function render():void
		{
			super.render();
			
			_back.graphics.clear();
			_back.graphics.beginFill(_color);
			_back.graphics.drawEllipse(0, 0, _width, _height);
			
			_field.x = _width / 2 - _field.width / 2;
			_field.y = _height / 2 - _field.height / 2;
		}
		
	}
}