package com.sdg.business.resource
{
	import com.sdg.factory.IObjectFactory;
	
	public class ResourceInfo
	{
		public var url:String;
		public var params:Object;
		public var estimatedBytesTotal:uint;
		public var contentFactory:IObjectFactory;
		public var useCache:Boolean;
		
		public function ResourceInfo(url:String = null, params:Object = null, estimatedBytesTotal:uint = 1000, 
									 contentFactory:IObjectFactory = null, useCache:Boolean = false)
		{
			this.url = url;
			this.params = params;
			this.estimatedBytesTotal = estimatedBytesTotal;
			this.contentFactory = contentFactory;
			this.useCache = useCache;
		}
		
		public function clone():ResourceInfo
		{
			return new ResourceInfo(url, params, estimatedBytesTotal, contentFactory, useCache);
		}
	}
}