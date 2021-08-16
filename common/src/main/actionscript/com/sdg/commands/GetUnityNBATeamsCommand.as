package com.sdg.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.adobe.cairngorm.control.CairngormEventDispatcher;
	import com.sdg.business.SdgServiceDelegate;
	import com.sdg.events.GetUnityNBATeamsEvent;
	import com.sdg.model.ModelLocator;
	
	import mx.rpc.IResponder;
	
	public class GetUnityNBATeamsCommand implements ICommand, IResponder
	{
		public function execute(event:CairngormEvent):void
		{
			new SdgServiceDelegate(this).getUnityNBATeams(ModelLocator.getInstance().avatar.avatarId);
		}
		
		public function result(data:Object):void
		{
			returnEvent(data);
		}
		
		public function fault(info:Object):void
		{
			returnEvent();
		}
		
		private function returnEvent(returnObj:Object = null):void
		{
			CairngormEventDispatcher.getInstance().dispatchEvent(new GetUnityNBATeamsEvent(GetUnityNBATeamsEvent.UNITY_NBA_TEAMS_RETURNED, returnObj)); 
		}
	}
}
