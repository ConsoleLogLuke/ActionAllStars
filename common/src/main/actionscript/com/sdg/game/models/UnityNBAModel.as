package com.sdg.game.models
{
	import com.sdg.game.events.UnityNBAEvent;
	
	import flash.events.EventDispatcher;
	
	public class UnityNBAModel extends EventDispatcher implements IUnityNBAModel
	{
		private var _tierArray:Array;
		private var _myTeam:UnityNBATeam;
		private var _opponentTeam:UnityNBATeam;
		private var _tokensEarned:int;
		private var _xpEarned:int;
		private var _isGameComplete:Boolean;
		private var _isWinner:Boolean;
		private var _myScore:int;
		private var _opponentScore:int;
		
		public function UnityNBAModel()
		{
			super();
		}
		
		public function close():void
		{
			
		}
		
		public function set myTeam(value:UnityNBATeam):void
		{
			_myTeam = value;
		}
		
		public function get myTeam():UnityNBATeam
		{
			return _myTeam;
		}
		
		public function set opponentTeam(value:UnityNBATeam):void
		{
			_opponentTeam = value;
		}
		
		public function get opponentTeam():UnityNBATeam
		{
			return _opponentTeam;
		}
		
		public function get tokensEarned():int
		{
			return _tokensEarned;
		}
		
		public function get xpEarned():int
		{
			return _xpEarned;
		}
		
		public function get isGameComplete():Boolean
		{
			return _isGameComplete;
		}
		
		public function get isWinner():Boolean
		{
			return _isWinner;
		}
		
		public function set gameResult(value:Object):void
		{
			if (value != null)
			{
				var result:XML = XML(value.unityGameResult);
				
				// testing data
				_myScore = result.score1;
				_opponentScore = result.score2;
				_tokensEarned = result.tokensEarned;
				_xpEarned = result.experienceEarned;
				
				var winValue:int = result.win;
				
				// 0 lose, 1 win, 2 game not complete
				if (winValue != 2)
				{
					_isGameComplete = true;
					
					if (winValue == 1)
					{
						_isWinner = true;
					}
				}
			}
			
			dispatchEvent(new UnityNBAEvent(UnityNBAEvent.GAME_RESULT, true));
		}
		
		public function set inputData(value:Object):void
		{
			var tier:UnityNBATier;
			var team:UnityNBATeam;
			
			_tierArray = new Array();
			
			var teamsXmlList:XMLList = value.team;
			
			for each (var teamXml:XML in teamsXmlList)
			{
				var teamName:String = teamXml.@name;
				var teamId:int = teamXml.@teamId;
				var tierIndex:int = teamXml.@tier;
				var isDefeated:Boolean = teamXml.@isDefeated == 1;
				
				team = new UnityNBATeam(teamName, teamId, isDefeated);
				
				var playersXmlList:XMLList = teamXml.player;
				for each (var playerXml:XML in playersXmlList)
				{
					var playerName:String = playerXml.@name;
					
					var player:UnityNBAPlayer = new UnityNBAPlayer(playerName);
					
					var attributesXmlList:XMLList = playerXml.children();
					for each (var attributeXml:XML in attributesXmlList)
					{
						player.addAttribute(attributeXml.name(), attributeXml);
					}
					
					team.addPlayer(player);
				}
				
				tier = _tierArray[tierIndex];
				if (tier == null)
				{
					tier = new UnityNBATier();
					_tierArray[tierIndex] = tier;
				}
				tier.addTeam(team);
			}
			
			// determine lock state of tiers
			var locked:Boolean = false;
			
			for each (tier in _tierArray)
			{
				// set lock state for this tier
				tier.locked = locked;
				
				if (locked == true) continue;

				// determine lock state for next tier
				for each (team in tier.teams)
				{
					if (team.isDefeated == false)
					{
						locked = true;
						break;
					} 
				}
			}
			
			dispatchEvent(new UnityNBAEvent(UnityNBAEvent.DATA_CHANGE, true));
		}
		
		public function get tierArray():Array
		{
			return _tierArray;
		}
		
		public function get myScore():int
		{
			return _myScore;
		}
		
		public function get opponentScore():int
		{
			return _opponentScore;
		}
	}
}