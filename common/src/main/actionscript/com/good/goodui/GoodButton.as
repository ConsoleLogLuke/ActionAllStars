package com.good.goodui
{
	import com.good.goodgraphics.GoodRect;
	
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	public class GoodButton extends FluidView
	{
		protected var _backing:GoodRect;
		protected var _field:TextField;
		protected var _margin:Number;
		protected var _shadow:DropShadowFilter;
		protected var _format:TextFormat;
		protected var _glow:GlowFilter;
		
		public function GoodButton(label:String, color:uint = 0x677192)
		{
			super(10, 10);
			
			_margin = 4;
			_shadow = new DropShadowFilter(1, 45, 0, 1, 2, 2);
			_format = new TextFormat('Arial', 14, 0xffffff, true);
			_glow = new GlowFilter(0xffffff, 1, 6, 6, 2);
			
			_backing = new GoodRect(_width, _height, _height / 2, color);
			addChild(_backing);
			
			_field = new TextField();
			_field.defaultTextFormat = _format;
			_field.autoSize = TextFieldAutoSize.LEFT;
			_field.selectable = false;
			_field.mouseEnabled = false;
			_field.text = label;
			_field.filters = [_shadow];
			addChild(_field);
			
			var h:Number = _field.height + _margin;
			
			_width = _field.width + h;
			_height = h;
			
			buttonMode = true;
			
			render();
			
			addEventListener(MouseEvent.ROLL_OVER, onRollOver);
			addEventListener(MouseEvent.ROLL_OUT, onRollOut);
		}
		
		override protected function render():void
		{
			super.render();
			
			_backing.width = _width;
			_backing.height = _height;
			_backing.cornerSize = _height;
			
			_field.x = _width / 2 - _field.width / 2;
			_field.y = _margin / 2;
		}
		
		public function destroy():void
		{
			removeEventListener(MouseEvent.ROLL_OVER, onRollOver);
			removeEventListener(MouseEvent.ROLL_OUT, onRollOut);
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		public function get color():uint
		{
			return _backing.color;
		}
		public function set color(value:uint):void
		{
			_backing.color = value;
		}
		
		public function get labelFormat():TextFormat
		{
			return _format;
		}
		public function set labelFormat(value:TextFormat):void
		{
			_format = value;
			
			// Set new text format.
			_field.defaultTextFormat = _format;
			_field.setTextFormat(_format);
			
			// Adjust size according to new format.
			_height = _field.height + _margin;
			_width = _field.width + _height;
			
			render();
		}
		
		public function get embedFonts():Boolean
		{
			return _field.embedFonts;
		}
		public function set embedFonts(value:Boolean):void
		{
			_field.embedFonts = value;
		}
		
		////////////////////
		// EVENT HANDLERS
		////////////////////
		
		private function onRollOver(e:MouseEvent):void
		{
			_backing.filters = [_glow];
		}
		
		private function onRollOut(e:MouseEvent):void
		{
			_backing.filters = [];
		}
		
	}
}