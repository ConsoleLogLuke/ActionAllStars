package com.sdg.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.adobe.cairngorm.control.CairngormEventDispatcher;
	import com.sdg.business.SdgServiceDelegate;
	import com.sdg.events.PayByPayPalEvent;
	
	import mx.rpc.IResponder;
	
	public class PayByPayPalCommand implements ICommand, IResponder
	{
		public function execute(event:CairngormEvent):void
		{
			var ev:PayByPayPalEvent = event as PayByPayPalEvent;
			new SdgServiceDelegate(this).setPayPal(ev.userId, ev.planId);
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
			trace(info);
		}
	}
}
