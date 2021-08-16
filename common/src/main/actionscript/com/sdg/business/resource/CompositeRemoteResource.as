package com.sdg.business.resource
{
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	
	public class CompositeRemoteResource extends EventDispatcher implements IRemoteResource
	{
		protected var actualResource:IRemoteResource;
		
		public function get bytesLoaded():uint
		{
			return actualResource.bytesLoaded;
		}
		
		public function get bytesTotal():uint
		{
			return actualResource.bytesTotal;
		}
		
		public function get complete():Boolean
		{
			return actualResource.complete;
		}
		
		public function get pending():Boolean
		{
			return actualResource.pending;
		}
		
		public function get content():*
		{
			return actualResource.content;
		}
		
		public function get useCache():Boolean
		{
			return actualResource.useCache;
		}
			
		public function CompositeRemoteResource(actualResource:IRemoteResource):void
		{
			this.actualResource = actualResource;
			
			actualResource.addEventListener(Event.COMPLETE, dispatchEvent, false, 0, true);
			actualResource.addEventListener(Event.CLOSE, dispatchEvent, false, 0, true);
			actualResource.addEventListener(ProgressEvent.PROGRESS, dispatchEvent, false, 0, true);
			actualResource.addEventListener(IOErrorEvent.IO_ERROR, dispatchEvent, false, 0, true);
			actualResource.addEventListener(ErrorEvent.ERROR, errorHandler, false, 0, true);
		}
		
		public function load():void
		{
			actualResource.load();
		}
		
		public function reset():void
		{
			actualResource.reset();
		}
		
		public function destroy():void
		{
			// Handle clean up.
			actualResource.removeEventListener(Event.COMPLETE, dispatchEvent);
			actualResource.removeEventListener(Event.CLOSE, dispatchEvent);
			actualResource.removeEventListener(ProgressEvent.PROGRESS, dispatchEvent);
			actualResource.removeEventListener(IOErrorEvent.IO_ERROR, dispatchEvent);
			actualResource.removeEventListener(ErrorEvent.ERROR, errorHandler);
			actualResource.reset();
			actualResource = null;
		}
		
		protected function errorHandler(event:ErrorEvent):void
		{
			if (hasEventListener(ErrorEvent.ERROR)) dispatchEvent(event);
		}
	}
}