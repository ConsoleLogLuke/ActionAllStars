package com.sdg.business.resource
{
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	public class RemoteResourceLocator
	{
		private var resourceFactories:Object = {};
		private var resourceKeyMap:Dictionary = new Dictionary(true);
		private var resources:Object = {};
		
		public function RemoteResourceLocator():void
		{
		}
		
		public function setResourceFactory(type:String, generator:Object, bytesTotal:uint = 1000, contentFactory:Object = null, useCache:Boolean = false):void
		{
			resourceFactories[type] = { generator:generator, bytesTotal:bytesTotal, contentFactory:contentFactory, useCache:useCache };
		}
		
		public function getResource(type:String, url:String = null, params:Object = null):IRemoteResource
		{
			var key:String = getResourceKey(type, url, params);
			var resource:IRemoteResource = resources[key];
			
			if (!resource)
			{
				resource = createResource(type, url, params);
				
				if (resource.useCache)
				{
					resources[key] = resource;
					resourceKeyMap[resource] = key;
				}
			}
			
			return resource;
		}
		
		public function createResource(type:String, url:String, params:Object = null):IRemoteResource
		{
			var f:Object = resourceFactories[type];
			if (!f) throw new Error("Factory not found for resource 'type' [" + type + "].");
			
			var info:ResourceInfo = new ResourceInfo(url, params, f.bytesTotal, f.contentFactory, f.useCache);
			var resource:IRemoteResource;
			
			if (f.generator is Class)
			{
				resource = new f.generator();
				if (resource is IResourceLoader) IResourceLoader(resource).info = info;
			}
			else if (f.generator is Function)
			{
				resource = f.generator(info);
			}
			
			return resource;
		}
		
		public function removeResource(resource:IRemoteResource):void
		{
			var key:String = resourceKeyMap[resource];
			if (key) delete resources[key];
		}
		
		protected function getResourceKey(type:String, url:String, params:Object):String
		{
			var key:String = type + '_' + url;
			
			if (params)
			{
				for (var name:String in params)
					key += '_' + name + '=' + String(params[name]);
			}
			
			return key;
		}
	}
}