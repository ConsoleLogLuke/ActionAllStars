package com.sdg.game.keycombo
{
	import flash.events.Event;

	public class KeyComboEvent extends Event
	{
		public static const NEW_VALUE:String = 'new key value';
		public static const COMPLETE:String = 'combo complete';
		public static const OFF_TIME:String = 'off time';
		
		private var _keyValues:Array;
		private var _lstAcDev:Number;
		private var _avgAcDev:Number;
		
		public function KeyComboEvent(type:String, keyValues:Array, lastAccuracyDeviation:Number, averageAccuracyDeviation:Number, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			_keyValues = keyValues;
			_lstAcDev = lastAccuracyDeviation;
			_avgAcDev = averageAccuracyDeviation;
		}
		
		public function get keyValues():Array
		{
			return _keyValues;
		}
		
		public function get lastAccuracyDeviation():Number
		{
			return _lstAcDev;
		}
		
		public function get averageAccuracyDeviation():Number
		{
			return _avgAcDev;
		}
		
	}
}