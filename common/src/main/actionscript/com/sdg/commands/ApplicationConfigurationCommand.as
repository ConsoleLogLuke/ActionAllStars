package com.sdg.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.sdg.business.SdgServiceDelegate;
	import com.sdg.events.*;
	import com.sdg.model.*;
	
	import mx.binding.utils.*;
	import mx.collections.ArrayCollection;
	import mx.collections.ItemResponder;

	public class ApplicationConfigurationCommand extends AbstractResponderCommand implements ICommand
	{
		[Bindable]
		public var responseCount:int = 0;
		
		public function execute(event:CairngormEvent):void
		{
			var avatarResponder:ItemResponder = new ItemResponder(onAvatarLevels,onFault);
			new SdgServiceDelegate(avatarResponder).getAvatarLevels();
			
			ModelLocator.getInstance().inventoryItemTypes[1] = new ArrayCollection();
			ModelLocator.getInstance().inventoryItemTypes[2] = new ArrayCollection();
			
			var res_1:ItemResponder = new ItemResponder(onInventoryItemTypes,onFault,{id:1});
			new SdgServiceDelegate(res_1).getItemTypeList(8);
			
			var res_2:ItemResponder = new ItemResponder(onInventoryItemTypes,onFault,{id:2});
			new SdgServiceDelegate(res_2).getItemTypeList(2);
			
			BindingUtils.bindSetter(onRequestComplete, this, "responseCount");
		}
		
		private function onRequestComplete(value:Object):void
		{
			if(value == 3)
			{
				ModelLocator.getInstance().application.isConfigLoaded = true;
			}
		}
		
		public function onAvatarLevels(data:Object, token:Object):void
		{
			var levels:XMLList = data.children();
			for each (var level:XML in levels.level)
			{
				var al:AvatarLevel = new AvatarLevel();
				al.levelId = level.levelId;
				al.levelName = level.levelName;
				al.pointsToLevel = level.subLevel.(subLevelOrder%5 == 1).pointsToLevel;
				ModelLocator.getInstance().avatarLevels[al.levelId] = al;
			}
			responseCount++;
		}
		
		public function onInventoryItemTypes(data:Object, token:Object):void
		{
			var list:ArrayCollection = ModelLocator.getInstance().inventoryItemTypes[token.id] as ArrayCollection;
			if (list == null)
			{
				list = new ArrayCollection;
				ModelLocator.getInstance().inventoryItemTypes[token.id] = list;
			}
			
			// now populate the list			
			var xmlData:XML = data as XML;
			for each (var itemTypeXml:XML in xmlData.itemType)
			{
				var inventoryItemType:InventoryItemType = 
					new InventoryItemType(itemTypeXml.itemTypeId, itemTypeXml.name, itemTypeXml.itemClassId);
				list.addItem(inventoryItemType);										
			}
			responseCount++;
		}
		
		private function onFault(info:Object, token:Object):void
		{
			fault(info);
		}
	}
}