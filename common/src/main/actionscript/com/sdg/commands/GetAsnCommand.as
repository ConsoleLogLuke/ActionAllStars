package com.sdg.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.sdg.business.SdgServiceDelegate;
	import com.sdg.components.controls.SdgAlertChrome;
	import com.sdg.events.GetAsnEvent;
	import com.sdg.utils.ErrorCodeUtil;
	
	import mx.rpc.IResponder;
	
	public class GetAsnCommand implements ICommand, IResponder
	{
		private var _event:GetAsnEvent;
		
		public function execute(event:CairngormEvent):void
		{
			_event = event as GetAsnEvent;
			new SdgServiceDelegate(this).getAsn(_event.avatarId);
		}
		
		public function result(data:Object):void
		{
		}
		
		public function fault(info:Object):void
		{
			var myClass:Class = Object(this).constructor;
			var status:int = int(info.@status);
			
			SdgAlertChrome.show("Sorry, we were unable to complete your request.", "Time Out!", null, null, 
									true, true, 430, 200, ErrorCodeUtil.constructCode(myClass,status.toString()));
			
			//SdgAlertChrome.show("Error getting action sports news.", "Time Out!", null, null, 
									//true, true, false, 430, 200, ErrorCodeUtil.constructCode(myClass,status.toString()));
		}
	}
}
