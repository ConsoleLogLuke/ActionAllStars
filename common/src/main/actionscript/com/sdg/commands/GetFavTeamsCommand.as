package com.sdg.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.sdg.business.SdgServiceDelegate;
	import com.sdg.events.GetFavTeamsEvent;
	import com.sdg.model.Avatar;
	import com.sdg.model.ModelLocator;
	import com.sdg.model.Team;
	
	import mx.rpc.IResponder;
		
	public class GetFavTeamsCommand extends AbstractResponderCommand implements ICommand, IResponder
	{
		public function execute(event:CairngormEvent):void
		{
			var ev:GetFavTeamsEvent = event as GetFavTeamsEvent;
			new SdgServiceDelegate(this).getFavTeams(ev.avatarId);
		}
		
		public function result(data:Object):void
		{
			var avatar:Avatar = ModelLocator.getInstance().avatar;
			var favoriteLeagueId:int;
			
			for each (var teamXml:XML in data.team)
			{
				var teamId:uint = teamXml.@teamId;
				var teamName:String = teamXml.@teamName;
				var cityName:String = teamXml.@cityName;
				var leagueId:uint = teamXml.@leagueId;
				
				var color1:uint;
				var color2:uint;
				var color3:uint;
				var color4:uint;
				
				if (teamXml.teamColor.c[0] != undefined)
					color1 = uint("0x" +  teamXml.teamColor.c[0]);
				
				if (teamXml.teamColor.c[1] != undefined)
					color2 = uint("0x" +  teamXml.teamColor.c[1]);
				
				if (teamXml.teamColor.c[2] != undefined)
					color3 = uint("0x" +  teamXml.teamColor.c[2]);
				
				if (teamXml.teamColor.c[3] != undefined)
					color4 = uint("0x" +  teamXml.teamColor.c[3]);
				
				if (teamXml.@primaryFlag == 1)
					favoriteLeagueId = leagueId;
				
				var team:Team = new Team(teamId, teamName, cityName, leagueId, color1, color2, color3, color4);
				
				avatar.setFavoriteTeam(team, leagueId);
			}
			
			avatar.favoriteLeagueId = favoriteLeagueId;
		}
	}
}