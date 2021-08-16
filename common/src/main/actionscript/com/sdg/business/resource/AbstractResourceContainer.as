package com.sdg.business.resource
{
	import com.sdg.factory.IContentFactory;
	import com.sdg.factory.IObjectFactory;
	import com.sdg.utils.ProgressMonitor;
	
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	public class AbstractResourceContainer extends EventDispatcher
	{
		protected var progressMonitor:ProgressMonitor;
		
		private var _content:*;
		private var _contentFactory:IObjectFactory;
		
		public function get bytesLoaded():uint
		{
			return progressMonitor.bytesLoaded;
		}
		
		public function get bytesTotal():uint
		{
			return progressMonitor.bytesTotal;
		}
		
		public function get complete():Boolean
		{
			return progressMonitor.complete;
		}
		
		public function get pending():Boolean
		{
			return progressMonitor.pending;
		}
		
		public function get content():*
		{
			return _content;
		}
		
		public function get contentFactory():IObjectFactory
		{
			return _contentFactory;
		}
		
		public function set contentFactory(value:IObjectFactory):void
		{
			_contentFactory = value;
		}
		
		public function get useCache():Boolean
		{
			return false;
		}
		
		public function AbstractResourceContainer():void
		{
			progressMonitor = new ProgressMonitor(this);
			progressMonitor.stop();
			
			addEventListener(Event.COMPLETE, completeHandler, false);
		}
		
		public function contains(resource:IRemoteResource):Boolean
		{
			return progressMonitor.contains(resource);
		}
		
		protected function addLoadable(resource:IRemoteResource):void
		{
			progressMonitor.addSource(resource);
			resource.addEventListener(ErrorEvent.ERROR, resourceErrorHandler, false, 0, true);
			if (pending) resource.load();
		}
		
		protected function removeLoadable(resource:IRemoteResource):void
		{
			progressMonitor.removeSource(resource);
			resource.removeEventListener(ErrorEvent.ERROR, resourceErrorHandler);
		}
		
		protected function removeAllLoadable():void
		{
			progressMonitor.stop();
			progressMonitor.removeAllSources();
		}
		
		public function load():void
		{
			_content = null;
			progressMonitor.start();
			loadContent();
		}
		
		public function reset():void
		{
			_content = null;
			removeAllLoadable();
			resetContent();
			
			if (pending) dispatchEvent(new Event(Event.CLOSE));
		}
		
		protected function loadContent():void
		{
			
		}
		
		protected function resetContent():void
		{
			
		}
		
		protected function completeHandler(event:Event):void
		{
			progressMonitor.stop();
			
			var factory:IContentFactory = _contentFactory as IContentFactory;
			
			if (factory)
			{
				factory.setData(this);
				_content = factory.createInstance();
			}
			
			dispatchEvent(new Event(Event.CLOSE));
		}
		
		protected function resourceErrorHandler(event:ErrorEvent):void
		{
			if (!pending || !progressMonitor.contains(event.target)) return;
			
			progressMonitor.stop();
			
			if (hasEventListener(ErrorEvent.ERROR)) dispatchEvent(event);
			
			dispatchEvent(new Event(Event.CLOSE));
		}
	}
}