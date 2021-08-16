package com.sdg.gameMenus
{
	import com.sdg.events.StartGameEvent;
	import com.sdg.model.Avatar;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	public class RBITeamSelect extends GameBody
	{
		protected const SELECTOR_GAP:Number = 30;
		protected var _numPlayers:int;
		protected var _myTeamSelect:TeamSelectBox;
		protected var _opponentTeamSelect:TeamSelectBox;
		protected var _myNameField:TextField;
		protected var _opponentField:TextField;
		protected var _player1Text:TextField;
		protected var _player2Text:TextField;
		protected var _mainMenuButton:RBIMenuButton;
		protected var _startGameButton:RBIMenuButton;
		
		public function RBITeamSelect(avatar:Avatar, width:Number = 925, height:Number = 480)
		{
			super("TEAM SELECT", width, height);
			_myTeamSelect = new TeamSelectBox();
			_myTeamSelect.y = 85;
			addChild(_myTeamSelect);
			
			_myNameField = new TextField();
			_myNameField.defaultTextFormat = new TextFormat('EuroStyle', 38, 0xffffff, true);
			_myNameField.embedFonts = true;
			_myNameField.autoSize = TextFieldAutoSize.LEFT;
			_myNameField.selectable = false;
			_myNameField.mouseEnabled = false;
			_myNameField.text = avatar.name;
			_myNameField.filters = [new GlowFilter(0x0099FF, 1, 10, 10)];
			addChild(_myNameField);
			
			_mainMenuButton = new RBIMenuButton("MAIN MENU", 120, 28, 5, 12);
			_mainMenuButton.x = _width/2 - _mainMenuButton.width/2;
			_mainMenuButton.y = _height - 30 - _mainMenuButton.height;
			_mainMenuButton.addEventListener(MouseEvent.CLICK, onMainMenuClick);
			addChild(_mainMenuButton);
			
			_startGameButton = new RBIMenuButton("START GAME", 180, 38, 8, 24);
			_startGameButton.x = _width/2 - _startGameButton.width/2;
			_startGameButton.y = _mainMenuButton.y - 14 - _startGameButton.height;
			_startGameButton.addEventListener(MouseEvent.CLICK, onStartGameClick);
			addChild(_startGameButton);
		}
		
		protected function onMainMenuClick(event:MouseEvent):void
		{
			dispatchEvent(new Event("returnToMenu"));
		}
		
		protected function onStartGameClick(event:MouseEvent):void
		{
			dispatchEvent(new StartGameEvent(_numPlayers, _myTeamSelect.selectedTeam.id, _opponentTeamSelect.selectedTeam.id));
		}
		
		public function destroy():void
		{
			_myTeamSelect.destroy();
			if (_opponentTeamSelect)
				_opponentTeamSelect.destroy();
			_mainMenuButton.removeEventListener(MouseEvent.CLICK, onMainMenuClick);
			_mainMenuButton.destroy();
			_startGameButton.removeEventListener(MouseEvent.CLICK, onStartGameClick);
			_startGameButton.destroy();
		}
		
		public function set numPlayers(value:int):void
		{
			_numPlayers = value;
			
			if (_numPlayers == 1)
			{
				if (_opponentTeamSelect == null)
				{
					_opponentTeamSelect = new TeamSelectBox();
					_opponentTeamSelect.y = 85;
					addChild(_opponentTeamSelect);
					
					_opponentField = new TextField();
					_opponentField.defaultTextFormat = new TextFormat('EuroStyle', 38, 0xffffff, true);
					_opponentField.embedFonts = true;
					_opponentField.autoSize = TextFieldAutoSize.LEFT;
					_opponentField.selectable = false;
					_opponentField.mouseEnabled = false;
					_opponentField.text = "Opponent";
					_opponentField.filters = [new GlowFilter(0x0099FF, 1, 10, 10)];
					addChild(_opponentField);
					
					_player1Text = new TextField();
					_player1Text.defaultTextFormat = new TextFormat('EuroStyle', 15, 0x8599AC, true);
					_player1Text.embedFonts = true;
					_player1Text.autoSize = TextFieldAutoSize.LEFT;
					_player1Text.selectable = false;
					_player1Text.mouseEnabled = false;
					_player1Text.text = "";
					addChild(_player1Text);
					
					_player2Text = new TextField();
					_player2Text.defaultTextFormat = new TextFormat('EuroStyle', 15, 0x8599AC, true);
					_player2Text.embedFonts = true;
					_player2Text.autoSize = TextFieldAutoSize.LEFT;
					_player2Text.selectable = false;
					_player2Text.mouseEnabled = false;
					_player2Text.text = "";
					addChild(_player2Text);
				}
				
				_opponentTeamSelect.visible = true;
				_opponentField.visible = true;
				_player1Text.visible = true;
				_player2Text.visible = true;
				
				_myTeamSelect.x = _width/2 - SELECTOR_GAP/2 - _myTeamSelect.width;
				_myNameField.x = _myTeamSelect.x + _myTeamSelect.width/2 - _myNameField.width/2;
				_myNameField.y = _myTeamSelect.y - _myNameField.height;
				_opponentTeamSelect.x = _width/2 + SELECTOR_GAP/2;
				_opponentField.x = _opponentTeamSelect.x + _opponentTeamSelect.width/2 - _opponentField.width/2;
				_opponentField.y = _opponentTeamSelect.y - _opponentField.height;
				_player1Text.x = _myTeamSelect.x + _myTeamSelect.width/2 - _player1Text.width/2;
				_player1Text.y = _myNameField.y - _player1Text.height;
				_player2Text.x = _opponentTeamSelect.x + _opponentTeamSelect.width/2 - _player2Text.width/2;
				_player2Text.y = _opponentField.y - _player2Text.height;
			}
			else if (_numPlayers == 2)
			{
				_myTeamSelect.x = _width/2 - _myTeamSelect.width/2;
				_myNameField.x = _myTeamSelect.x + _myTeamSelect.width/2 - _myNameField.width/2;
				
				if (_opponentTeamSelect)
				{
					_opponentTeamSelect.visible = false;
					_opponentField.visible = false;
					_player1Text.visible = false;
					_player2Text.visible = false;
				}
			}
		}
		
		public function set teams(value:Array):void
		{
			_myTeamSelect.teams = value;
			
			if (_numPlayers == 1)
				_opponentTeamSelect.teams = value;
		}
	}
}