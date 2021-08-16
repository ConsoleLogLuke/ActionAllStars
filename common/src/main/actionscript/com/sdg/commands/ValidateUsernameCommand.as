package com.sdg.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.adobe.cairngorm.control.CairngormEventDispatcher;
	import com.sdg.business.SdgServiceDelegate;
	import com.sdg.components.controls.SdgAlert;
	import com.sdg.events.ValidateUsernameEvent;
	
	import mx.rpc.IResponder;
	
	public class ValidateUsernameCommand implements ICommand, IResponder
	{
		private var _event:ValidateUsernameEvent;
		
		private static const ID_MAP:Object =
		{
			1:"invalid",
			2:"available",
			3:"taken",
			4:"unacceptable"
		};
		
		public function execute(event:CairngormEvent):void
		{
			_event = ValidateUsernameEvent(event);
			
			new SdgServiceDelegate(this).validateUsername(_event.userName);
		}
		
		public function result(data:Object):void
		{
			// get the status from our xml data object
			var statusInt:int = data.result;
			var status:String = ID_MAP[statusInt] as String;
			var suggestion:String = data.suggest;
			
			// dispatch a "usernameValidated" event			
			CairngormEventDispatcher.getInstance().dispatchEvent(new ValidateUsernameEvent(_event.userName, ValidateUsernameEvent.USERNAME_VALIDATED, status, suggestion));
		}
		
		public function fault(info:Object):void
		{
			CairngormEventDispatcher.getInstance().dispatchEvent(new ValidateUsernameEvent(_event.userName, ValidateUsernameEvent.USERNAME_VALIDATED));
			//SdgAlert.show("Error validating name", "Time Out!", SdgAlert.OK);
		}
	}
}