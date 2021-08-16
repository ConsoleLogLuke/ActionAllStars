package com.sdg.util
{
	import com.sdg.net.Environment;
	
	public class AssetUtil extends Object
	{
		public static function GetGameAssetUrl(gameId:uint, fileName:String):String
		{
			return Environment.getAssetUrl() + '/test/gameSwf/gameId/' + gameId.toString() + '/gameFile/' + fileName;
		}
		
		public static function GetRoomBackgroundUrl(backgroundId:uint):String
		{
			return Environment.getAssetUrl() + '/test/static/roomBackground?backgroundId=' + backgroundId;
		}
		
		public static function GetTeamLogoUrl(teamId:uint):String
		{
			return Environment.getAssetUrl() + "/test/static/clipart/teamLogoTemplate?teamId=" + teamId;
		}
		
		public static function GetTurfIcon(level:uint):String
		{
			return GetGameAssetUrl(73, 'house' + level.toString() + '.swf');
		}
		
		public static function GetQuestCardAsset(questId:uint):String
		{
			return Environment.getAssetUrl() + '/test/static/quest/mission?achievementId=' + questId;
		}
		
		public static function GetGameLogoUrl(gameId:int):String
		{
			return Environment.getAssetUrl() + '/test/static/gameImage?gameId=' + gameId;
		}
		
		public static function GetItemImageUrlWithLayerAndContext(itemId:int, layerId:int, contextId:int):String
		{
			return Environment.getAssetUrl() + '/test/static/spritesheet?layerId=' + layerId + '&contextId=' + contextId + '&itemId=' + itemId;
		}
		
		public static function GetEmoteIconUrl(emoteId:int):String
		{
			return GetGameAssetUrl(83, 'emote_icon_' + emoteId + '.swf');
		}
		
		public static function GetJabIconUrl(jabId:int):String
		{
			return GetGameAssetUrl(83, 'jab_icon_' + jabId + '.swf');
		}
		
	}
}