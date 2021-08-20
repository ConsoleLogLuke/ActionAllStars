package com.sdg.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.sdg.business.SdgSocketDelegate;
	import com.sdg.components.controls.SdgAlertChrome;
	import com.sdg.components.dialog.*;
	import com.sdg.events.SocketEvent;
	import com.sdg.events.SocketLoginEvent;
	import com.sdg.model.ModelLocator;
	import com.sdg.model.User;
	import com.sdg.utils.ErrorCodeUtil;

	import mx.core.FlexGlobals; // Non-SDG - Application to FlexGlobals
	import mx.rpc.IResponder;

	public class SocketLoginCommand implements ICommand, IResponder
	{
		private var _delegate:SdgSocketDelegate;
		private var _serverId:uint;
		private var _failOverAttempted:Boolean = false;
		//private var _progressDialog:ProgressAlertChrome;

		public function execute(event:CairngormEvent):void
		{
			//_progressDialog = ProgressAlert.show("In Progress.  Please wait", "Entering Server", null, null, true);

			_serverId = SocketLoginEvent(event).serverId;
			_delegate = new SdgSocketDelegate(this);
			//SdgAlertChrome.show("Connecting...", "Entering Server");
			_delegate.connect();
		}

		public function result(event:Object):void
		{
			var user:User = ModelLocator.getInstance().user;

			if (event.type == SocketEvent.CONNECTION)
			{
				var loginUserName:String = user.avatarId + "_" + new Date().getTime();
				//var loginUserName:String = user.username;
				if (user.hash != null)
				{
					trace("Login to socket server with hash");
					_delegate.loginWithHash(loginUserName, user.hash, user.avatarId, _serverId);
				}
				else
				{
					trace("Login to socket server");
					_delegate.login(loginUserName, user.password, user.avatarId, _serverId);
				}
			}
			else
			{
				trace('Connected to socket server ' + _serverId)
				user.isSocketLoggedIn = true;
				//_progressDialog.close();
			}
		}

		public function fault(info:Object):void
		{
			var myClass:Class = Object(this).constructor;
			var status:int = (info.hasOwnProperty("success")) ? 1 : 0;

			FlexGlobals.topLevelApplication.closeStarsWaiting();
			if (_failOverAttempted == false)
			{
				//SdgAlertChrome.show("Unable to connect to server.  Not Failover", "Time Out!");
				_delegate.connect(true);
				_failOverAttempted = true;
			}
			else
			{
				SdgAlertChrome.show("Unable to connect to server.  Please check your firewall and anti-virus settings to allow for ActionAllStars.com.", "Time Out!", null, null,
										true, true, 430, 200, ErrorCodeUtil.constructCode(myClass,status.toString()));
				//SdgAlertChrome.show("Unable to connect to server.  Please check your firewall and anti-virus settings to allow for ActionAllStars.com.", "Time Out!");
			}
		}
	}
}
