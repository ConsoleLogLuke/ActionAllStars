package com.sdg.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.sdg.business.SdgServiceDelegate;
	import com.sdg.events.LoginEvent;
	import com.sdg.model.ModelLocator;
	import com.sdg.model.User;
	
	import mx.rpc.IResponder;
	
	public class MVPLoginCommand extends AbstractResponderCommand implements ICommand, IResponder
	{
		private var _username:String;
		private var _password:String;
		
		public function execute(event:CairngormEvent):void
		{
			var ev:LoginEvent = event as LoginEvent;
			
			new SdgServiceDelegate(this).mvpLogin(ev.username, ev.password, ev.linkId, ev.planId, ev.paymentMethodId);
		}
		
		public function result(data:Object):void
		{
			returnResult(data);
		}
		
		public override function fault(data:Object):void
		{
			returnResult(data);
		}
		
		private function returnResult(data:Object):void
		{
			var user:User = ModelLocator.getInstance().user;
			user.userId = data.@userId;
			user.loggedInStatus = data.@status; // has to be last because changewatcher is on loggedInStatus
		}
	}
}