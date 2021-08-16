package com.sdg.model
{
	import com.sdg.events.GameCastEvent;
	
	public class FandamoniumEndGameData
	{
		private var _topAvatarName:String;
		private var _topAvatarScore:int;
		private var _topAvatarId:int;
		private var _topAvatarTeamId:int;
		
		public function FandamoniumEndGameData(topAvatarId:int, topAvatarName:String, topAvatarScore:int, topAvatarTeamId:int)
		{
			_topAvatarId = topAvatarId;
			_topAvatarName = topAvatarName;
			_topAvatarScore = topAvatarScore;
			_topAvatarTeamId = topAvatarTeamId;
		}
		
		public static function GetDataFromGameCastEvent(event:GameCastEvent):FandamoniumEndGameData
		{
			if (event.type != GameCastEvent.END_GAME_EVENT) return null;
			
			var params:Object = event.params;
			if (params == null) return null;
			
			var xml:XML = (params.gameEndEvent != null) ? new XML(params.gameEndEvent) : null;
			if (xml == null) return null;
			
			if (!xml.hasOwnProperty("topAvatarId")) return null;
			if (!xml.hasOwnProperty("topAvatarScore")) return null;
			if (!xml.hasOwnProperty("topAvatarName")) return null;
			if (!xml.hasOwnProperty("topAvatarTeamId")) return null;
			
			return new FandamoniumEndGameData(xml.topAvatarId, xml.topAvatarName, xml.topAvatarScore, xml.topAvatarTeamId);
		}
		
		public function get topAvatarName():String
		{
			return _topAvatarName;
		}
		
		public function get topAvatarScore():int
		{
			return _topAvatarScore;
		}
		
		public function get topAvatarId():int
		{
			return _topAvatarId;
		}
		
		public function get topAvatarTeamId():int
		{
			return _topAvatarTeamId;
		}
	}
}