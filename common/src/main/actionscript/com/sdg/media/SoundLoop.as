package com.sdg.media
{
	import flash.events.Event;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	
	public class SoundLoop extends Object
	{
		private var _channel:SoundChannel;
		private var _sound:Sound;
		private var _playing:Boolean;
		
		public function SoundLoop(sound:Sound)
		{
			super();
			
			_sound = sound;
			_playing = false;
		}
		
		////////////////////
		// CLASS METHODS
		////////////////////
		
		public function start():void
		{
			if (_playing == true) return;
			_playing = true;
			_channel = _sound.play();
			_channel.addEventListener(Event.SOUND_COMPLETE, _onSoundComplete);
		}
		
		public function stop():void
		{
			if (_playing == false) return;
			_playing = false;
			_channel.removeEventListener(Event.SOUND_COMPLETE, _onSoundComplete);
			_channel.stop();
			_channel = null;
		}
		
		public function destroy():void
		{
			// Stop playback and remove references.
			if (_playing)
			{
				_channel.removeEventListener(Event.SOUND_COMPLETE, _onSoundComplete);
				_channel.stop();
			}
			
			_sound = null;
			_channel = null;
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		public function get transform():SoundTransform
		{
			return _channel.soundTransform;
		}
		public function set transform(value:SoundTransform):void
		{
			_channel.soundTransform = value;
		}
		
		////////////////////
		// EVENT HANDLERS
		////////////////////
		
		private function _onSoundComplete(e:Event):void
		{
			if (_playing != true) return;
			_channel = _sound.play();
		}
		
	}
}