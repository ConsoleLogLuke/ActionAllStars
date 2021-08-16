package com.sdg.model
{
	import com.sdg.utils.DateUtil;
	
	public class LiveGame extends Object
	{
		private var _id:String;
		private var _startDate:Date;
		private var _homeTeam:LiveGameTeam;
		private var _awayTeam:LiveGameTeam;
		private var _typeId:uint;
		private var _isGameOver:Boolean;
		private var _isGameStarted:Boolean;
		
		public function LiveGame(id:String, startDate:Date, homeTeam:LiveGameTeam, awayTeam:LiveGameTeam, typeId:uint)
		{
			super();
			
			_id = id;
			_startDate = startDate;
			_homeTeam = homeTeam;
			_awayTeam = awayTeam;
			_typeId = typeId;
			_isGameOver = false;
			_isGameStarted = false;
		}
		
		////////////////////
		// STATIC METHODS
		////////////////////
		
		public static function LiveGameFromXML(gameEventXML:XML):LiveGame
		{
			// Validate necesary data.
			var id:String = (gameEventXML.gameEventId != null) ? gameEventXML.gameEventId : '';
			var startDate:Date = (gameEventXML.startDate != null) ? DateUtil.ParseStandardDate(gameEventXML.startDate) : null;
			var typeId:uint = (gameEventXML.gameEventTypeId != null) ? gameEventXML.gameEventTypeId : 0;
			var homeTeamId:uint = (gameEventXML.homeTeamId != null) ? gameEventXML.homeTeamId : 0;
			var homeTeamName:String = (gameEventXML.homeTeamName != null) ? gameEventXML.homeTeamName : '';
			var homeCityName:String = (gameEventXML.homeCityName != null) ? gameEventXML.homeCityName : '';
			var homeTeamShortName:String = (gameEventXML.homeTeamShortName != null) ? gameEventXML.homeTeamShortName : '';
			var awayTeamId:uint = (gameEventXML.awayTeamId != null) ? gameEventXML.awayTeamId : 0;
			var awayTeamName:String = (gameEventXML.awayTeamName != null) ? gameEventXML.awayTeamName : '';
			var awayCityName:String = (gameEventXML.awayCityName != null) ? gameEventXML.awayCityName : '';
			var awayTeamShortName:String = (gameEventXML.awayTeamShortName != null) ? gameEventXML.awayTeamShortName : '';
			var homeTeamColor1:uint = (gameEventXML.homeTeamColor1 != null) ? parseInt('0x' + gameEventXML.homeTeamColor1) : 0xffffff;
			var homeTeamColor2:uint = (gameEventXML.homeTeamColor2 != null) ? parseInt('0x' + gameEventXML.homeTeamColor2) : 0xffffff;
			var awayTeamColor1:uint = (gameEventXML.awayTeamColor1 != null) ? parseInt('0x' + gameEventXML.awayTeamColor1) : 0xffffff;
			var awayTeamColor2:uint = (gameEventXML.awayTeamColor2 != null) ? parseInt('0x' + gameEventXML.awayTeamColor2) : 0xffffff;
			
			// If we don't have all necesary information, then return null.
			if (id.length < 1 || startDate == null) return null;
			
			// Create team objects.
			var homeTeam:LiveGameTeam = new LiveGameTeam(homeTeamId, homeTeamName, homeCityName, homeTeamShortName);
			homeTeam.advantage = LiveGameTeam.HOME_TEAM;
			homeTeam.color1 = homeTeamColor1;
			homeTeam.color2 = homeTeamColor2;
			var awayTeam:LiveGameTeam = new LiveGameTeam(awayTeamId, awayTeamName, awayCityName, awayTeamShortName);
			awayTeam.advantage = LiveGameTeam.AWAY_TEAM;
			awayTeam.color1 = awayTeamColor1;
			awayTeam.color2 = awayTeamColor2;
			
			// Create the live game object.
			var liveGame:LiveGame = new LiveGame(id, startDate, homeTeam, awayTeam, typeId);
			
			return liveGame;
		}
		
		public static function GetGameXML(gameEvent:LiveGame):XML
		{
			var root:XML = new XML(<gameEvent></gameEvent>);
			
			root.appendChild('<gameEventId>' + gameEvent.id + '</gameEventId>');
			root.appendChild('<homeTeamId>' + gameEvent.homeTeam.id + '</homeTeamId>');
			root.appendChild('<homeTeamName>' + gameEvent.homeTeam.name + '</homeTeamName>');
			root.appendChild('<homeTeamShortName>' + gameEvent.homeTeam.shortName + '</homeTeamShortName>');
			root.appendChild('<awayTeamId>' + gameEvent.awayTeam.id + '</awayTeamId>');
			root.appendChild('<awayTeamName>' + gameEvent.awayTeam.name + '</awayTeamName>');
			root.appendChild('<awayTeamShortName>' + gameEvent.awayTeam.shortName + '</awayTeamShortName>');
			root.appendChild('<awayCityName>' + gameEvent.awayTeam.cityName + '</awayCityName>');
			root.appendChild('<startDate>' + DateUtil.DateToStandardString(gameEvent.startDate) + '</startDate>');
			root.appendChild('<gameEventTypeId>' + gameEvent.typeId + '</gameEventTypeId>');
			root.appendChild('<homeTeamColor2>' + zeroPad(gameEvent.homeTeam.color2.toString(16)) + '</homeTeamColor2>');
			root.appendChild('<homeTeamColor1>' + zeroPad(gameEvent.homeTeam.color1.toString(16)) + '</homeTeamColor1>');
			root.appendChild('<awayTeamColor1>' + zeroPad(gameEvent.awayTeam.color1.toString(16)) + '</awayTeamColor1>');
			root.appendChild('<awayTeamColor2>' + zeroPad(gameEvent.awayTeam.color2.toString(16)) + '</awayTeamColor2>');
			
			return root;
			
			function zeroPad(string:String, length:uint = 6):String
			{
				while(string.length < length)
				{
					string = '0' + string;
				}
				
				return string;
			}
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		public function get id():String
		{
			return _id;
		}
		
		public function get startDate():Date
		{
			return _startDate;
		}
		
		public function get typeId():uint
		{
			return _typeId;
		}
		
		public function get homeTeam():LiveGameTeam
		{
			return _homeTeam;
		}
		
		public function get awayTeam():LiveGameTeam
		{
			return _awayTeam;
		}
		
		public function get isGameOver():Boolean
		{
			return _isGameOver;
		}	
		public function set isGameOver(value:Boolean):void
		{
			_isGameOver = value;
		}
		
		public function get isGameStarted():Boolean
		{
			return _isGameStarted;
		}	
		public function set isGameStarted(value:Boolean):void
		{
			_isGameStarted = value;
		}	
	}
}