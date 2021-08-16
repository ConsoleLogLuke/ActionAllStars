package com.sdg.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.sdg.business.SdgServiceDelegate;
	import com.sdg.components.controls.ProgressAlertChrome;
	import com.sdg.components.controls.SdgAlertChrome;
	import com.sdg.events.ResendActivationEvent;
	import com.sdg.utils.ErrorCodeUtil;
	
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import mx.events.CloseEvent;
	import mx.rpc.IResponder;
	
	public class ResendActivationCommand implements ICommand, IResponder
	{
		private var _event:ResendActivationEvent;
		private var _progressDialog:ProgressAlertChrome;
		
		public function execute(event:CairngormEvent):void
		{
			_progressDialog = ProgressAlertChrome.show("In Progress.  Please wait", "Resending Activation", null, null, true);
			//_progressDialog = ProgressAlert.show("In Progress.  Please wait", "Resending Activation", null, null, true);
			_event = event as ResendActivationEvent;
			new SdgServiceDelegate(this).resendActivation(_event.userName, _event.email);
		}
		
		public function result(data:Object):void
		{
			//trace(data);
			var body:String = "Congratulations!  We have sent an email to " + _event.email +
					" with instructions on how you can activate your account.  " + 
					"Please check your email to complete the activation process.";
			//SdgAlertChrome.show(body, "Check Your Email!", navigateToLogin, null, true, true, false, 430, 230);
			//SdgAlert.show(body, "Check Your Email!", null);
			
			// close out progress dialog
			if (_progressDialog)
				_progressDialog.close();
		}
		
		public function fault(info:Object):void
		{
			trace(info);
			var myClass:Class = Object(this).constructor;
			var status:int = int(info.@status);
			var reason:String = "";
			
			// close out progress dialog
			if (_progressDialog)
				_progressDialog.close();
			
			switch (status)
			{
				case 403:
					SdgAlertChrome.show("This Athlete name does not exist.", "Time Out!");
					break;
				case 407:
					SdgAlertChrome.show("This avatar does not exist.", "Time Out!");
					break;
				case 406:
					SdgAlertChrome.show("This account has already been activated.", "Time Out!", navigateToLogin);
					break;
				case 410:
					SdgAlertChrome.show("This email address does not match the Athlete name we have on record. Please try again.", "Time Out!");
					break;
				default:
					SdgAlertChrome.show("Sorry, we were unable to complete your request. Please try again.", "Time Out!", null, null, 
											true, true, 430, 200, ErrorCodeUtil.constructCode(myClass,status.toString()));
					break;
			}
		}
		
		private function navigateToLogin(e:CloseEvent):void
		{
			navigateToURL(new URLRequest('chatApp.jsp'), '_self');
			//navigateToURL(new URLRequest('login.jsp'), '_self');
			//Application.application.loadModule("Login.swf");
		}
	}
}
