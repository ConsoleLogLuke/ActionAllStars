package com.sdg.model
{
	import flash.media.SoundMixer;
	import flash.media.SoundTransform;
	
	public class Audio
	{
		private var _soundOn:Boolean;

		public function Audio()
		{
			_soundOn = true;	// initial state is audio on
		}

		public function setAudio(turnOn:Boolean):void
		{
			var s:SoundTransform = new SoundTransform();
		
			if (turnOn)	
			{	
				// turn sound on
				s.volume=1;
				SoundMixer.soundTransform = s;
				_soundOn = true;
			}
			else 
			{	
				// turn sound off
				s.volume=0;
				SoundMixer.soundTransform = s;
				_soundOn = false;
			}
		}

		public function getAudio():Boolean
		{
			return _soundOn;
		}
	}
}