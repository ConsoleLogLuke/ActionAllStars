package com.sdg.events
{	
	import com.adobe.cairngorm.control.CairngormEvent;

	public class GetFavTeamsEvent extends CairngormEvent
	{
		public static const GET_FAV_TEAM:String = "get fav team";
		
		public var avatarId:int;
		
		public function GetFavTeamsEvent(avatarId:int)
		{
			super(GET_FAV_TEAM);
			this.avatarId = avatarId;
		}
	}
}