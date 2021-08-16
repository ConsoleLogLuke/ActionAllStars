package com.good.goodui
{
	import com.good.goodgraphics.GoodRect;
	
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;

	public class GoodInput extends FluidView
	{
		protected var _id:uint;
		protected var _name:String;
		protected var _backing:GoodRect;
		protected var _input:TextField;
		protected var _format:TextFormat;
		protected var _innerGlow:GlowFilter;
		protected var _label:TextField;
		
		public function GoodInput(id:uint, name:String, width:Number)
		{
			_id = id;
			_name = name;
			_format = new TextFormat('Arial', 14, 0x000000);
			_innerGlow = new GlowFilter(0, 0.3, 8, 8, 2, 1, true);
			
			// Create input.
			_input = new TextField();
			_input.defaultTextFormat = _format;
			_input.type = TextFieldType.INPUT;
			_input.height = _input.textHeight * 1.3;
			
			_label = new TextField();
			_label.defaultTextFormat = new TextFormat('Arial', 12, 0, true);
			_label.autoSize = TextFieldAutoSize.LEFT;
			_label.selectable = false;
			_label.visible = false;
			_label.text = _name;
			
			var h:Number = textSize * 2;
			
			_backing = new GoodRect(width, h, h, 0xffffff);
			_backing.filters = [_innerGlow];
			
			addChild(_backing);
			addChild(_input);
			addChild(_label);
			
			super(width, h);
			
			render();
		}
		
		override protected function render():void
		{
			super.render();
			
			var h:Number = textSize * 2;
			var labelH:Number = (_label.visible) ? _label.height : 0;
			_height = h + labelH;
			
			_backing.width = _width;
			_backing.height = h;
			_backing.y = labelH;
			
			_input.width = _width - _backing.cornerSize;
			_input.height = _input.textHeight * 1.3;
			_input.x = _backing.cornerSize / 2;
			_input.y = _backing.y + _backing.height / 2 - _input.height / 2;
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		public function get id():uint
		{
			return _id;
		}
		
		override public function get name():String
		{
			return _name;
		}
		
		public function get value():String
		{
			return _input.text;
		}
		public function set value(value:String):void
		{
			_input.text = value;
		}
		
		public function get useLabel():Boolean
		{
			return _label.visible;
		}
		public function set useLabel(value:Boolean):void
		{
			//if (value == _label.visible) return;
			_label.visible = value;
			render();
		}
		
		public function get isPassword():Boolean
		{
			return _input.displayAsPassword;
		}
		public function set isPassword(value:Boolean):void
		{
			_input.displayAsPassword = value;
		}
		
		public function get textSize():Number
		{
			return Number(_format.size.toString());
		}
		
		override public function set height(value:Number):void
		{
			// Height is read only for good input.
		}
		
		public function get embedFonts():Boolean
		{
			return _input.embedFonts;
		}
		public function set embedFonts(value:Boolean):void
		{
			_input.embedFonts = value;
		}
		
	}
}