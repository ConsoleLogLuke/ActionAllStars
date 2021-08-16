package com.sdg.components.controls
{
	public class GameConsoleDelegate
	{
		private static var _gameConsole:GameConsole;
		private static var _isInit:Boolean;
		
		public static function init(gameConsole:GameConsole):void
		{
			if (_isInit) return;
			_isInit = true;
			
			_gameConsole = gameConsole;
		}
		
		public static function get gameConsole():GameConsole
		{
			return _gameConsole;
		}
		
	}
}