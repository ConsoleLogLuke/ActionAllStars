package com.sdg.model
{
	public class LiveGamePlayer extends Object
	{
		private var _id:uint;
		private var _teamId:uint;
		private var _number:uint;
		private var _name:String;
		
		public function LiveGamePlayer(id:uint, name:String, teamId:uint, number:uint)
		{
			super();
			
			_id = id;
			_name = name;
			_teamId = teamId;
			_number = number;
		}
		
		////////////////////
		// STATIC METHODS
		////////////////////
		
		public static function PlayerFromXML(playerXML:XML):LiveGamePlayer
		{
			// Validate player data.
			var id:uint = (playerXML.playerId != null) ? playerXML.playerId : 0;
			var teamId:uint = (playerXML.teamId != null) ? playerXML.teamId : 0;
			var number:uint = (playerXML.number != null) ? playerXML.number : 0;
			var name:String = (playerXML.displayName != null) ? playerXML.displayName : '';
			
			// Create player object.
			var player:LiveGamePlayer = new LiveGamePlayer(id, name, teamId, number);
			
			return player;
		}
		
		public static function GetPlayerXML(player:LiveGamePlayer, rootName:String = 'player'):XML
		{
			var root:XML = new XML('<' + rootName + '></' + rootName + '>');
			
			root.appendChild('<playerId>' + player.id + '</playerId>');
			root.appendChild('<displayName>' + player.name + '</displayName>');
			root.appendChild('<teamId>' + player.teamId + '</teamId>');
			root.appendChild('<number>' + player.number + '</number>');
			
			return root;
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		public function get id():uint
		{
			return _id;
		}
		
		public function get name():String
		{
			return _name;
		}
		
		public function get number():uint
		{
			return _number;
		}
		
		public function get teamId():uint
		{
			return _teamId;
		}
		
	}
}