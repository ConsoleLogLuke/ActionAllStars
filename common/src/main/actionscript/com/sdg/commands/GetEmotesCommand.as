package com.sdg.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.sdg.business.SdgServiceDelegate;
	import com.sdg.model.Emote;
	import com.sdg.model.ModelLocator;
	import com.sdg.view.room.RoomItemCircleMenu;
	
	import mx.rpc.IResponder;
	
	public class GetEmotesCommand extends AbstractResponderCommand implements ICommand, IResponder
	{	
		public function execute(event:CairngormEvent):void
		{ 
			new SdgServiceDelegate(this).getEmotes();
		}
		
		public function result(data:Object):void
		{
			// create new emote containers
			var emoteList:Array = new Array();
			var emoteMap:Object = new Object();
			
			// get the emotes from our XML
			var xmlData:XML = data as XML;
			for each (var emoteXml:XML in xmlData.emotes.emote)
			{
				// create a new emote	
				var emote:Emote = new Emote(
					emoteXml.@emoteId, 
					emoteXml, 
					emoteXml.@emoteUrl,
					emoteXml.@emoteText, 
					emoteXml.@requiredLevel,
					emoteXml.@vendorId); 
					
				// add the emote	
				emoteList.push(emote);
				emoteMap[emote.emoteId] = emote;
				
				// Add the emote icon to the circle menu.
				RoomItemCircleMenu.addEmoteIcon(emote.emoteId);
			}
			
			// set the emotes in ModelLocator
			ModelLocator.getInstance().emoteList = emoteList;			
			ModelLocator.getInstance().emoteMap = emoteMap;			
		}
	}
}