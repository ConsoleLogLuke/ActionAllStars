package com.sdg.model
{
	public class PrizeItem extends SdgItem
	{
		private var _value:Number;
		
		public function PrizeItem(instanceId:int = 0)
		{
			super(instanceId);
			
			// Default.
			_value = 0;
		}
		
		public function get value():Number
		{
			return _value;
		}
		public function set value(val:Number):void
		{
			_value = val;
		}
		
	}
}