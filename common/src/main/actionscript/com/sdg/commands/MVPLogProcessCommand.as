package com.sdg.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.sdg.business.SdgServiceDelegate;
	import com.sdg.events.MVPLogProcessEvent;
	
	import mx.rpc.IResponder;
	
	public class MVPLogProcessCommand extends AbstractResponderCommand implements ICommand, IResponder
	{
		public function execute(event:CairngormEvent):void
		{
			var e:MVPLogProcessEvent = event as MVPLogProcessEvent;
			new SdgServiceDelegate(this).mvpLogProcess(e.pageId, e.linkId, e.planId, e.paymentMethodId);
		}
		
		public function result(data:Object):void
		{
		}
		
		override public function fault(info:Object):void
		{
		}
	}
}
