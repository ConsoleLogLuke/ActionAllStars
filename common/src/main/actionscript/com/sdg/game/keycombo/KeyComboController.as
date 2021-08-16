package com.sdg.game.keycombo
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Matrix;
	import flash.utils.Timer;

	public class KeyComboController extends Sprite implements IKeyComboController
	{
		public static const OFF_TIME:String = 'off time';
		public static const NEW_VALUE:String = 'new value';
		public static const NEW_INTERVAL:String = 'new interval';
		
		private static const _USE_BASE_GUIDE:Boolean = false;
		
		private var _intervalDuration:int;
		private var _maxIntervals:int;
		private var _timeAtStart:uint;
		private var _timeAtLastInterval:uint;
		private var _triggerDuration:int;
		private var _view:IKeyComboView;
		private var _values:Array;
		private var _intervalIndex:int;
		private var _stepTimer:Timer;
		private var _lastAccuracyDeviation:Number;
		private var _averageAccuracyDeviation:Number;
		private var _baseGuide:Bitmap;
		private var _handicapFactor:Number;
		
		public function KeyComboController(initialValue:String, intervalDuration:int = 1000, maxIntervals:int = 3, triggerDuration:int = 200, intervalWidth:Number = 100, handicapFactor:Number = 1.25)
		{
			super();
			
			_values = [];
			_intervalDuration = intervalDuration;
			_maxIntervals = maxIntervals;
			_triggerDuration = triggerDuration;
			_handicapFactor = handicapFactor;
			_intervalIndex = 0;
			_lastAccuracyDeviation = 0;
			_averageAccuracyDeviation = 0;
			
			_stepTimer = new Timer(20);
			
			if (_USE_BASE_GUIDE)
			{
				var base:IKeyComboView = new KeyComboView(intervalWidth, (triggerDuration / intervalDuration) * intervalWidth);
				base.fillVisible = false;
				for (var i:int = 0; i < _maxIntervals; i++)
				{
					base.addKeyPoint();
				}
				var baseDisplay:DisplayObject = DisplayObject(base);
				var margin:Number = 5;
				var bD:BitmapData = new BitmapData(baseDisplay.width + margin * 2, baseDisplay.height + margin * 2, true, 0x00ff00);
				bD.draw(baseDisplay, new Matrix(1, 0, 0, 1, margin, margin));
				_baseGuide = new Bitmap(bD);
				_baseGuide.x = -margin;
				_baseGuide.y = -margin;
				_baseGuide.alpha = 0.5;
				_baseGuide.blendMode = BlendMode.MULTIPLY;
				
				addChild(_baseGuide);
			}
			
			_view = new KeyComboView(intervalWidth, (triggerDuration / intervalDuration) * intervalWidth);
			_view.addKeyPoint();
			_view.addKeyPoint();
			_view.setNextKeyPointValue(initialValue);
			
			addChild(DisplayObject(_view));
		}
		
		////////////////////
		// PUBLIC FUNCTIONS
		////////////////////
		
		public function start(initialValue:String):void
		{
			// Make sure we only start once.
			if (_timeAtStart) return;
			_timeAtStart = new Date().time;
			_timeAtLastInterval = _timeAtStart;
			_values.push(initialValue);
			
			_stepTimer.addEventListener(TimerEvent.TIMER, onStepTimer);
			_stepTimer.start();
		}
		
		public function destroy():void
		{
			_stepTimer.reset();
			_stepTimer = null;
			
			removeChild(DisplayObject(_view));
			_view.destroy();
			_view = null;
		}
		
		public function stop(validStop:Boolean = true):void
		{
			_stepTimer.removeEventListener(TimerEvent.TIMER, onStepTimer);
			_stepTimer.reset();
			
			// Set interval progress to update view before we stop.
			var timeSinceLastInterval:int = new Date().time - _timeAtLastInterval;
			_view.setIntervalProgress(timeSinceLastInterval / _intervalDuration);
			
			// Remove base guide.
			if (_baseGuide) removeChild(_baseGuide);
			_baseGuide = null
			
			// Max milliseconds of deviation allowed to still be considered valid.
			var maxDeviation:Number = _triggerDuration / 2;
			
			if (validStop)
			{
				// Include accuracy deviaiton as a fraction of the maximum allowable.
				dispatchEvent(new KeyComboEvent(KeyComboEvent.COMPLETE, _values, _lastAccuracyDeviation / maxDeviation, _averageAccuracyDeviation / maxDeviation, true));
			}
			else
			{
				// Include accuracy deviaiton as a fraction of the maximum allowable.
				dispatchEvent(new KeyComboEvent(KeyComboEvent.OFF_TIME, _values, _lastAccuracyDeviation / maxDeviation, _averageAccuracyDeviation / maxDeviation, true));
			}
			
		}
		
		public function attemptToSetNextValue(value:String):void
		{
			// Make sure we are within the timeframe allowed to set the next value.
			var timeSinceLastInterval:int = new Date().time - _timeAtLastInterval;
			// Determine deviation from perfect timing.
			_lastAccuracyDeviation = timeSinceLastInterval - _intervalDuration; // In miliseconds.
			var absDev:int = Math.abs(_lastAccuracyDeviation); // Absolute value.
			_averageAccuracyDeviation = (_averageAccuracyDeviation * _intervalIndex + absDev) / (_intervalIndex + 1);
			var maxDeviation:Number = _triggerDuration / 2;
			// The handicap factor was introduced to have an easier threshold as the number of steps in the combo increases.
			var handicap:Number = getHandicapFactorWithIntervalIndex(_intervalIndex);
			maxDeviation *= handicap;
			if (absDev < maxDeviation)
			{
				// This is a valid time to set the next value.
				// Make sure the next value has not already been set.
				var nextValue:String = _values[_intervalIndex + 1] as String;
				if (nextValue) return;
				_values.push(value);
				
				_view.setNextKeyPointValue(value);
				
				// Include accuracy deviaiton as a fraction of the maximum allowable.
				dispatchEvent(new KeyComboEvent(KeyComboEvent.NEW_VALUE, _values, _lastAccuracyDeviation / maxDeviation, _averageAccuracyDeviation / maxDeviation, true));
				
				// Check if we have reached maximum interval values.
				if (_values.length > _maxIntervals - 1)
				{
					// Reached maximum interval values.
					stop(true);
				}
			}
			else
			{
				// This is not a valid time to set the next value.
				stop(false);
			}
		}
		
		////////////////////
		// PRIVATE FUNCTIONS
		////////////////////
		
		private function getHandicapFactorWithIntervalIndex(intervalIndex:int):Number
		{
			return (intervalIndex > 0) ? Math.pow(_handicapFactor, intervalIndex) : 1;
		}
		
		////////////////////
		// GET/SET FUNCTIONS
		////////////////////
		
		override public function get width():Number
		{
			return _view.intervalWidth * ((_baseGuide) ? (_maxIntervals - 1) : (_intervalIndex + 1)) + _view.keyPointSize;
		}
		
		override public function get height():Number
		{
			return DisplayObject(_view).height;
		}
		
		public function get values():Array
		{
			return _values.concat();
		}
		
		////////////////////
		// EVENT HANDLERS
		////////////////////
		
		private function onStepTimer(e:TimerEvent):void
		{
			// Determine how much time has passed since last interval.
			var currentTime:uint = new Date().time;
			var timeSinceLastInterval:uint = currentTime - _timeAtLastInterval;
			// The handicap factor was introduced to have an easier threshold as the number of steps in the combo increases.
			var handicap:Number = getHandicapFactorWithIntervalIndex(_intervalIndex + 1);
			if (timeSinceLastInterval > _intervalDuration + (_triggerDuration * handicap) / 2)
			{
				// We have reached the end of the interval range.
				// Check if the next value has been assigned.
				var nextValue:String = _values[_intervalIndex + 1] as String;
				if (nextValue)
				{
					// The next interval value has been set.
					// Go on to the next interval.
					_intervalIndex++;
					_timeAtLastInterval = _timeAtStart + _intervalDuration * _intervalIndex;
					timeSinceLastInterval = currentTime - _timeAtLastInterval;
					_view.addKeyPoint(handicap);
					
					dispatchEvent(new Event(NEW_INTERVAL));
				}
				else
				{
					// The next value has not been set.
					// Consider this bad timing.
					// Determine deviation from perfect timing.
					_lastAccuracyDeviation = timeSinceLastInterval - _intervalDuration; // In miliseconds.
					_averageAccuracyDeviation = (_averageAccuracyDeviation * _intervalIndex + Math.abs(_lastAccuracyDeviation)) / (_intervalIndex + 1);
					stop(false);
					return;
				}
			}
			
			_view.setIntervalProgress(timeSinceLastInterval / _intervalDuration);
		}
		
	}
}