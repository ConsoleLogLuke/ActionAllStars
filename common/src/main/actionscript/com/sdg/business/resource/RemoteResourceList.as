package com.sdg.business.resource
{
	import com.sdg.collections.QuickList;
	
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	public class RemoteResourceList extends AbstractResourceContainer implements IRemoteResource
	{
		protected var resources:QuickList = new QuickList();
		
		public function get numResources():uint
		{
			return resources.length;
		}
		
		public function RemoteResourceList():void
		{
		}
		
		public function addResource(resource:IRemoteResource):void
		{
			if (contains(resource)) removeResource(resources.indexOf(resource));
			
			resources.push(resource);
			addLoadable(resource);
		}
		
		public function insertResource(index:int, resource:IRemoteResource):void
		{
			if (contains(resource)) removeResource(resources.indexOf(resource));
			
			if (index > resources.length)
				throw new ArgumentError("Argument 'index' " + index + " is out of range.");
				
			resources.splice(index, resource);
			addLoadable(resource);
		}
		
		public function setResource(index:int, resource:IRemoteResource):void
		{
			if (resources[index]) removeResource(resources[index]);
			insertResource(index, resource);
		}
		
		public function getContent(index:int):*
		{
			var resource:IRemoteResource = resources[index];
			if (resource) return resource.content;
		}
		
		public function getAllContents():Array
		{
			var list:Array = [];
			
			for each (var resource:IRemoteResource in resources)
				list.push(resource.content);
			
			return list;
		}
		
		public function getResource(index:int):IRemoteResource
		{
			return resources[index];
		}
		
		public function getAllResources():Array
		{
			return resources.slice();
		}
		
		public function removeResource(index:int):IRemoteResource
		{
			var resource:IRemoteResource = resources.remove(index);
			removeLoadable(resource);
			return resource;
		}
		
		public function removeAll():void
		{
			removeAllLoadable();
			resources.length = 0;
		}
		
		override protected function loadContent():void
		{
			for each (var resource:IRemoteResource in resources)
				resource.load();
		}
		
		override protected function resetContent():void
		{
			resources.length = 0;
		}
	}
}