package com.sdg.model
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	public class Party extends EventDispatcher
	{
		protected var _theme:String;
		protected var _effectId:int;
		protected var _soundId:int;
		protected var _partyOn:Boolean;
		
		public function Party()
		{
		}
		
		public function setPartyOptions(partyOn:Boolean, theme:String, effectId:int, soundId:int):void
		{
			if (partyOn != _partyOn)
			{
				_partyOn = partyOn;
				_theme = theme;
				_effectId = effectId;
				_soundId = soundId;
				
				dispatchEvent(new Event("partyOnChanged"));
			}
			else
			{
				if (theme != _theme)
				{
					_theme = theme;
					dispatchEvent(new Event("themeChanged"));
				}
				
				if (effectId != _effectId)
				{
					_effectId = effectId;
					dispatchEvent(new Event("effectIdChanged"));
				}
				
				if (soundId != _soundId)
				{
					_soundId = soundId;
					dispatchEvent(new Event("soundIdChanged"));
				}
			}
			
		}
		
		public function reset():void
		{
			_theme = null;
			_effectId = 0;
			_soundId = 0;
			_partyOn = false;
		}
		
		public function get theme():String
		{
			return _theme;
		}
		
		public function get effectId():int
		{
			return _effectId;
		}
		
		public function get soundId():int
		{
			return _soundId;
		}
		
		public function get partyOn():Boolean
		{
			return _partyOn;
		}
	}
}