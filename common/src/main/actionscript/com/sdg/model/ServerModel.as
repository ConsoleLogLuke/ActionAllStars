package com.sdg.model
{
	public class ServerModel extends IdObject
	{
		protected var _domain:String;
		
		public function ServerModel(id:uint, name:String, domain:String)
		{
			super(id, name);
			
			_domain = domain;
		}
		
		//////////////////////
		// STATIC METHODS
		//////////////////////
		
		public static function ServerModelCollectionFromXML(serverList:XMLList):ServerModelCollection
		{
			var i:uint = 0;
			var servers:ServerModelCollection = new ServerModelCollection();
			while (serverList.server[i])
			{
				var server:ServerModel = ServerModelFromXML(serverList.server[i]);
				servers.push(server);
				
				i++;
			}
			
			return servers;
		}
		
		public static function ServerModelFromXML(serverXML:XML):ServerModel
		{
			var id:uint = (serverXML.id) ? serverXML.id : 0;
			var name:String = (serverXML.name) ? serverXML.name : '';
			var domain:String = (serverXML.domain) ? serverXML.domain : '';
			
			return new ServerModel(id, name, domain);
		}
		
		//////////////////////
		// GET/SET METHODS
		//////////////////////
		
		public function get domain():String
		{
			return _domain;
		}
		
	}
}