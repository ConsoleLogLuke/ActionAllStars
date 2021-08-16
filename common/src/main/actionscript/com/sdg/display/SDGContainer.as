
package com.sdg.display
{
	import com.sdg.events.TrackedEvent;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.EventDispatcher;
	import flash.events.Event;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	public class SDGContainer extends MovieClip
	{
		
		private var _events:Array = [];
		private var _soundChannel:SoundChannel;
		private var _currentSounds:Array = [];
		protected var _destroyed:Boolean = false; // true when destroy() is called, not when cleanup is complete
		
		public function SDGContainer()
		{
			super();
		}
		
		public function init():void
		{
			
		}
		
		protected function trackEventListener(target:EventDispatcher, type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):TrackedEvent
		{
			// add the event listener on the provided target
			target.addEventListener(type, listener, useCapture, priority, useWeakReference);
			
			// store this information in an array
			// so that later we can remove all event listeners added using this method
			// store it as a TrackedEvent object
			var e:TrackedEvent = new TrackedEvent(target, type, listener);
			_events.push(e);
			
			return e;
		}
		
		protected function removeTrackedEventListener(e:TrackedEvent):void
		{
			var target:EventDispatcher = e.target;
			var type:String = e.type;
			var listener:Function = e.listener;
			
			// remove listener
			target.removeEventListener(type, listener);
					
			// remove from array
			var index:int = _events.indexOf(e);
			_events.splice(index, 1);
		}
		
		protected function playSound(sound:Sound):SoundChannel
		{
			// play a sound
			// keep track of the sound
			// when it is done playing, forget about it
			_soundChannel = sound.play();
			var te:TrackedEvent = trackEventListener(_soundChannel, Event.SOUND_COMPLETE, complete);
			
			var i:int = _currentSounds.length;
			_currentSounds.push(_soundChannel);
			
			return _soundChannel;
			
			function complete(e:Event):void
			{
				removeTrackedEventListener(te);
				_currentSounds.splice(i, 1);
			}
		}
		
		protected function _loopSound(sound:Sound, times:int = 1, delayMultiplyer:Number = 1, volume:Number = 1, endCallback:Function = null):void
		{
			var count:int = 0;
			var length:Number = sound.length;
			var tmr:Timer = new Timer(length * delayMultiplyer);
			var te:TrackedEvent = trackEventListener(tmr, TimerEvent.TIMER, timerInterval);
			_soundChannel = playSound(sound);
			_soundChannel.soundTransform = new SoundTransform(volume);
			tmr.start();
			
			function timerInterval(e:TimerEvent):void
			{
				count++;
				if (count < times)
				{
					_soundChannel = playSound(sound);
					_soundChannel.soundTransform = new SoundTransform(volume);
					tmr.reset();
					tmr.start();
				}
				else
				{
					removeTrackedEventListener(te);
					tmr.reset();
					tmr = null;
					
					if (endCallback != null) endCallback();
				}
			}
		}
		
		public function destroy():void
		{
			_destroyed = true;
			
			// send to frame 1 and stop
			gotoAndStop(1);
			
			// vars used for clean up
			var len:int;
			var i:int;
			
			// stop current sounds
			len = _currentSounds.length;
			i = 0;
			for (i; i < len; i++)
			{
				var channel:SoundChannel = SoundChannel(_currentSounds[i]);
				if (channel != null) channel.stop();
			}
			
			// remove all event listeners
			len = _events.length;
			i = len - 1;
			for (i; i >= 0; i--)
			{
				var e:* = _events[i];
				if (e as TrackedEvent)
				{
					var target:EventDispatcher = e.target;
					var type:String = e.type;
					var listener:Function = e.listener;
					
					// remove listener
					target.removeEventListener(type, listener);
					
					// remove from array
					_events.splice(i, 1);
				}
			}
			
			// remove/destroy all display children
			destroyChildren(this);
			
			function destroyChildren(container:DisplayObjectContainer):void
			{
				// remove/destroy all display children
				i = 0;
				var child:DisplayObject;
				var children:int = container.numChildren;
				while (children > 0)
				{
					// WARNING
					// this should never result in an endless loop
					// but maybe should take some precaution
					try
					{
						child = container.getChildAt(i);
					}
					catch (e:RangeError)
					{
						i++;
						return;
					}
					if (child)
					{
						var childContainer:SDGContainer = child as SDGContainer;
						if (childContainer != null)
						{
							childContainer.destroy();
						}
							
						var childMC:MovieClip = child as MovieClip;
						if (childMC != null)
						{
							childMC.gotoAndStop(1);	
						}
						
						var childObjCtnr:DisplayObjectContainer = child as DisplayObjectContainer;
						if (childObjCtnr != null)
						{
							destroyChildren(DisplayObjectContainer(childObjCtnr));
						}
						
						// if we dont get resource/performance improvements by removing the children from display
						// then we shouldnt be doing it
						// commenting it out for now
						/*container.removeChild(child);
						child = null;*/
						children--;
					}
					else
					{
						i++;
					}
				}
			}
		}
	}
}