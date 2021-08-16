package com.sdg.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.sdg.business.SdgServiceDelegate;
	import com.sdg.events.ModeratorSaveReportEvent;
	import mx.rpc.IResponder;
		
	public class SaveModeratorReportCommand extends AbstractResponderCommand implements ICommand, IResponder
	{
		public function execute(event:CairngormEvent):void
		{
			var ev:ModeratorSaveReportEvent = event as ModeratorSaveReportEvent;
			new SdgServiceDelegate(this).saveModeratorReport(ev.params);
		}
		
		public function result(data:Object):void
		{
	
		}
	}
}