package com.sdg.events
{	
	import com.adobe.cairngorm.control.CairngormEvent;

	public class SaveFavTeamsEvent extends CairngormEvent
	{
		public static const SAVE_FAV_TEAM:String = "save fav team";
		
		public var params:Object;
		
		public function SaveFavTeamsEvent(params:Object)
		{
			super(SAVE_FAV_TEAM);
			this.params = params;
		}
	}
}