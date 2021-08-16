package com.sdg.events
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	public class GetBillDateEvent extends CairngormEvent
	{
		public static const GET_DATE_BY_USER:String = "getDateByUser";
		public static const DATE_BY_USER_RECEIVED:String = "dateByUserReceived";
		//public static const GET_DATE_BY_PLAN:String = "getDateByPlan";
		//public static const DATE_BY_PLAN_RECEIVED:String = "dateByPlanReceived";
		
		private var _eventType:String;
		private var _userId:uint;
		private var _plan:uint;
		private var _date:String;
		private var _renew:uint;
		
		public function GetBillDateEvent(id:uint, type:String = GET_DATE_BY_USER, date:String = null, plan:uint = 0, renew:uint = 0)
		{
			super(type);
			_eventType = type;
			_userId = id;
			_plan = plan;
			_date = date;
			_renew = renew;
		}
		
		public function get eventType():String
		{
			return _eventType;
		}
		
		public function get userId():uint
		{
			return _userId;
		}
		
		public function get plan():uint
		{
			return _plan;
		}
		
		public function get date():String
		{
			return _date;
		}
		
		public function get renew():uint
		{
			return _renew;
		}
	}
}