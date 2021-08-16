package com.sdg.model
{
	public class FandamoniumPrizeItem extends PrizeItem
	{
		private var _teamId:uint;
		
		public function FandamoniumPrizeItem(instanceId:int=0)
		{
			super(instanceId);
			
			// Default.
			_teamId = 0;
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		public function get teamId():uint
		{
			return _teamId;
		}
		public function set teamId(value:uint):void
		{
			_teamId = value;
		}
		
	}
}