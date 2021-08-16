package com.sdg.components.controls
{
	import com.sdg.control.HudController;
	import com.sdg.model.NotificationIcon;
	
	public class BuddyRequestMessage extends RequestMessage
	{
		public var buddyAvatarId:int;
		public var buddyAvatarName:String;
		
		public function BuddyRequestMessage()
		{
			super();
			iconSource = NotificationIcon.getIcon(NotificationIcon.BUDDY).icon;
		}
		
		override protected function onClick(bool:Boolean):void
		{
			if (HudController.getInstance().processBuddyRequestReply(bool, buddyAvatarId, buddyAvatarName) && _removeCallback != null)
				_removeCallback(this);
		}
	}
}