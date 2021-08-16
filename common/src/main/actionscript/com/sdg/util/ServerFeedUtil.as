package com.sdg.util
{
	import com.sdg.net.Environment;
	
	public class ServerFeedUtil extends Object
	{
		public static function TopUserListUrl(localUserId:uint, gameId:uint, limit:uint, timeFrame:uint, userSetId:uint):String
		{
			return Environment.getApplicationUrl() + '/test/leaderboard/list?avatarId=' + localUserId.toString() + '&gameId=' + gameId.toString() + '&limit=' + limit.toString() + '&timeFrame=' + timeFrame.toString() + '&userSetId=' + userSetId.toString();
		}
		
		public static function GameListUrl():String
		{
			return Environment.getApplicationUrl() + '/test/dyn/gameInfo/list';
		}
		
		public static function AllStarHallUserList():String
		{
			return Environment.getApplicationUrl() + '/test/leaderboard/list?gameId=10&limit=14&timeFrame=4&userSetId=4';
		}
		
	}
}