package com.sdg.business.resource
{
	import com.sdg.collections.QuickList;
	
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	/**
	 * This singleton class basically throttles the loading of pre-composed avatar spritesheets.   
	 * If too many avatars are in a room and we try and load them all at once, we'll run
	 * out of memory because each sprite sheet (about 11 to each avatar) is huge.
	 */
	public class AvatarLoadingQueue
	{
		private static var _instance:AvatarLoadingQueue;
		private const MAX_LOADERS:int = 1;
		
		private var _loaders:QuickList = new QuickList();
		private var _waitingLoaders:QuickList = new QuickList();
		
		public function AvatarLoadingQueue()
		{
			// this is a singleton class
			if (_instance)
				throw new Error("AvatarLoadingQueue is a singleton class. Use 'AvatarLoadingQueue.getInstance()'");
		}
		
		/**
		 * Gets the instance of the AvatarLoadingQueue 
		 */
		public static function getInstance():AvatarLoadingQueue
		{
			if (_instance == null)
				_instance = new AvatarLoadingQueue();
				
			return _instance;	
		}
		
		/**
		 * adds an avatar to the queue for loading
		 */ 
		public function queueForLoading(loader:AnimationSetResourceLoader):void
		{
			if (_loaders.length < maxLoaders())
				startLoading(loader);
			else
				_waitingLoaders.push(loader);
		}
		
		protected function maxLoaders():uint
		{
			return MAX_LOADERS;
		}
		
		private function startLoading(loader:AnimationSetResourceLoader):void
		{
			// Start loading the avatar.
			
			// Keep track of the loader in an array.
			_loaders.push(loader);
			
			// Load the avatar.
			var loadDidBegin:Boolean = loader.loadAvatar(false);
			// Make sure the load was able to begin.
			if (loadDidBegin != true)
			{
				removeLoader(loader);
				return;
			}
			
			// Use a kill timer.
			// If there is no progress after a certain amount of time, remove the loader.
			var timeout:uint = 5000;
			var timer:Timer = new Timer(timeout);
			timer.addEventListener(TimerEvent.TIMER, onKillTimer);
			
			// And event listeners to loader.
			loader.addEventListener(ProgressEvent.PROGRESS, onLoaderProgress);
			
			// Start the kill timer.
			timer.start();
			
			function onLoaderProgress(e:ProgressEvent):void
			{
				// Reset the kill timer.
				timer.reset();
				timer.start();
				
				// Check if all bytes have been loaded.
				if (e.bytesLoaded > e.bytesTotal - 1)
				{
					// Remove event listener.
					loader.removeEventListener(ProgressEvent.PROGRESS, onLoaderProgress);
					
					// Kill the timer.
					timer.removeEventListener(TimerEvent.TIMER, onKillTimer);
					timer.reset();
					timer = null;
					
					// Remove loader.
					removeLoader(loader);
				}
			}
			
			function onKillTimer(e:TimerEvent):void
			{
				// If the kill timer reaches it's interval.
				
				// Kill the timer.
				timer.removeEventListener(TimerEvent.TIMER, onKillTimer);
				timer.reset();
				timer = null;
				
				// Remove loader event listener.
				loader.removeEventListener(ProgressEvent.PROGRESS, onLoaderProgress);
				
				// Remove loader.
				removeLoader(loader);
			}
		}
		
		private function removeLoader(loader:AnimationSetResourceLoader):void
		{
			// Remove the loader from the queue.
			_loaders.removeValue(loader);
			
			// Load the next avatar if necessary.
			if (_loaders.length < maxLoaders())
			{
				loader = _waitingLoaders.shift() as AnimationSetResourceLoader;
				if (loader != null) startLoading(loader);
			}
		}
		
	}
}