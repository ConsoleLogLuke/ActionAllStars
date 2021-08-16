package com.sdg.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.adobe.cairngorm.control.CairngormEventDispatcher;
	import com.sdg.business.SdgServiceDelegate;
	import com.sdg.events.GetFavTeamsEvent;
	import com.sdg.events.SaveFavTeamsEvent;
	import com.sdg.model.ModelLocator;
	
	import mx.rpc.IResponder;
		
	public class SaveFavTeamsCommand extends AbstractResponderCommand implements ICommand, IResponder
	{
		private var avatarId:int;
		
		public function execute(event:CairngormEvent):void
		{
			avatarId = ModelLocator.getInstance().avatar.avatarId;
			
			var ev:SaveFavTeamsEvent = event as SaveFavTeamsEvent;
			new SdgServiceDelegate(this).saveFavTeams(avatarId, ev.params);
		}
		
		public function result(data:Object):void
		{
			CairngormEventDispatcher.getInstance().dispatchEvent(new GetFavTeamsEvent(avatarId));
		}
	}
}