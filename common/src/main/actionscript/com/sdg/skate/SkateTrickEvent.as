package com.sdg.skate
{
	import flash.events.Event;

	public class SkateTrickEvent extends Event
	{
		public static const TRICK:String = 'trick';
		
		private var _trickName:String;
		private var _averageAccuracyDeviation:Number;
		private var _skaterIsMoving:Boolean;
		private var _comboLength:int;
		
		public function SkateTrickEvent(type:String, trickName:String, averageAccuracyDeviaiton:Number, skaterIsMoving:Boolean, comboLength:int, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			_trickName = trickName;
			_averageAccuracyDeviation = averageAccuracyDeviaiton;
			_skaterIsMoving = skaterIsMoving;
			_comboLength = comboLength;
		}
		
		public function get trickName():String
		{
			return _trickName;
		}
		
		public function get averageAccuracyDeviation():Number
		{
			return _averageAccuracyDeviation;
		}
		public function get skaterIsMoving():Boolean
		{
			return _skaterIsMoving;
		}
		public function get comboLength():int
		{
			return _comboLength;
		}
		
	}
}