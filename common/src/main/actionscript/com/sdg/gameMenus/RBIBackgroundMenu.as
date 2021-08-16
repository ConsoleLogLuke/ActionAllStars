package com.sdg.gameMenus
{
	import com.sdg.net.QuickLoader;
	
	import flash.display.DisplayObject;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	public class RBIBackgroundMenu extends BackgroundMenu
	{
		protected var _menuText:TextField;
		
		public function RBIBackgroundMenu(width:Number, height:Number)
		{
			super("assets/swfs/rbi/rbiBGMenu.swf", width, height);
			
			_menuText = new TextField();
			_menuText.defaultTextFormat = new TextFormat('EuroStyle', 30, 0x848A8C, true);
			_menuText.embedFonts = true;
			_menuText.autoSize = TextFieldAutoSize.LEFT;
			_menuText.selectable = false;
			_menuText.mouseEnabled = false;
			addChild(_menuText);
			
			var gameLogo:DisplayObject = new QuickLoader("assets/swfs/rbi/rbiLogo.swf", onComplete);
			
			function onComplete():void
			{
				gameLogo.x = _width/2 - gameLogo.width/2;
				gameLogo.y = 75;
				addChild(gameLogo);
			}
		}
		
		override public function set body(value:GameBody):void
		{
			super.body = value;
			value.y = 185;
			_menuText.text = value.menuName;
			_menuText.x = _width - 35 - _menuText.width;
			_menuText.y = 90;
		}
	}
}