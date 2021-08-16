package com.sdg.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.sdg.business.SdgServiceDelegate;
	import com.sdg.events.ServerListEvent;
	import com.sdg.model.ModelLocator;
	import com.sdg.model.Server;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.IResponder;
	import com.adobe.cairngorm.control.CairngormEventDispatcher;
	
	public class ServerListCommand extends AbstractResponderCommand implements ICommand, IResponder
	{	
		
		public function execute(event:CairngormEvent):void
		{
			var ev:ServerListEvent = event as ServerListEvent;
		
			new SdgServiceDelegate(this).getServers();
		}
		
		public function result(data:Object):void
		{
			var servers:ArrayCollection = ModelLocator.getInstance().servers;
			servers.removeAll();
			
			for each (var item:XML in data.servers.children())
			{
				var s:Server = new Server();
				s.serverId = item.serverId;
				s.name = item.name;
				s.domain = item.primaryServer.address;
				s.port = item.primaryServer.port;
				s.failoverDomain = item.primaryServer.failoverAddress;
				s.failoverPort = item.primaryServer.failoverPort;
				s.numUsers = item.numUsers;
				s.chatMode = item.chatPolicyId;
				servers.addItem(s);
			}
			
			//for testing purpose only
//			for (var i:int=102; i<110; i++)
//			{
//				var s:Server = new Server();
//				s.serverId = i;
//				s.name = "testServer "+ i;
//				s.domain = "66.166.6.139";
//				s.port = 9898;
//				servers.addItem(s);
//			}
			
			// dispatch a "listCompleted" event
			CairngormEventDispatcher.getInstance().dispatchEvent(
				new ServerListEvent(ServerListEvent.LIST_COMPLETED, data.servers.@isAfterHours == "true"));
		}
	}
}