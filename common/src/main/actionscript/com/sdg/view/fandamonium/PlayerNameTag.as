package com.sdg.view.fandamonium
{
	import flash.display.Sprite;
	import flash.filters.BevelFilter;
	import flash.filters.DropShadowFilter;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	public class PlayerNameTag extends Sprite
	{
		private var _name:String;
		private var _number:uint;
		private var _color1:uint;
		private var _color2:uint;
		private var _fill1:Sprite;
		private var _fill2:Sprite;
		private var _fills:Sprite;
		private var _line:Sprite;
		private var _nameField:TextField;
		private var _numberField:TextField;
		
		public function PlayerNameTag(name:String, number:uint, color1:uint = 0xff0000, color2:uint = 0x0000ff)
		{
			super();
			_name = name;
			_number = number;
			_color1 = color1;
			_color2 = color2;
			
			_nameField = new TextField();
			_nameField.defaultTextFormat = new TextFormat('GillSans', 12, 0xffffff, true);
			_nameField.embedFonts = true;
			_nameField.autoSize = TextFieldAutoSize.LEFT;
			_nameField.selectable = false;
			_nameField.mouseEnabled = false;
			_nameField.text = _name;
			_nameField.filters = [new DropShadowFilter(1, 45, 0, 0.8, 2, 2)];
			addChild(_nameField);
			
			_numberField = new TextField();
			_numberField.defaultTextFormat = _nameField.defaultTextFormat;
			_numberField.embedFonts = true;
			_numberField.autoSize = TextFieldAutoSize.LEFT;
			_numberField.selectable = false;
			_numberField.mouseEnabled = false;
			_numberField.text = _number.toString();
			_numberField.filters = _nameField.filters;
			addChild(_numberField);
			
			_fill1 = new Sprite();
			_fill2 = new Sprite();
			_fills = new Sprite();
			_fills.addChild(_fill1);
			_fills.addChild(_fill2);
			_fills.filters = [new BevelFilter(1, 45, 0xffffff, 1, 0, 1, 3, 3)];
			addChildAt(_fills, 0);
			
			_line = new Sprite();
			_line.filters = [new BevelFilter(1, 45, 0xffffff, 1, 0, 1, 2, 2)];
			addChild(_line);
			
			render();
		}
		
		private function render():void
		{
			var space:Number = 10;
			_nameField.x = space;
			var nameBounds:Rectangle = _nameField.getBounds(this);
			nameBounds.height += 2;
			
			_numberField.x = nameBounds.right + space;
			var numberBounds:Rectangle = _numberField.getBounds(this);
			
			_fill1.graphics.clear();
			_fill1.graphics.beginFill(_color1);
			_fill1.graphics.moveTo(0, nameBounds.height);
			_fill1.graphics.lineTo(10, 0);
			_fill1.graphics.lineTo(nameBounds.right + space, 0);
			_fill1.graphics.lineTo(nameBounds.right, nameBounds.height);
			_fill1.graphics.lineTo(0, nameBounds.height);
			
			_fill2.graphics.clear();
			_fill2.graphics.beginFill(_color2);
			_fill2.graphics.moveTo(nameBounds.right + space, 0);
			_fill2.graphics.lineTo(numberBounds.right + space, 0);
			_fill2.graphics.lineTo(numberBounds.right, nameBounds.height);
			_fill2.graphics.lineTo(nameBounds.right, nameBounds.height);
			_fill2.graphics.lineTo(nameBounds.right + space, 0);
			
			_line.graphics.clear();
			_line.graphics.lineStyle(3, 0xcccccc);
			_line.graphics.moveTo(0, nameBounds.height);
			_line.graphics.lineTo(10, 0);
			_line.graphics.lineTo(numberBounds.right + space, 0);
			_line.graphics.lineTo(numberBounds.right, nameBounds.height);
			_line.graphics.lineTo(0, nameBounds.height);
		}
		
	}
}