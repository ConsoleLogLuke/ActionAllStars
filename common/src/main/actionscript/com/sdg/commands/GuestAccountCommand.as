package com.sdg.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.adobe.cairngorm.control.CairngormEventDispatcher;
	import com.sdg.business.SdgServiceDelegate;
	import com.sdg.events.GuestAccountEvent;
	import com.sdg.events.LoginEvent;
	import com.sdg.model.Avatar;
	import com.sdg.model.ModelLocator;
	import com.sdg.model.Server;
	
	import mx.rpc.IResponder;
	
	public class GuestAccountCommand implements ICommand, IResponder
	{
		private var _event:GuestAccountEvent;
		
		public function execute(event:CairngormEvent):void
		{
			_event = event as GuestAccountEvent;
			new SdgServiceDelegate(this).makeGuestAccount(_event.avatar, ModelLocator.getInstance().affiliate);
		}
		
		public function result(data:Object):void
		{
			var s:Server = new Server();
			var serverXml:XMLList = data.servers.server;
			
			s.serverId = serverXml.serverId;
			s.name = serverXml.name;
			s.domain = serverXml.primaryServer.address;
			s.port = serverXml.primaryServer.port;
			s.failoverDomain = serverXml.primaryServer.failoverAddress;
			s.failoverPort = serverXml.primaryServer.failoverPort;
			s.numUsers = serverXml.numUsers;
			s.chatMode = serverXml.chatPolicyId;
			Server.setCurrentServer(s);
			
//			s.serverId = 102;
//			s.name = "Wood";
//			s.domain = "192.168.0.222";
//			s.port = 9898;
//			s.numUsers = 0;
//			s.chatMode = 2;
//			Server.setCurrentServer(s);
			
			ModelLocator.getInstance().avatar = new Avatar();
			CairngormEventDispatcher.getInstance().dispatchEvent(new LoginEvent(data.@userName, data.@password));
		}
		
		public function fault(info:Object):void
		{
			CairngormEventDispatcher.getInstance().dispatchEvent(new GuestAccountEvent(null, GuestAccountEvent.REENABLE_BUTTON));
		}
	}
}