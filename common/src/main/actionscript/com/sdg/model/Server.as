package com.sdg.model
{

	[Bindable]
	public class Server  
	{
		
		public var serverId:uint;
		public var name:String;
		public var domain:String;
		public var port:int;
		public var failoverDomain:String;
		public var failoverPort:int;
		public var useFailover:Boolean = false;
		public var numUsers:uint;
		public var chatMode:uint;
		
		public static const ULTRA_SAFE_CHAT:uint = 2;
		public static const SAFE_CHAT:uint = 1;
		
		private static var _currentServer:Server;
		
		public static function getCurrent():Server
		{
			return _currentServer;
		}
		
		public static function getCurrentId():uint
		{
			return (_currentServer != null) ? _currentServer.serverId : null;
		}
		
		public static function setCurrentServer(currentServer:Server):void
		{
			_currentServer = currentServer;
		}
	}
}