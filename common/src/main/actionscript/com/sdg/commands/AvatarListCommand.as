package com.sdg.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.adobe.cairngorm.control.CairngormEventDispatcher;
	import com.sdg.business.SdgServiceDelegate;
	import com.sdg.components.controls.SdgAlertChrome;
	import com.sdg.events.AvatarListEvent;
	import com.sdg.events.GuestAccountEvent;
	import com.sdg.factory.SdgItemFactory;
	import com.sdg.model.Avatar;
	import com.sdg.model.ModelLocator;
	import com.sdg.model.User;
	import com.sdg.utils.ErrorCodeUtil;
	
	import mx.rpc.IResponder;
		
	public class AvatarListCommand implements ICommand, IResponder
	{		
		public function execute(event:CairngormEvent):void
		{
			var ev:AvatarListEvent = event as AvatarListEvent;
			new SdgServiceDelegate(this).getAvatars(ev.username);
		}
		
		public function result(data:Object):void
		{
			var factory:SdgItemFactory = new SdgItemFactory();
			var avatars:XMLList = data.children();
			var numAvatars:int = avatars.length();
			var userAvatar:Avatar = ModelLocator.getInstance().avatar;
			var user:User = ModelLocator.getInstance().user;
			var xml:XML = new XML();
			
			user.avatars.removeAll();
			
			// Update system avatar.
			if (numAvatars)
			{
				factory.setXML(avatars[0]);
				factory.updateInstance(userAvatar);
				user.avatarId = userAvatar.avatarId;
				user.avatars.addItem(userAvatar);
			}
			
			// Update user avatar list.
			for (var i:int = 1; i < numAvatars; i++)
			{
				factory.setXML(avatars[i]);
				user.avatars.addItem( Avatar(factory.createInstance()) );
			}
		}
		
		public function fault(info:Object):void
		{
			var myClass:Class = Object(this).constructor;
			var status:int = int(info.@status);
			
			SdgAlertChrome.show("Sorry, we were unable to complete your request.", "Time Out!", null, null, 
									true, true, 430, 200, ErrorCodeUtil.constructCode(myClass,status.toString()));
			
			CairngormEventDispatcher.getInstance().dispatchEvent(new GuestAccountEvent(null, GuestAccountEvent.REENABLE_BUTTON));
		}
	}
}