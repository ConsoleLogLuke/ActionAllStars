package com.sdg.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.sdg.business.SdgServiceDelegate;
	import com.sdg.model.Jab;
	import com.sdg.model.ModelLocator;
	import com.sdg.view.room.RoomItemCircleMenu;
	
	import mx.rpc.IResponder;
	
	public class GetJabsCommand extends AbstractResponderCommand implements ICommand, IResponder
	{	
		public function execute(event:CairngormEvent):void
		{ 
			new SdgServiceDelegate(this).getJabs();
		}
		
		public function result(data:Object):void
		{
			// create new jab containers
			var jabList:Array = new Array();
			var jabMap:Object = new Object();
			var userGender:int = ModelLocator.getInstance().avatar.gender;
			
			// get the jabs from our XML
			var xmlData:XML = data as XML;
			for each (var jabXml:XML in xmlData.jabs.jab)
			{
				// create a new jab	
				var jab:Jab = new Jab(
					jabXml.@jabId, 
					jabXml, 
					jabXml.@iconUrl, 
					jabXml.@hudUrl, 
					jabXml.@emoteUrl, 
					jabXml.@senderText, 
					jabXml.@receiverText, 
					jabXml.@emoteText, 
					jabXml.@requiredLevel, 
					jabXml.@showEmote != "0",
					jabXml.@toolTip,
					(int(jabXml.@genderId)) ? jabXml.@genderId : userGender);
				
				// add the jab	
				jabList.push(jab);
				jabMap[jab.jabId] = jab;
				
				// Add the jab icon.
				RoomItemCircleMenu.addJabIcon(jab.jabId);
			}
			
			// set the jabs in ModelLocator
			ModelLocator.getInstance().jabList = jabList;			
			ModelLocator.getInstance().jabMap = jabMap;			
		}
	}
}