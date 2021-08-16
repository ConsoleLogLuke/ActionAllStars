package com.sdg.game.models
{
	import com.sdg.game.events.UnityNBAEvent;
	import com.sdg.net.Environment;
	import com.sdg.net.QuickLoader;
	
	import flash.display.DisplayObject;
	import flash.events.EventDispatcher;
	
	public class UnityNBATeam extends EventDispatcher
	{
		private var _name:String;
		private var _teamId:int;
		private var _isDefeated:Boolean;
		private var _players:Array;
		private var _logo:DisplayObject;
		
		public function UnityNBATeam(name:String, teamId:int, isDefeated:Boolean, players:Array = null)
		{
			super();
			_name = name;
			_teamId = teamId;
			_isDefeated = isDefeated;
			_players = players;
		}
		
		public function addPlayer(player:UnityNBAPlayer):void
		{
			if (_players == null)
				_players = new Array();
			
			_players.push(player);
		}
		
		public function get logo():DisplayObject
		{
			var logoLoader:QuickLoader; 
			
			if (_logo == null)
			{
				var url:String = "http://" + Environment.getApplicationDomain() + "/test/static/clipart/teamLogoTemplate?teamId=" + teamId;
				logoLoader = new QuickLoader(url, onComplete);
			}
			
			return _logo;
			
			function onComplete():void
			{
				_logo = logoLoader.content;
				dispatchEvent(new UnityNBAEvent(UnityNBAEvent.LOGO_LOADED, true));
			}
		}
		
		public function get name():String
		{
			return _name;
		}
		
		public function get teamId():int
		{
			return _teamId;
		}
		
		public function get isDefeated():Boolean
		{
			return _isDefeated;
		}
		
		public function get players():Array
		{
			return _players;
		}
	}
}