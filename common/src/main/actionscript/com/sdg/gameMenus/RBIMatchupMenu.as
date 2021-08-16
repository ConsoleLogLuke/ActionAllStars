package com.sdg.gameMenus
{
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	public class RBIMatchupMenu extends Sprite
	{
		protected var _p1Icon:MatchupIcon;
		protected var _p2Icon:MatchupIcon;
		protected var _gameStatusText:TextField;
		protected var _width:Number;
		protected var _height:Number;
		
		public function RBIMatchupMenu(player1:String, player2:String = null, width:Number = 925, height:Number = 665)
		{
			super();
			
			_width = width;
			_height = height;
			
			_p1Icon = new MatchupIcon(player1, true);
			addChild(_p1Icon);
			
			_p2Icon = new MatchupIcon(player2, false);
			addChild(_p2Icon);
			
			_gameStatusText = new TextField();
			_gameStatusText.defaultTextFormat = new TextFormat('EuroStyle', 25, 0x333333, true);
			_gameStatusText.embedFonts = true;
			_gameStatusText.autoSize = TextFieldAutoSize.LEFT;
			_gameStatusText.selectable = false;
			_gameStatusText.mouseEnabled = false;
			addChild(_gameStatusText);
			
			render();
			
			updateGameStatus();
		}
		
		public function set player1(value:String):void
		{
			updatePlayerIcon(value, _p1Icon);
		}
		
		public function set player2(value:String):void
		{
			updatePlayerIcon(value, _p2Icon);
		}
		
		protected function updatePlayerIcon(pname:String, icon:MatchupIcon):void
		{
			icon.playerName = pname;
			updateGameStatus();
		}
		
		protected function updateGameStatus():void
		{
			if (_p1Icon.hasPlayer && _p2Icon.hasPlayer)
			{
				_gameStatusText.text = "Starting Game...";
			}
			else
			{
				_gameStatusText.text = "Waiting for another player...";
			}
			
			_gameStatusText.x = _width/2 - _gameStatusText.width/2;
			_gameStatusText.y = 150;
		}
		
		protected function render():void
		{
			_p1Icon.x = _width/4 - _p1Icon.width/2;
			_p2Icon.x = 3*_width/4 - _p2Icon.width/2;
		}
	}
}