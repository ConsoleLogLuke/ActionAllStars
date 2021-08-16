package com.sdg.net
{
	import com.sdg.events.LoaderQueEvent;
	import com.sdg.model.URLRequestCollection;
	
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;
	import flash.net.URLRequest;
	import flash.utils.Timer;

	public class LoaderQue extends EventDispatcher
	{
		private static const KILL_CURRENT_LOADERS:String = 'kill current loaders';
		
		protected var _maxConcurrentLoads:uint;
		protected var _maxProgressDelay:uint;
		protected var _maxRetry:uint;
		protected var _autoStart:Boolean;
		protected var _isRunning:Boolean;
		protected var _concurrentLoads:uint;
		protected var _requestQue:URLRequestCollection;
		protected var _traceDebug:Boolean;
		
		public function LoaderQue(maxConcurrentLoads:uint = 1, maxProgressDelay:uint = 3000, maxRetry:uint = 0, autoStart:Boolean = false)
		{
			super();
			
			_maxConcurrentLoads = maxConcurrentLoads;
			_maxProgressDelay = maxProgressDelay;
			_maxRetry = maxRetry;
			_autoStart = autoStart;
			_isRunning = _autoStart;
			_concurrentLoads = 0;
			_requestQue = new URLRequestCollection();
			_traceDebug = false;
		}
		
		////////////////////
		// INSTANCE METHODS
		////////////////////
		
		public function start():void
		{
			_isRunning = true;
			
			// Debug.
			if (_traceDebug) trace('LoaderQue: Started. ' + _requestQue.length + ' requests in que.');
			
			checkRequestQue();
		}
		
		public function stop():void
		{
			_isRunning = false;
			
			// Debug.
			if (_traceDebug) trace('LoaderQue: Stoped. ' + _requestQue.length + ' requests in que.');
		}
		
		public function clear(killCurrentLoaders:Boolean = false):void
		{
			// Empty the request que.
			_requestQue.empty();
			
			// If specified, kill current loaders.
			if (killCurrentLoaders == true) dispatchEvent(new Event(KILL_CURRENT_LOADERS));
			
			// Debug.
			if (_traceDebug) trace('LoaderQue: Cleared. Request que is empty.');
		}
		
		public function addRequest(request:URLRequest):void
		{
			// Add the request to the que.
			_requestQue.push(request);
			
			// Debug.
			if (_traceDebug) trace('LoaderQue: Request added. ' + _requestQue.length + ' requests in que.');
			
			// Check the que.
			if (_isRunning) checkRequestQue();
		}
		
		protected function checkRequestQue():Boolean
		{
			// Check if we can begin loading another request.
			if (_concurrentLoads < _maxConcurrentLoads && _requestQue.length > 0)
			{
				// Load the next request in the que.
				var request:URLRequest = _requestQue.shift();
				loadRequest(request);
				return true;
			}
			
			return false;
		}
		
		protected function loadRequest(request:URLRequest):void
		{
			// Begin loading this request.
			// Increment concurrent loads.
			// Listen for load related events and propegate events as necessary.
			_concurrentLoads++;
			
			// Keep track of how many times we try to load this request.
			var retryCount:uint = 0;
			
			// Keep track of bytes loaded.
			var bytesLoaded:uint = 0;
			var bytesTotal:uint = 1;
			
			// Use a timer to keep track of the delay between progress events.
			var progressTimer:Timer = new Timer(_maxProgressDelay);
			progressTimer.addEventListener(TimerEvent.TIMER, onProgressTimerInterval);
			
			// First attempt to load the request.
			var loader:Loader;
			tryLoad();
			
			function tryLoad():void
			{
				// Debug.
				if (_traceDebug) trace('LoaderQue: Loading request.\n' +
						'\tUrl: ' + request.url + '\n' +
						'\tRetry count: ' + retryCount + '\n' +
						'\tConcurrent loads: ' + _concurrentLoads + '\n' +
						'\tRequests in que: ' + _requestQue.length + '\n'
						);
				
				// Attempt to load the request.
				loader = new Loader();
				loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onProgress);
				loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
				progressTimer.reset();
				progressTimer.start();
				loader.load(request);
				// Listen for event to stop loading.
				addEventListener(KILL_CURRENT_LOADERS, killCurrentLoaders);
			}
			
			function onProgress(e:ProgressEvent):void
			{
				// Restart progress timer.
				progressTimer.reset();
				progressTimer.start();
				
				// Update bytes loaded.
				bytesLoaded = e.bytesLoaded;
				bytesTotal = e.bytesTotal;
				
				// Dispatch event.
				dispatchEvent(new LoaderQueEvent(LoaderQueEvent.PROGRESS, loader, bytesLoaded, bytesTotal));
			}
			
			function onError(e:IOErrorEvent):void
			{
				// Remove event listeners.
				removeListeners();
				
				// Debug.
				if (_traceDebug) trace('LoaderQue: Load error.\n' +
						'\tUrl: ' + request.url + '\n' +
						'\tRetry count: ' + retryCount + '\n' +
						'\tConcurrent loads: ' + _concurrentLoads + '\n' +
						'\tRequests in que: ' + _requestQue.length + '\n'
						);
				
				// There was an error loading the request.
				error();
			}
			
			function onComplete(e:Event):void
			{
				// Remove event listeners.
				removeListeners();
				
				// Debug.
				if (_traceDebug) trace('LoaderQue: Load successful.\n' +
						'\tUrl: ' + request.url + '\n' +
						'\tRetry count: ' + retryCount + '\n' +
						'\tConcurrent loads: ' + _concurrentLoads + '\n' +
						'\tRequests in que: ' + _requestQue.length + '\n'
						);
				
				// Dispatch event.
				dispatchEvent(new LoaderQueEvent(LoaderQueEvent.COMPLETE, loader, bytesLoaded, bytesTotal));
				
				// End the load process.
				endLoad();
			}
			
			function onProgressTimerInterval(e:TimerEvent):void
			{
				// The loader has not progressed for too long.
				// We'll consider this an error.
				
				// Remove event listeners.
				removeListeners();
				
				// Reset the progress timer.
				progressTimer.reset();
				
				// There was an error loading the request.
				error();
			}
			
			function removeListeners():void
			{
				// Remove event listeners.
				removeEventListener(KILL_CURRENT_LOADERS, killCurrentLoaders);
				loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, onProgress);
				loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onError);
				loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onComplete);
			}
			
			function error():void
			{
				// Check if we can retry the load.
				if (checkRetry() == true)
				{
					// The load is being tried again.
				}
				else
				{
					// Unable to load this request.
					// Dispatch event.
					dispatchEvent(new LoaderQueEvent(LoaderQueEvent.ERROR, loader, bytesLoaded, bytesTotal));
					
					// End the load process.
					endLoad();
				}
			}
			
			function checkRetry():Boolean
			{
				// Check if we should try to load this request again.
				// Return TRUE if we try again.
				if (_isRunning == true && retryCount < _maxRetry)
				{
					// Retry.
					retryCount++;
					tryLoad();
					return true;
				}
				
				return false;
			}
			
			function endLoad():void
			{
				// Kill progress timer.
				progressTimer.removeEventListener(TimerEvent.TIMER, onProgressTimerInterval);
				progressTimer.reset();
				
				// Remove refrence to loader.
				loader = null;
				
				// Decrement concurrent loads.
				_concurrentLoads--;
				
				// Debug.
				if (_traceDebug) trace('LoaderQue: Load ended.\n' +
						'\tUrl: ' + request.url + '\n' +
						'\tRetry count: ' + retryCount + '\n' +
						'\tConcurrent loads: ' + _concurrentLoads + '\n' +
						'\tRequests in que: ' + _requestQue.length + '\n'
						);
				
				// If running, check que for more requests to load.
				var isMoreRequests:Boolean = true;
				if (_isRunning == true) isMoreRequests = checkRequestQue();
				
				// If there are no more requests to load, dispatch an event.
				if (isMoreRequests == false) dispatchEvent(new LoaderQueEvent(LoaderQueEvent.EMPTY, loader, bytesLoaded, bytesTotal));
			}
			
			function killCurrentLoaders(e:Event):void
			{
				// Kill all current loaders.
				// Make sure this is only called on loaders that are currently loading data.
				if (loader.loaderInfo != null && loader.loaderInfo.bytesLoaded < loader.loaderInfo.bytesTotal) loader.close();
				// Remove event listeners.
				removeListeners();
				endLoad();
			}
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		public function get traceDebug():Boolean
		{
			return _traceDebug;
		}
		public function set traceDebug(value:Boolean):void
		{
			_traceDebug = value;
		}
		
	}
}