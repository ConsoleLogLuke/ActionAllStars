package com.sdg.gameMenus
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	public class GreyedOutGridRow extends GridRow
	{
		protected var _constantField:Array;
		protected var _greyBlock:Sprite;
		protected var _textField:TextField;
		
		public function GreyedOutGridRow(greyedOutText:String = null)
		{
			super();
			_constantField = new Array();
			
			_greyBlock = new Sprite();
			_greyBlock.visible = false;
			addChild(_greyBlock);
			
			if (greyedOutText)
			{
				_textField = new TextField();
				_textField.defaultTextFormat = new TextFormat('EuroStyle', 30, 0x848A8C, true);
				_textField.embedFonts = true;
				_textField.autoSize = TextFieldAutoSize.LEFT;
				_textField.selectable = false;
				_textField.mouseEnabled = false;
				_textField.text = greyedOutText;
				_greyBlock.addChild(_textField);
			}
		}
		
		public function addConstantField(field:GridField):void
		{
			addField(field);
			_constantField.push(field);
		}
		
		public function set greyedOut(value:Boolean):void
		{
			if (value)
			{
				_greyBlock.graphics.clear();
				_greyBlock.graphics.beginFill(0xbbbbbb, .9);
				_greyBlock.graphics.drawRect(0, 0, width, height);
				
				if (_textField)
				{
					_textField.x = width - _textField.width - 60;
					_textField.y = height/2 - _textField.height/2;
				}
				
				setChildIndex(_greyBlock, numChildren-1);
				for each (var field:GridField in _constantField)
				{
					var display:DisplayObject = field.display;
					display.x = field.x + display.x;
					_greyBlock.addChild(display);
				}
			}
			_greyBlock.visible = value;
		}
	}
}