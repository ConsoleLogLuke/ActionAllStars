package com.sdg.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.adobe.cairngorm.control.CairngormEventDispatcher;
	import com.sdg.business.SdgServiceDelegate;
	import com.sdg.events.GetBillDateEvent;
	
	import mx.rpc.IResponder;
	
	public class GetBillDateCommand implements ICommand, IResponder
	{
		private var _event:GetBillDateEvent;
		
		public function execute(event:CairngormEvent):void
		{
			_event = event as GetBillDateEvent;
			
			if (_event.eventType == GetBillDateEvent.GET_DATE_BY_USER)
				new SdgServiceDelegate(this).getBillDateByUser(_event.userId);
		}
		
		public function result(data:Object):void
		{
			getStatus(data);
		}
		
		public function fault(info:Object):void
		{
			getStatus(info);
		}
		
		private function getStatus(info:Object):void
		{
			// get the status from our xml data object
			trace("TRACE: GetBillDateCommand.getStatus.info: "+info);
			var status:int = int(info.@status);
			var plan:uint = info.@plan;
			var date:String = info.@date;
			var renew:uint = info.@renew;
			
			
			// dispatch a date received event
			if (_event.eventType == GetBillDateEvent.GET_DATE_BY_USER)
				CairngormEventDispatcher.getInstance().dispatchEvent(new GetBillDateEvent(_event.userId, GetBillDateEvent.DATE_BY_USER_RECEIVED, date, plan, renew));
		}
	}
}
