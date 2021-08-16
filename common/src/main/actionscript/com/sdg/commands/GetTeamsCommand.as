package com.sdg.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.adobe.cairngorm.control.CairngormEventDispatcher;
	import com.sdg.business.SdgServiceDelegate;
	import com.sdg.events.GetTeamsEvent;
	import com.sdg.model.ModelLocator;
	
	import mx.rpc.IResponder;
	
	public class GetTeamsCommand implements ICommand, IResponder
	{
		private var _event:GetTeamsEvent;
		
		public function execute(event:CairngormEvent):void
		{
			_event = event as GetTeamsEvent;
			new SdgServiceDelegate(this).getGameTeams(ModelLocator.getInstance().avatar.avatarId, _event.getOwned);
		}
		
		public function result(data:Object):void
		{
			CairngormEventDispatcher.getInstance().dispatchEvent(new GetTeamsEvent(GetTeamsEvent.TEAMS_RECEIVED, _event.getOwned, data.rbiTeams));
		}
		
		public function fault(info:Object):void
		{
			CairngormEventDispatcher.getInstance().dispatchEvent(new GetTeamsEvent(GetTeamsEvent.GET_TEAMS_ERROR, _event.getOwned));
		}
	}
}