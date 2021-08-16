package com.sdg.business.resource
{
	import com.sdg.factory.IContentFactory;
	
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	
	/**
	 * The AbstractRemoteResource class provides implementations of
	 * IRemoteResource with commonly used methods and accessors for managing
	 * a single loadable resource.
	 */
	public class AbstractResourceLoader extends EventDispatcher
	{
		public static const STATUS_INIT:int			 = 0;
		public static const STATUS_RESET:int		 = 1;
		public static const STATUS_LOADING:int		 = 2;
		public static const STATUS_COMPLETE:int		 = 3;
		public static const STATUS_ERROR:int		 = 4;
		
		private var _bytesLoaded:uint;
		private var _bytesTotal:uint;
		private var _content:*;
		private var _info:ResourceInfo;
		private var _status:uint = STATUS_RESET;
		
		public function get bytesLoaded():uint
		{
			return _bytesLoaded;
		}
		
		public function get bytesTotal():uint
		{
			return _bytesTotal;
		}
		
		public function get complete():Boolean
		{
			return _status == STATUS_COMPLETE;
		}
		
		public function get pending():Boolean
		{
			return _status == STATUS_LOADING;
		}
		
		public function get content():*
		{
			return _content;
		}
		
		public function get info():ResourceInfo
		{
			return (_info) ? _info.clone() : null;
		}
		
		public function set info(value:ResourceInfo):void
		{
			if (_info != null)
				throw new Error("Unable to set 'info' because it already exists.");
			
			_info = value;
			reset();
		}
		
		public function get useCache():Boolean
		{
			return (_info) ? _info.useCache : false;
		}
		
		/**
		 * Constructor.
		 *
		 * @param info
		 */
		public function AbstractResourceLoader(info:ResourceInfo = null):void
		{
			_info = info;
		}
		
		/**
		 * Loads the content. Ignored if already loading or loading is complete.
		 */
		public function load():void
		{
			if (_status == STATUS_RESET)
			{
				setProgress(0, _info.estimatedBytesTotal);
				_status = STATUS_LOADING;
				loadContent();
			}
		}
		
		/**
		 * Clears the content and updates the current progress.
		 */
		public function reset():void
		{
			var status:uint = _status;
			
			if (_info)
			{
				_status = STATUS_RESET;
				setProgress(0, _info.estimatedBytesTotal);
			}
			else if (_status != STATUS_INIT)
			{
				_status = STATUS_INIT;
				setProgress(0, 0);
			}
			
			if (status > STATUS_RESET)
			{
				resetContent();
				_content = null;
				
				if (status == STATUS_LOADING) dispatchEvent(new Event(Event.CLOSE));
			}
		}
		
		protected function loadContent():void
		{
			// Override this method to load content.
		}
		
		protected function resetContent():void
		{
			// Override this method to reset content.
		}
		
		protected function setComplete(content:*):void
		{
			_content = content;
			_status = STATUS_COMPLETE;
			
			dispatchEvent(new Event(Event.COMPLETE));
			dispatchEvent(new Event(Event.CLOSE));
		}
		
		protected function setError(text:String = ""):void
		{
			_status = STATUS_RESET;
			
			if (hasEventListener(ErrorEvent.ERROR))
				dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, text));
			else
				trace("RemoteResource Error: " + text);
				
			dispatchEvent(new Event(Event.CLOSE));
		}
		
		protected function setProgress(bytesLoaded:uint, bytesTotal:uint):void
		{
			_bytesLoaded = bytesLoaded;
			_bytesTotal = bytesTotal;
			
			dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, false, false, bytesLoaded, bytesTotal));
		}
	}
}