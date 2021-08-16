package com.sdg.control
{
	import com.sdg.components.controls.SdgAlertChrome;
	import com.sdg.components.dialog.ReferFriendPromoDialog;
	import com.sdg.components.dialog.SaveYourGameDialog;
	import com.sdg.logging.LoggingUtil;
	import com.sdg.model.Avatar;
	import com.sdg.model.MembershipStatus;
	import com.sdg.utils.MainUtil;
	
	import flash.events.EventDispatcher;

	public class ReferAFriendController extends EventDispatcher
	{
		private const LOG_SAVE_GAME:uint = 0;
		private const LOG_UNAPPROVED:uint = 1;
		
		public function ReferAFriendController()
		{}
		
		public function refer(avatar:Avatar,sourceId:uint):void
		{
			// Check if user is registered
			if (avatar.membershipStatus == MembershipStatus.GUEST)
			{
				// If user isn't registered, show save your game dialog
				this.log(LOG_SAVE_GAME,sourceId);
				MainUtil.showDialog(SaveYourGameDialog);
				return;
			}
			
			// Check Avatar Name Accepted - Ask Yves the data to check 
			if (avatar.approved == 0)
			{
				// Name not accepted - show message
				this.log(LOG_UNAPPROVED,sourceId);
				SdgAlertChrome.show("You won't be able to refer friends until your Athlete name has been approved!", "Oops!");
				return;
			}
			
			// Launch Dialog
			MainUtil.showDialog(ReferFriendPromoDialog,{avatar:avatar,sourceId:sourceId},false);
		}
		
		private function log(logId:uint,sourceId:uint):void
		{
			if (logId == LOG_SAVE_GAME)
			{
				if (sourceId==621)
				{
					LoggingUtil.sendClickLogging(LoggingUtil.RAF_FOOTBALL_FIELD_KIOSK_REGISTER);
				}
				else if (sourceId==620)
				{
					LoggingUtil.sendClickLogging(LoggingUtil.RAF_BALLERS_HALL_KIOSK_REGISTER);
				}
				else if (sourceId==619)
				{
					LoggingUtil.sendClickLogging(LoggingUtil.RAF_RIVERWALK_KIOSK_REGISTER);
				}
				else if (sourceId==0)
				{
					LoggingUtil.sendClickLogging(LoggingUtil.RAF_REFER_A_FRIEND_PDA_REGISTER);
				}
			}
			else if (logId == LOG_UNAPPROVED)
			{
				if (sourceId==621)
				{
					LoggingUtil.sendClickLogging(LoggingUtil.RAF_FOOTBALL_FIELD_KIOSK_UNAPPROVED);
				}
				else if (sourceId==620)
				{
					LoggingUtil.sendClickLogging(LoggingUtil.RAF_BALLERS_HALL_KIOSK_UNAPPROVED);
				}
				else if (sourceId==619)
				{
					LoggingUtil.sendClickLogging(LoggingUtil.RAF_RIVERWALK_KIOSK_UNAPPROVED);
				}
				else if (sourceId==0)
				{
					LoggingUtil.sendClickLogging(LoggingUtil.RAF_REFER_A_FRIEND_PDA_UNAPPROVED);
				}
			}
		}
	}
}