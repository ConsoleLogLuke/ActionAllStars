package com.sdg.business.resource
{
	import com.sdg.collections.QuickMap;
	
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	public class RemoteResourceMap extends AbstractResourceContainer implements IRemoteResource
	{
		protected var resources:QuickMap = new QuickMap();
		
		public function get numResources():uint
		{
			return progressMonitor.sourcesTotal;
		}
		
		public function RemoteResourceMap():void
		{
		}
		
		public function setResource(key:Object, resource:IRemoteResource):void
		{
			if (resources[key] != resource)
			{
				if (contains(resource)) removeResource(resources.getKey(resource));
				if (resources[key]) removeResource(key);
			
				resources[key] = resource;
				addLoadable(resource);
			}
		}
		
		public function getContent(key:Object):*
		{
			var resource:IRemoteResource = resources[key];
			if (resource) return resource.content;
		}
		
		public function getAllContents():Array
		{
			var list:Array = [];
			
			for (var key:Object in resources)
				list.push(getContent(key));
			
			return list;
		}
		
		public function getResource(key:Object):IRemoteResource
		{
			return resources[key];
		}
		
		public function getAllResources():Array
		{
			return resources.toArray();
		}
		
		public function removeResource(key:Object):IRemoteResource
		{
			var resource:IRemoteResource = resources.remove(key);
			if (resource) removeLoadable(resource);
			return resource;
		}
		
		public function removeAll():void
		{
			removeAllLoadable();
			resources = new QuickMap();
		}
		
		override protected function loadContent():void
		{
			for each (var resource:IRemoteResource in resources)
				resource.load();
		}
		
		override protected function resetContent():void
		{
			resources = new QuickMap();
		}
	}
}