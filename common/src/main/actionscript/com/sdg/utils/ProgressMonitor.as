package com.sdg.utils
{
	import com.sdg.core.IntervalManager;
	import com.sdg.core.IntervalType;
	import com.sdg.core.IProgressInfo;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	[Event(name="complete", type="flash.events.Event")]
	[Event(name="progress", type="flash.events.ProgressEvent")]
	
	public class ProgressMonitor extends EventDispatcher implements IProgressInfo
	{
		public static const DISPATCH_COMPLETE_INTERVAL:int = 1;
		public static const DISPATCH_PROGRESS_INTERVAL:int = 20;
		
		private var _bytesLoaded:uint;
		private var _bytesTotal:uint;
		private var _dispatcher:IEventDispatcher;
		private var _isRunning:Boolean = true;
		private var _progressMap:Dictionary = new Dictionary();
		private var _progressUpdateTime:uint;
		private var _progressTimer:Timer;
		private var _sourcesPending:uint;
		private var _sourcesTotal:uint;
		
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
			return _sourcesPending == 0 && _sourcesTotal > 0;
		}
		
		public function get pending():Boolean
		{
			return _isRunning && _sourcesPending > 0;
		}
		
		public function get isRunning():Boolean
		{
			return _isRunning;
		}
		
		public function get sourcesPending():uint
		{
			return _sourcesPending;
		}
		
		public function get sourcesTotal():uint
		{
			return _sourcesTotal;
		}
		
		public function ProgressMonitor(dispatcher:IEventDispatcher = null):void
		{
			_dispatcher = (dispatcher) ? dispatcher : this;
			super(_dispatcher);
			
			_progressTimer = new Timer(DISPATCH_PROGRESS_INTERVAL, 1);
			_progressTimer.addEventListener(TimerEvent.TIMER_COMPLETE, dispatchProgress);
		}
		
		public function addSource(source:IEventDispatcher, estimatedBytesTotal:uint = 0):void
		{
			if (!_progressMap[source])
			{
				var bytes:Number;
				var complete:Boolean;
				var progress:Progress = new Progress();
				var sourceObj:Object = Object(source);
				
				_progressMap[source] = progress;
				_sourcesPending++;
				_sourcesTotal++;
				
				addSourceListeners(source);
				
				if (source is IProgressInfo)
				{
					progress.bytesLoaded = sourceObj.bytesLoaded;
					progress.bytesTotal = sourceObj.bytesTotal;
					complete = sourceObj.complete;
				}
				else
				{
					// Check for bytesLoaded property.
					if (sourceObj.hasOwnProperty('bytesLoaded'))
					{
						bytes = sourceObj.bytesLoaded;

						if (!isNaN(bytes)) progress.bytesLoaded = bytes;
					}

					// Check for bytesTotal property.
					if (sourceObj.hasOwnProperty('bytesTotal'))
					{
						bytes = sourceObj.bytesTotal;

						if (!isNaN(bytes)) progress.bytesTotal = bytes;
					}

					complete = progress.bytesTotal > 0 && progress.bytesLoaded == progress.bytesTotal;
				}

				if (!complete && progress.bytesTotal == 0) progress.bytesTotal = estimatedBytesTotal;

				updateProgress(progress.bytesLoaded, progress.bytesTotal);

				// Check if source is already complete.
				if (complete) setProgressComplete(progress);
			}
		}
		
		public function contains(source:Object):Boolean
		{
			return _progressMap[source] != null;
		}
		
		public function removeSource(source:Object):void
		{
			var progress:Progress = _progressMap[source];
			
			if (progress)
			{
				_sourcesTotal--;
				
				updateProgress(-progress.bytesLoaded, -progress.bytesTotal);
				setProgressComplete(progress);
				removeSourceListeners(source);
				delete _progressMap[source];
			}
		}
		
		public function removeAllSources():void
		{
			for (var source:Object in _progressMap)
			{
				removeSourceListeners(IEventDispatcher(source));
			}
			
			_bytesLoaded = _bytesTotal = _sourcesPending = _sourcesTotal = 0;
			_progressMap = new Dictionary();
			_progressTimer.reset();
			IntervalManager.removeIntervalListener(dispatchComplete);
			
			if (!_isRunning) dispatchProgress();
		}

		public function start():void
		{
			_isRunning = true;
			
			if (complete)
				dispatchComplete();
			else
				dispatchProgress();
		}
		
		public function stop():void
		{
			_isRunning = false;
			_progressTimer.stop();
		}
		
		public function setSourceComplete(source:Object):void
		{
			if (_progressMap[source]) setProgressComplete(_progressMap[source]);
		}
		
		public function setSourcePending(source:Object):void
		{
			var progress:Progress = _progressMap[source];
			
			if (progress && progress.complete)
			{
				updateProgress(-progress.bytesLoaded, 0);
				progress.bytesLoaded = 0;
				progress.complete = false;
				_sourcesPending++;
			}
		}
		
		private function setProgressComplete(progress:Progress):void
		{
			if (!progress.complete)
			{
				progress.complete = true;
				_sourcesPending--;
				
				if (_sourcesPending == 0)
				{
					queueDispatchComplete();
				}
			}
		}
		
		private function updateProgress(bytesLoaded:int, bytesTotal:int):void
		{
			// Add bytes to total.
			_bytesLoaded += bytesLoaded;
			_bytesTotal += bytesTotal;
		}
		
		private function queueDispatchComplete():void
		{
			if (!IntervalManager.hasIntervalListener(dispatchComplete))
			{
				IntervalManager.addIntervalListener(dispatchComplete, IntervalType.SET_INTERVAL, DISPATCH_COMPLETE_INTERVAL, 1);
			}
		}
		
		private function dispatchComplete(event:Event = null):void
		{
			if (_isRunning && complete)
			{
				_progressTimer.reset();
				IntervalManager.removeIntervalListener(dispatchComplete);
				
				_dispatcher.dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, false, false, _bytesTotal, _bytesTotal));
				_dispatcher.dispatchEvent(new Event(Event.COMPLETE));
			}
		}
		
		private function dispatchProgress(event:Event = null):void
		{
			_dispatcher.dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, false, false, _bytesLoaded, _bytesTotal));
		}
		
		private function addSourceListeners(source:Object):void
		{
			source.addEventListener(Event.COMPLETE, completeHandler, false, 0, true);
			source.addEventListener(ProgressEvent.PROGRESS, progressHandler, false, 0, true);
		}
		
		private function removeSourceListeners(source:Object):void
		{
			source.removeEventListener(Event.COMPLETE, completeHandler);
			source.removeEventListener(ProgressEvent.PROGRESS, progressHandler);
		}
		
		private function completeHandler(event:Event):void
		{
			setSourceComplete(IEventDispatcher(event.target));
		}
		
		private function progressHandler(event:ProgressEvent):void
		{
			var progress:Progress = _progressMap[event.target];
			
			updateProgress(event.bytesLoaded - progress.bytesLoaded, event.bytesTotal - progress.bytesTotal);
			
			progress.bytesLoaded = event.bytesLoaded;
			progress.bytesTotal = event.bytesTotal;
			
			if (progress.complete)
			{
				progress.complete = false;
				_sourcesPending++;
			}
			
			if (_isRunning && !_progressTimer.running)
			{
				var time:int = getTimer();
				
				if (time - _progressUpdateTime >= DISPATCH_PROGRESS_INTERVAL)
				{
					dispatchProgress();
				}
				else
				{
					_progressTimer.start();
				}
				
				_progressUpdateTime = time;
			}
		}
	}
}

class Progress
{
	public var bytesLoaded:uint;
	public var bytesTotal:uint;
	public var complete:Boolean;
}