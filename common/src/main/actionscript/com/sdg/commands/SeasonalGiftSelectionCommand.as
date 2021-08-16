package com.sdg.commands
{
	import mx.rpc.IResponder; 
 	import com.adobe.cairngorm.commands.ICommand;
 	import com.adobe.cairngorm.control.CairngormEvent;
 	import com.sdg.business.SdgServiceDelegate;
 	import com.sdg.events.SeasonalGiftSelectionEvent;
 	
	public class SeasonalGiftSelectionCommand extends AbstractResponderCommand implements ICommand, IResponder
	{
		public function execute(event:CairngormEvent):void
 		{
 			var ev:SeasonalGiftSelectionEvent = event as SeasonalGiftSelectionEvent;
 			new SdgServiceDelegate(this).seasonGiftSelection(ev.avatarId, ev.itemId, ev.answerId, ev.additionalComments);
 		}
 		
 		public function result(data:Object):void
 		{
 		trace("seasonGiftSelection response: " + XML(data));
 		}
	}
}