package com.sdg.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.adobe.cairngorm.control.CairngormEventDispatcher;
	import com.sdg.business.SdgServiceDelegate;
	import com.sdg.events.InventoryListEvent;
	import com.sdg.factory.SdgItemFactory;
	import com.sdg.model.Avatar;
	import com.sdg.model.InventoryItem;
	import com.sdg.model.ModelLocator;
	import com.sdg.net.Environment;
	import com.sdg.utils.PreviewUtil;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.IResponder;
		
	public class InventoryListCommand extends AbstractResponderCommand implements ICommand, IResponder
	{	
		private var _itemTypeId:uint;
		private var _avatarId:uint;
		
		public function execute(event:CairngormEvent):void
		{
			var ev:InventoryListEvent = event as InventoryListEvent;
			_itemTypeId = ev.itemTypeId;
			_avatarId = ev.avatarId;
			new SdgServiceDelegate(this).getInventory(ev.avatarId, ev.itemTypeId);
		}
		
		public function result(data:Object):void
		{
			var avatar:Avatar = ModelLocator.getInstance().avatar;
			var factory:SdgItemFactory = new SdgItemFactory();
			avatar.apparelList[_itemTypeId] = null;
			
			var avatarInventoryList:ArrayCollection = avatar.getInventoryListById(_itemTypeId);
			
			// Create items.
			trace('InventoryListCommand.result()');
			trace('Building items and adding to avatar inventory...');
			var count:int = 0;
			for each (var item:XML in data.items.children())
			{
				factory.setXML(item);
				var inventoryItem:InventoryItem = factory.createInstance() as InventoryItem;
				trace('Created item: Name = ' + inventoryItem.name + ', itemId = ' + inventoryItem.itemId);
				avatarInventoryList.addItem(inventoryItem);
				
				count++;
			}
			
			// Report on how many items were created and added to the avatar inventory list.
			trace('\n\tTotal items created and added to avatar inventory: ' + count.toString() + '\n');
			
			if (_itemTypeId == PreviewUtil.BACKGROUNDS)
			{
				var defaultBG:InventoryItem = new InventoryItem();
				defaultBG.itemId = 4167;
				defaultBG.thumbnailUrl = Environment.getApplicationUrl() + "/test/inventoryThumbnail?itemId=4167";
				defaultBG.previewUrl = Environment.getApplicationUrl() + "/test/inventoryPreview?itemId=4167&contextId=101";
				defaultBG.itemTypeId = 1019;
				defaultBG.itemValueType = 1;
				avatarInventoryList.addItem(defaultBG);
			}
			
			// Dispatch a "listCompleted" event.
			CairngormEventDispatcher.getInstance().dispatchEvent(new InventoryListEvent(_avatarId, _itemTypeId, InventoryListEvent.LIST_COMPLETED));
		}
		
		override public function fault(info:Object):void
		{
			super.fault(info);
			
			CairngormEventDispatcher.getInstance().dispatchEvent(new InventoryListEvent(_avatarId, _itemTypeId, InventoryListEvent.LIST_FAILED));
		}
	}
}