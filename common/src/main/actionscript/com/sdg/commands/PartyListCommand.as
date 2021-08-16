package com.sdg.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.sdg.business.SdgServiceDelegate;
	import com.sdg.control.BuddyManager;
	import com.sdg.model.Server;
	
	import mx.rpc.IResponder;

	public class PartyListCommand extends AbstractResponderCommand implements ICommand, IResponder
	{
		public function execute(event:CairngormEvent):void
		{
			new SdgServiceDelegate(this).getPartyList(Server.getCurrentId())
		}
		
		public function result(data:Object):void
		{
			trace(data);
			BuddyManager.partyBuddyXML = XML(data.buddies);
		}
	}
}