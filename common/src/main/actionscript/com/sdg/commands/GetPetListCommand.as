package com.sdg.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.adobe.cairngorm.control.CairngormEventDispatcher;
	import com.sdg.business.SdgServiceDelegate;
	import com.sdg.events.GetPetListEvent;
	import com.sdg.model.ModelLocator;
	
	import mx.rpc.IResponder;

	public class GetPetListCommand extends AbstractResponderCommand implements ICommand, IResponder
	{
		public function execute(event:CairngormEvent):void
		{
			var ev:GetPetListEvent = event as GetPetListEvent;
			new SdgServiceDelegate(this).getPetList(ev.avatarId);
		}
		
		public function result(data:Object):void
		{
			var petList:Array = new Array();
			//var petListAlt:Array = new Array();
			
			// get the itemSets from our XML
			var xmlData:XML = data as XML;
			var count:int = 0;
			var itemIdList:Array = new Array();
			var invMapping:Object = new Object();
			for each (var petsXml:XML in xmlData.i)
			{
				//petListAlt.push(petsXml.iId);
				
				itemIdList.push(petsXml.Id);
				invMapping[petsXml.Id] = petsXml.iId;
				count++;
			}
			
			// Order iIds for event
			itemIdList.sort(Array.NUMERIC);
			var i:int = 0;
			while (i < count)
			{
				var x:int = itemIdList[i];
				petList.push(invMapping[x]);
				i++;
			}
			
			// dispatch completed event	
			var event:GetPetListEvent = new GetPetListEvent(GetPetListEvent.GET_PET_LIST_COMPLETED, ModelLocator.getInstance().avatar.avatarId);
			event.petIdArray = petList;
			CairngormEventDispatcher.getInstance().dispatchEvent(event);		
		}
		
	}
}