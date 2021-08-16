package com.sdg.gameMenus
{
	import com.sdg.net.QuickLoader;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	public class GameHeader extends Sprite
	{
		protected var _width:Number;
		protected var _height:Number;
		protected var _backgroundUrl:String;
		protected var _background:DisplayObject;
		protected var _gameLogoUrl:String;
		protected var _gameLogo:DisplayObject;
		protected var _leagueLogoUrl:String;
		protected var _leagueLogo:DisplayObject;
		protected var _titleString:String;
		protected var _titleText:TextField;
		
		public function GameHeader(width:Number = 925, height:Number = 150)
		{
			super();
			_width = width;
			_height = height;
		}
		
		protected function loadBackground():void
		{
			var background:DisplayObject = new QuickLoader(_backgroundUrl, onComplete);
			
			function onComplete():void
			{
				addChild(background);
				setChildIndex(background, 0);
				background.x = _width/2 - background.width/2;
				if (_background) removeChild(_background);
				_background = background;
			}
		}
		
		protected function loadGameLogo():void
		{
			var gameLogo:DisplayObject = new QuickLoader(_gameLogoUrl, onComplete);
			
			function onComplete():void
			{
				addChild(gameLogo);
				gameLogo.x = _width/2 - gameLogo.width/2;
				gameLogo.y = _height/2 - gameLogo.height/2;
				if (_gameLogo) removeChild(_gameLogo);
				_gameLogo = gameLogo;
			}
		}
		
		protected function loadLeagueLogo():void
		{
			var leagueLogo:DisplayObject = new QuickLoader(_leagueLogoUrl, onComplete);
			
			function onComplete():void
			{
				addChild(leagueLogo);
				leagueLogo.x = _width - 10 - leagueLogo.width;
				leagueLogo.y = _height/2 - leagueLogo.height/2;
				if (_leagueLogo) removeChild(_leagueLogo);
				_leagueLogo = leagueLogo;
			}
		}
		
		protected function updateTitle():void
		{
			if (_titleText == null)
			{
				_titleText= new TextField();
				_titleText.defaultTextFormat = new TextFormat('EuroStyle', 30, 0x848A8C, true);
				_titleText.embedFonts = true;
				_titleText.autoSize = TextFieldAutoSize.LEFT;
				_titleText.selectable = false;
				_titleText.mouseEnabled = false;
				addChild(_titleText);
			}
			
			_titleText.text = _titleString;
			_titleText.x = _width - 20 - _titleText.width;
			_titleText.y = _height - 7 - _titleText.height;
		}
		
		public function set backgroundUrl(value:String):void
		{
			if (_backgroundUrl == value) return;
			
			_backgroundUrl = value;
			loadBackground();
		}
		
		public function set gameLogoUrl(value:String):void
		{
			if (_gameLogoUrl == value) return;
			
			_gameLogoUrl = value;
			loadGameLogo();
		}
		
		public function set leagueLogoUrl(value:String):void
		{
			if (_leagueLogoUrl == value) return;
			
			_leagueLogoUrl = value;
			loadLeagueLogo();
		}
		
		public function set titleString(value:String):void
		{
			if (_titleString == value) return;
			
			_titleString = value;
			updateTitle();
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
