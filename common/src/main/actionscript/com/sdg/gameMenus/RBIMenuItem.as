package com.sdg.gameMenus
{
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	public class RBIMenuItem extends Sprite implements IGameMenuItem
	{
		protected var _menuText:TextField;
		protected var _menuLine2Text:TextField;
		protected var _onSelected:Function;
		
		public function RBIMenuItem(menuString:String, menuLine2String:String = null, onSelected:Function = null, textColor:uint = 0x5F708A)
		{
			super();
			_menuText = new TextField();
			_menuText.defaultTextFormat = new TextFormat('EuroStyle', 25, textColor, true);
			_menuText.embedFonts = true;
			_menuText.autoSize = TextFieldAutoSize.LEFT;
			_menuText.selectable = false;
			_menuText.mouseEnabled = false;
			_menuText.text = menuString;
			addChild(_menuText);
			
			menuLine2Text = menuLine2String;
			
			_onSelected = onSelected;
			
			render();
		}
		
		public function destroy():void
		{
			
		}
		
		protected function render():void
		{
			_menuText.x = 0;
			
			if (_menuLine2Text)
			{
				_menuLine2Text.x = 0;
				_menuLine2Text.x = width/2 - _menuLine2Text.width/2;
				_menuLine2Text.y = _menuText.y + _menuText.height - 4;
			}
			
			_menuText.x = width/2 - _menuText.width/2;
		}
		
		public function set onSelected(value:Function):void
		{
			_onSelected = value;
		}
		
		public function get onSelected():Function
		{
			return _onSelected;
		}
		
		public function set menuString(value:String):void
		{
			_menuText.text = value;
			render();
		}
		
		public function set menuLine2String(value:String):void
		{
			menuLine2Text = value;
			render();
		}
		
		protected function set menuLine2Text(value:String):void
		{
			if (value == null)
			{
				if (_menuLine2Text != null)
				{
					removeChild(_menuLine2Text);
					_menuLine2Text = null;
				}
			}
			else
			{
				if (_menuLine2Text == null)
				{
					_menuLine2Text = new TextField();
					_menuLine2Text.defaultTextFormat = new TextFormat('EuroStyle', 12, _menuText.textColor, true);
					_menuLine2Text.embedFonts = true;
					_menuLine2Text.autoSize = TextFieldAutoSize.LEFT;
					_menuLine2Text.selectable = false;
					_menuLine2Text.mouseEnabled = false;
					addChild(_menuLine2Text);
				}
				
				_menuLine2Text.text = value;
			}
		}
		
		public function get menuText():TextField
		{
			return _menuText;
		}
		
		public function set textColor(value:uint):void
		{
			_menuText.textColor = value;
			
			if (_menuLine2Text)
			{
				_menuLine2Text.textColor = value;
			}
		}
	}
}