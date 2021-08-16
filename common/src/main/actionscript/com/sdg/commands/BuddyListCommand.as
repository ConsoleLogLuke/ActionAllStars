package com.sdg.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.sdg.business.SdgServiceDelegate;
	import com.sdg.model.ModelLocator;
	import com.sdg.control.BuddyManager;
	
	import mx.rpc.IResponder;

	public class BuddyListCommand extends AbstractResponderCommand implements ICommand, IResponder
	{
		public function execute(event:CairngormEvent):void
		{
			new SdgServiceDelegate(this).getBuddyList(ModelLocator.getInstance().avatar.avatarId);
		}
		
		public function result(data:Object):void
		{
			trace(data);
			BuddyManager.buddyXML = XML(data.buddies);
			//BuddyManager.latestBuddyList = XML(data);
		}
	}
}