package com.sdg.net
{
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;
	import flash.net.URLRequest;
	import flash.utils.Timer;

	public class QuickLoader extends Sprite
	{
		protected var _url:String;
		protected var _loadComplete:Boolean;
		protected var _quedListeners:Array;
		protected var _loadedContent:DisplayObject;
		protected var _retryCount:uint;
		
		public function QuickLoader(url:String, onComplete:Function = null, onError:Function = null, retryCount:uint = 0, timeoutDuration:int = 3000)
		{
			_loadComplete = false;
			_quedListeners = [];
			_url = url;
			_retryCount = retryCount;
			
			var timeout:Timer = new Timer(timeoutDuration);
			timeout.addEventListener(TimerEvent.TIMER, onTimeout);
			
			var tryCount:uint = 1;
			
			var request:URLRequest = new URLRequest(_url);
			var loader:Loader = new Loader();
			loader.mouseChildren = true;
			loader.contentLoaderInfo.addEventListener(Event.INIT, onLoadComplete);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
			loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onLoadProgress);
			loader.load(request);
			
			timeout.start();
			
			function onLoadComplete(e:Event):void
			{
				// Kill timeout.
				killTimer();
				
				// Remove event listeners.
				loader.contentLoaderInfo.removeEventListener(Event.INIT, onLoadComplete);
				loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
				loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, onLoadProgress);
				
				// Set content.
				_loadedContent = loader.content;
				addChild(_loadedContent);
				
				_loadComplete = true;
				
				addQuedListeners();
				
				if (onComplete != null) onComplete();
			}
			
			function onLoadProgress(e:ProgressEvent):void
			{
				timeout.reset();
				timeout.start();
			}
			
			function onLoadError(e:IOErrorEvent):void
			{
				failed();
			}
			
			function onTimeout(e:TimerEvent):void
			{
				// Load timeout.
				failed();
			}
			
			function failed():void
			{
				if (_retryCount >= tryCount)
				{
					// Retry.
					tryCount++;
					loader.load(request);
				}
				else
				{
					// Failed.
					killTimer();
					// Remove event listeners.
					loader.contentLoaderInfo.removeEventListener(Event.INIT, onLoadComplete);
					loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
					loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, onLoadProgress);
					
					if (onError != null) onError();
				}
			}
			
			function killTimer():void
			{
				timeout.removeEventListener(TimerEvent.TIMER, onTimeout);
				timeout.reset();
			}
		}
		
		////////////////////
		// INSTANCE METHODS
		////////////////////
		
		override public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void
		{
			// If the load is complete, add the listener to the loader content,
			// Otherwise que it to be added once the load is complete.
			if (_loadComplete == true)
			{
				// Add the listener to the loaded content.
				_loadedContent.addEventListener(type, listener, useCapture, priority, useWeakReference);
			}
			else
			{
				// Que the listener.
				queListener(type, listener, useCapture, priority, useWeakReference);
			}
		}
		
		override public function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void
		{
			if (_loadComplete == true)
			{
				// Remove the listener from the loaded content.
				_loadedContent.removeEventListener(type, listener, useCapture);
			}
			else
			{
				// Remove qued listener.
				unqueListener(type, listener, useCapture);
			}
		}
		
		protected function queListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void
		{
			var params:Array = [type, listener, useCapture, priority, useWeakReference];
			_quedListeners.push(params);
		}
		
		protected function unqueListener(type:String, listener:Function, useCapture:Boolean=false):void
		{
			var i:uint = 0;
			var len:uint = _quedListeners.length;
			for (i; i < len; i++)
			{
				var params:Array = _quedListeners[i] as Array;
				if (params == null) continue;
				
				var typeQ:String = params[0] as String;
				var listenerQ:Function = params[1] as Function;
				if (typeQ == null || listenerQ == null) continue;
				
				if (typeQ == type && listenerQ == listener)
				{
					_quedListeners.splice(i, 1);
					i = len;
					return;
				}
			}
		}
		
		protected function addQuedListeners():void
		{
			var i:uint = 0;
			var len:uint = _quedListeners.length;
			for (i; i < len; i++)
			{
				var params:Array = _quedListeners[i] as Array;
				if (params == null) continue;
				
				var type:String = params[0] as String;
				var listener:Function = params[1] as Function;
				var useCapture:Boolean = params[2] as Boolean;
				var priority:int = params[3] as int;
				var useWeakReference:Boolean = params[4] as Boolean;
				
				_loadedContent.addEventListener(type, listener, useCapture, priority, useWeakReference);
			}
			
			_quedListeners = [];
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		public function get content():DisplayObject
		{
			return _loadedContent;
		}
		
	}
}