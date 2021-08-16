package com.sdg.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.sdg.business.SdgServiceDelegate;
	import com.sdg.events.AvatarEvent;
	import com.sdg.factory.SdgItemFactory;
	import com.sdg.model.Avatar;
	import com.sdg.model.ISetAvatar;
	
	import mx.rpc.IResponder;

	public class AvatarCommand extends AbstractResponderCommand implements ICommand, IResponder
	{
		private var _avatarReceiver:ISetAvatar;
		private var _avatarToUpdate:Avatar;
		
		public function execute(event:CairngormEvent):void
		{
			var ev:AvatarEvent = event as AvatarEvent;
			_avatarReceiver = ev.avatarReceiver;
			_avatarToUpdate = ev.avatarToUpdate;
			new SdgServiceDelegate(this).getAvatar(ev.avatarId);
		}
		
		public function result(data:Object):void
		{
			trace(data.avatar);
			
			// create the avatar
			var factory:SdgItemFactory = new SdgItemFactory();
			factory.setXML(data.avatar[0]);
			
			// If there is an avatar to update then merge the data with it.
			var avatar:Avatar;
			if (_avatarToUpdate != null)
			{
				factory.updateInstance(_avatarToUpdate);
				avatar = _avatarToUpdate;
			}
			else
			{
				avatar = Avatar(factory.createInstance());
			}
			
			// now pass it to our avatar receiver
			_avatarReceiver.avatar = avatar;
		}

	}
}