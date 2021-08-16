package com.sdg.leaderboard
{
	import com.sdg.leaderboard.model.TopUser;
	import com.sdg.leaderboard.model.TopUserCollection;
	
	public class LeaderboardUtil extends Object
	{
		public static function ParseTopUsers(topUserScoresXml:XML):TopUserCollection
		{
			var i:uint = 0;
			var topUsers:TopUserCollection = new TopUserCollection();
			var userList:XMLList = topUserScoresXml.topUserPointsList.users;
			if (!userList) return topUsers;
			while (userList.u[i] != null)
			{
				var user:XML = userList.u[i];
				var topUser:TopUser = ParseTopUser(user);
				topUsers.push(topUser);
				
				i++;
			}
			
			return topUsers;
		}
		
		public static function ParseTopUser(user:XML):TopUser
		{
			var id:uint = (user.@id != null) ? user.@id : 0;
			var place:uint = (user.@place != null) ? user.@place : int.MAX_VALUE;
			var name:String = (user.n != null) ? user.n : '';
			var points:int = (user.pts != null) ? user.pts : 0;
			var level:uint = (user.l > 0) ? user.l : 1;
			var teamId:uint = (user.team.@id != null) ? user.team.@id : 1;
			var teamName:String = 'Team Name';
			var color1:uint = parseInt('0x' + user.team.c[0]);
			var color2:uint = parseInt('0x' + user.team.c[1]);
			
			var topUser:TopUser = new TopUser(id, name, place, level, points, teamId, teamName, color1, color2);
			
			return topUser;
		}
		
	}
}