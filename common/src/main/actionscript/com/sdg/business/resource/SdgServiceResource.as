package com.sdg.business.resource
{
	import com.adobe.cairngorm.business.ServiceLocator;
	
	import com.sdg.business.SdgServiceResponder;
	import com.sdg.factory.IXMLObjectFactory;
	
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	
	import mx.rpc.AsyncToken;
	import mx.rpc.http.HTTPService;
	
	/**
	 * The SdgServiceResource class requests and contains SDG HTTP data.
	 */
	public class SdgServiceResource extends AbstractResourceLoader implements IResourceLoader
	{
		/**
		 * Constructor.
		 */
		public function SdgServiceResource(info:ResourceInfo = null):void
		{
			super(info);
		}
		
		override protected function loadContent():void
		{
			var responder:SdgServiceResponder = new SdgServiceResponder(resultHandler, faultHandler, info.contentFactory as IXMLObjectFactory);
			var service:HTTPService = ServiceLocator.getInstance().getHTTPService(info.url);
			var token:AsyncToken = service.send(info.params);
			
			token.addResponder(responder);
		}
		
		protected function resultHandler(data:Object, key:Object):void
		{
			if (pending)
			{
				setProgress(bytesTotal, bytesTotal);
				setComplete(data);
			}
		}
		
		protected function faultHandler(info:Object, key:Object):void
		{
			if (pending)
			{
				setError("SdgServiceResource Error: url=" + info.url + ", status=" + info.@status);
			}
		}
	}
}