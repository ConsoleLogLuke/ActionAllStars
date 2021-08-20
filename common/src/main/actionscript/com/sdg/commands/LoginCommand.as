package com.sdg.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.adobe.cairngorm.control.CairngormEventDispatcher;
	import com.sdg.business.SdgServiceDelegate;
	import com.sdg.components.controls.MVPAlert;
	import com.sdg.components.controls.ProgressAlertChrome;
	import com.sdg.events.GuestAccountEvent;
	import com.sdg.events.LoginEvent;
	import com.sdg.logging.LoggingUtil;
	import com.sdg.model.ModelLocator;
	import com.sdg.model.User;
	import com.sdg.utils.MainUtil;

	import mx.events.CloseEvent;
	import mx.rpc.IResponder;

	public class LoginCommand extends AbstractResponderCommand implements ICommand, IResponder
	{
		private var _username:String;
		private var _password:String;
		private var _progressDialog:ProgressAlertChrome;
		private var _avatarId:int;

		public function execute(event:CairngormEvent):void
		{
			//_progressDialog = ProgressAlert.show("In Progress.  Please wait", "Logging in", null, null, true);
			_progressDialog = ProgressAlertChrome.show("In Progress.  Please wait", "Logging in", null, null, true);

			var ev:LoginEvent = event as LoginEvent;
			_username = ev.username;
			_password = ev.password;
			new SdgServiceDelegate(this).login(_username, _password, ModelLocator.getInstance().hasUnity);
		}

		public function result(data:Object):void
		{
			var user:User = ModelLocator.getInstance().user;

			user.username = _username;
			user.password = _password;
			user.firstUser = 0;				// default = not first time in the world
											// note firstUser xml tag not present for
											// 'experienced' users

			// reset user.isLoggedIn and user.avatarId so our watchers in main fire
			user.loggedInStatus = -1;
			user.userId = data.@userId;
			//user.showTos = data.showTos != undefined ? data.showTos : -1;
			//user.freeMonthEligible = data.oneMonthFree == 1;

			user.lastEditionId = data.@lastEditionId;
			user.userEditionId = data.@userEditionId;

			user.mainTutorialCount = data.mainTutorialCount;
//			user.mainTutorialCount = 1;		// force until we get server fixed.

			//trace("DEBUG - Initial firstUser value: "+user.firstUser)
			//user.firstUser = data.@firstUser; // uncommment to turn on first user value
			//trace("DEBUG - New firstUser value: "+user.firstUser)
			user.firstUser = 1; //0;				// turn off firstUser
			user.avatarId = 0;

			_avatarId = data.@avatarId;
			checkMessages(data);

			if (_progressDialog)
				_progressDialog.close();
		}

		public override function fault(data:Object):void
		{
			var user:User = ModelLocator.getInstance().user;
			user.loggedInStatus = -1;
			user.userId = data.@userId;
			user.loggedInStatus = data.@status;
			if (_progressDialog)
				_progressDialog.close();

			CairngormEventDispatcher.getInstance().dispatchEvent(new GuestAccountEvent(null, GuestAccountEvent.REENABLE_BUTTON));
		}

		private function checkMessages(data:Object):void
		{
			var alert:MVPAlert;

			if (data.hasOwnProperty("@accountExpire"))
			{
				if (data.@accountExpire == 0)
				{
					LoggingUtil.sendClickLogging(LoggingUtil.MVP_UPSELL_VIEW_MVP_EXPIRED);
					alert = MVPAlert.show("Sorry, Athlete, but it looks like your membership has expired. " +
							"Activate your new membership now to continue enjoying all the MVP features of " +
							"Action AllStars.", "Membership Expired", onClose);

					alert.addButton("Renew Membership", LoggingUtil.MVP_UPSELL_CLICK_MVP_EXPIRED, 230);
				}
				else
				{
					var message:String = "Heads up, Athlete! Just a friendly reminder that your MVP membership is expiring in " + data.@accountExpire;
					if (data.@accountExpire == 1)
						message += " day.";
					else
						message += " days.";
					message += " Renew your membership now to avoid losing access to all MVP features.";

					alert = MVPAlert.show(message, "Membership Expiring", onClose);

					alert.addButton("Continue");
				}
			}
			else if (data.hasOwnProperty("@firstMvpLogin"))
			{
				alert = MVPAlert.show("You have been awarded 5000 tokens for joining the MVP team! Jump in " +
						"and experience Action AllStars as an MVP Athlete!", "Welcome to the Team!", onClose, "swfs/mvp/BackgroundApproved.swf");

				alert.addButton("Play!");
			}
			else
				ModelLocator.getInstance().user.loggedInStatus = data.@status;



			function onClose(event:CloseEvent):void
			{
				var identifier:int = event.detail;

				if (identifier == LoggingUtil.MVP_UPSELL_CLICK_MVP_EXPIRED)
					MainUtil.goToMVP(identifier);
				else
					ModelLocator.getInstance().user.loggedInStatus = data.@status;
			}
		}
	}
}
