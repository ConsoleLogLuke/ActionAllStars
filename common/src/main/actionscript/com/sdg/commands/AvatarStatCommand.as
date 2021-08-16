package com.sdg.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.adobe.cairngorm.control.CairngormEventDispatcher;
	import com.sdg.business.SdgServiceDelegate;
	import com.sdg.components.controls.SdgAlertChrome;
	import com.sdg.events.AvatarStatEvent;
	import com.sdg.utils.ErrorCodeUtil;
	
	import mx.rpc.IResponder;
	
	public class AvatarStatCommand implements ICommand, IResponder
	{
		private var _event:AvatarStatEvent;
		
		public function execute(event:CairngormEvent):void
		{
			_event = event as AvatarStatEvent;
			if (_event.type == AvatarStatEvent.GET_STAT)
				new SdgServiceDelegate(this).getAvatarStat(_event.avatarId, _event.statNameId);
			else if (_event.type == AvatarStatEvent.SAVE_STAT)
				new SdgServiceDelegate(this).saveAvatarStat(_event.avatarId, _event.statNameId, _event.statValue);
		}
		
		public function result(data:Object):void
		{
			if (_event.type == AvatarStatEvent.GET_STAT)
			{
				CairngormEventDispatcher.getInstance().dispatchEvent(new AvatarStatEvent(_event.avatarId, _event.statNameId, AvatarStatEvent.STAT_RECEIVED, data.statValue));
			}
		}
		
		public function fault(info:Object):void
		{
			var myClass:Class = Object(this).constructor;
			var status:int = int(info.@status);
			
			if (status != 409)
			{
				SdgAlertChrome.show("Sorry, we were unable to complete your request.", "Time Out!", null, null, 
										true, true, 430, 200, ErrorCodeUtil.constructCode(myClass,status.toString()));
				//SdgAlertChrome.show("Error with avatar stat.", "Time Out!", null, null, 
										//true, true, false, 430, 200, ErrorCodeUtil.constructCode(myClass,status.toString()));
			}
		}
	}
}
