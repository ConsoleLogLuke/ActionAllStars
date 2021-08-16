package com.sdg.business.resource
{
	import com.sdg.factory.IContentFactory;
	import com.sdg.utils.NetUtil;
	
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	
	/**
	 * The LoaderResource class loads and contains content obtained via flash.display.Loader.
	 */
	public class LoaderResource extends AbstractResourceLoader implements IResourceLoader
	{
		public var loaderContext:LoaderContext;
		
		protected var loader:Loader;
		
		/**
		 * Constructor.
		 */
		public function LoaderResource(info:ResourceInfo = null):void
		{
			super(info);
		}
		
		override protected function loadContent():void
		{
			loader = new Loader();
			
			var loaderInfo:LoaderInfo = loader.contentLoaderInfo;
			loaderInfo.addEventListener(Event.INIT, completeHandler); // changed from COMPLETE to test invisible avatar problem
			loaderInfo.addEventListener(Event.INIT, initHandler);
			loaderInfo.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			loaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
			loaderInfo.addEventListener(ProgressEvent.PROGRESS, progressHandler);
			
			var urlRequest:URLRequest = NetUtil.createURLRequest(info.url, info.params);
			loader.load(urlRequest, loaderContext);
		}
		
		override protected function resetContent():void
		{
			if (!loader) return;
			
			var loaderInfo:LoaderInfo = loader.contentLoaderInfo;
			loaderInfo.removeEventListener(Event.INIT, completeHandler); // changed from COMPLETE to test invisible avatar problem
			loaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			loaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
			loaderInfo.removeEventListener(ProgressEvent.PROGRESS, progressHandler);
			
			loader = null;
		}
		
		protected function completeHandler(event:Event):void
		{
			var content:Object;
			
			if (info.contentFactory is IContentFactory)
			{
				IContentFactory(info.contentFactory).setData(loader.content);
				content = info.contentFactory.createInstance();
			}
			else
			{
				content = loader.content;
			}
			
			setComplete(content);
		}
		
		protected function initHandler(e:Event):void
		{
			dispatchEvent(e);
		}
		
		protected function errorHandler(event:ErrorEvent):void
		{
			setError(event.text);
		}
		
		protected function progressHandler(event:ProgressEvent):void
		{
			setProgress(event.bytesLoaded, event.bytesTotal);
		}
	}
}