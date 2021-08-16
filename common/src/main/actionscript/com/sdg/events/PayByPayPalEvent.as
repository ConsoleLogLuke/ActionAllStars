package com.sdg.events
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	public class PayByPayPalEvent extends CairngormEvent
	{
		public static const SET_PAYPAL:String = "setPayPal";
		
		private var _userId:uint;
		private var _planId:uint;
		
		public function PayByPayPalEvent(userId:uint, planId:uint, type:String = SET_PAYPAL)
		{
			super(type);
			_userId = userId;
			_planId = planId;
		}
		
		public function get userId():uint
		{
			return _userId;
		}
		
		public function get planId():uint
		{
			return _planId;
		}
	}
}