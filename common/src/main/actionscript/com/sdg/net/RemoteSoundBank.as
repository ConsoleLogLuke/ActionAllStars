package com.sdg.net
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;

	public class RemoteSoundBank extends EventDispatcher
	{
		protected const NONE_STATUS:String = 'none asset status';
		protected const LOADING_STATUS:String = 'loading asset status';
		protected const ERROR_STATUS:String = 'error asset status';
		protected const COMPLETE_STATUS:String = 'complete asset status';
		
		protected var _soundUrlArray:Array;
		protected var _soundStatusArray:Array;
		protected var _soundArray:Array;
		protected var _bytesTotal:uint;
		
		private var _soundChannels:Array;
		private var _ignoreLoad:Array;
		
		
		/**
		 * The RemoteSoundBank class is used to load and play sounds.
		 * Once a sound has been loaded it will be cached so subsequent
		 * calls to play the sound will happen much faster.
		 * All sounds will be cached until clear() is called.
		 * 
		 */		
		public function RemoteSoundBank()
		{
			super();
			
			// Create storage arrays.
			_soundUrlArray = [];
			_soundStatusArray = [];
			_soundArray = [];
			_soundChannels = [];
			_ignoreLoad = [];
			
			_bytesTotal = 0;
		}
		
		////////////////////
		// INSTANCE METHODS
		////////////////////
		
		public function playSound(url:String, volume:Number = 1, panning:Number = 0):void
		{
			// Make sure we are not already loading or have already loaded this sound.
			var status:String = getSoundStatus(url);
			var soundTransform:SoundTransform = new SoundTransform(volume, panning);
			var soundChannel:SoundChannel;
			if (status == COMPLETE_STATUS)
			{
				// This sound has already been loaded.
				// Play the sound.
				var sound:Sound = _soundArray[url] as Sound;
				if (sound != null)
				{
					soundChannel = sound.play(0, 0, soundTransform);
					_soundChannels[url] = soundChannel;
					soundChannel.addEventListener(Event.SOUND_COMPLETE, onSoundComplete);
					return;
				}
			}
			else if (status == LOADING_STATUS)
			{
				// We are already loading this sound.
				return;
			}
			else if (status == ERROR_STATUS)
			{
				// We already tried to load this sound and there was an error.
				return;
			}
			
			// Get ready to load this sound.
			var request:URLRequest = new URLRequest(url);
			var loader:Sound = new Sound();
			loader.addEventListener(Event.COMPLETE, onComplete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onError);
			// Set status for the sound.
			_soundStatusArray[url] = LOADING_STATUS;
			// Store a reference to the sound.
			_soundArray[url] = loader;
			// Do the load.
			loader.load(request);
			
			function onComplete(e:Event):void
			{
				// Remove event listeners.
				loader.removeEventListener(Event.COMPLETE, onComplete);
				loader.removeEventListener(IOErrorEvent.IO_ERROR, onError);
				
				// Set status for the sound.
				_soundStatusArray[url] = COMPLETE_STATUS;
				
				// Set bytes.
				_bytesTotal += loader.bytesTotal;
				
				// Check if an ignore flag was set.
				if (_ignoreLoad[url])
				{
					_ignoreLoad[url] = false;
					return;
				}
				
				// Play the sound.
				soundChannel = loader.play(0, 0, soundTransform);
				_soundChannels[url] = soundChannel;
				soundChannel.addEventListener(Event.SOUND_COMPLETE, onSoundComplete);
			}
			
			function onError(e:IOErrorEvent):void
			{
				// Remove event listeners.
				loader.removeEventListener(Event.COMPLETE, onComplete);
				loader.removeEventListener(IOErrorEvent.IO_ERROR, onError);
				
				// Set status for the sound.
				_soundStatusArray[url] = ERROR_STATUS;
			}
		}
		
		protected function getSoundStatus(url:String):String
		{
			return (_soundStatusArray[url] != null) ? _soundStatusArray[url] : NONE_STATUS;
		}
		
		public function clear():void
		{
			// Empty arrays.
			_soundUrlArray = [];
			_soundStatusArray = [];
			_soundArray = [];
			
			// Reset bytes.
			_bytesTotal = 0;
		}
		
		public function isSoundPlaying(url:String):Boolean
		{
			return (_soundChannels[url] != null);
		}
		
		public function stopSound(url:String):void
		{
			var sndChnl:SoundChannel = _soundChannels[url] as SoundChannel;
			if (sndChnl)
			{
				// Remove listener.
				sndChnl.removeEventListener(Event.SOUND_COMPLETE, onSoundComplete);
				sndChnl.stop();
				_soundChannels[url] = null;
			}
			else if (getSoundStatus(url) == LOADING_STATUS)
			{
				_ignoreLoad[url] = true;
			}
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		public function get bytesTotal():uint
		{
			return _bytesTotal;
		}
		
		////////////////////
		// EVENT HANDLERS
		////////////////////
		
		private function onSoundComplete(e:Event):void
		{
			// Remove listener.
			SoundChannel(e.currentTarget).removeEventListener(Event.SOUND_COMPLETE, onSoundComplete);
			// Set flag.
			_soundChannels[_soundChannels.indexOf(e.currentTarget)] = null;
		}
		
	}
}