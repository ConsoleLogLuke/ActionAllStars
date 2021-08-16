package com.sdg.commands
{
	import com.sdg.components.controls.SdgAlertChrome;
	import com.sdg.utils.ErrorCodeUtil;
	
	public class AbstractResponderCommand
	{
		public function fault(info:Object):void
		{
			var myClass:Class = Object(this).constructor;
			var status:int = int(info.@status);
			
			SdgAlertChrome.show("Sorry, we were unable to complete your request.", "Time Out!", null, null, 
									true, true, 430, 200, ErrorCodeUtil.constructCode(myClass,status.toString()));
		}
	}
}