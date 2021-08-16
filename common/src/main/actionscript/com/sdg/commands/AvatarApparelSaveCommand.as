package com.sdg.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.adobe.cairngorm.control.CairngormEventDispatcher;
	import com.sdg.business.SdgServiceDelegate;
	import com.sdg.events.AvatarApparelSaveEvent;
	import com.sdg.model.Avatar;
	import com.sdg.net.socket.SocketClient;
	
	import mx.rpc.IResponder;
		
	public class AvatarApparelSaveCommand extends AbstractResponderCommand implements ICommand, IResponder
	{
		protected var _avatar:Avatar;
		
		public function execute(event:CairngormEvent):void
		{
			var ev:AvatarApparelSaveEvent = event as AvatarApparelSaveEvent;
			_avatar = ev.avatar;
			new SdgServiceDelegate(this).saveAvatarApparel(ev.avatar);
		}
		
		public function result(data:Object):void
		{
			// Dispatch a save success event.
			CairngormEventDispatcher.getInstance().dispatchEvent(new AvatarApparelSaveEvent(_avatar, AvatarApparelSaveEvent.SAVE_SUCCESS));
			
			// Send a socket uiEvent message to update the room avatar spritesheet.
			SocketClient.getInstance().sendPluginMessage("avatar_handler", "uiEvent", { uiEvent:"<uiEvent><uiId>1</uiId><avUp>1</avUp></uiEvent>" });
		}
	}
}