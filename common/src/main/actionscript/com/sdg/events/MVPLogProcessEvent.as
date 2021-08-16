package com.sdg.events
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	public class MVPLogProcessEvent extends CairngormEvent
	{
		public static const PROCESS_LOGGING:String = "process logging";
		
		private var _pageId:int;
		private var _linkId:int;
		private var _planId:int;
		private var _paymentMethodId:int;
		
		public function MVPLogProcessEvent(pageId:int, linkId:int, planId:int, paymentMethodId:int = 0, type:String = PROCESS_LOGGING)
		{
			super(type);
			_pageId = pageId;
			_linkId = linkId;
			_planId = planId;
			_paymentMethodId = paymentMethodId;
		}
		
		public function get pageId():int
		{
			return _pageId;
		}
		
		public function get linkId():int
		{
			return _linkId;
		}
		
		public function get planId():int
		{
			return _planId;
		}
		
		public function get paymentMethodId():int
		{
			return _paymentMethodId;
		}
	}
}